#Written by Charlie Mansell - Lucidity IT
#Script needs to be run on an Domain Controller
#Need to know the OU + Disabled user OU Must be called "Disabled Users" or "Users Disabled"
write-host "Installing PowerShell Active Directory Module Now..." -foreground Green
Add-WindowsFeature RSAT-AD-PowerShell
$checkADmodule = Get-WindowsFeature -Name RSAT-AD-PowerShell
 if ( $checkADmodule.Name -eq "RSAT-AD-PowerShell") 
    {
        write-host "Active Directory PowerShell Module Installed Successfully!" -foreground Green
        write-host "Importing Active Directory Module Now" -foreground Green
        Import-Module ActiveDirectory
    }
    else{
        write-host "AD Module did not install"
    }
$ticketnumber = read-host 'Enter Ticket Number'
$username = read-host 'Enter the username of the user you wish to disable' 


#Check if AD User Exists.  

Do {
    # Get a username from the user
    $username = read-host 'Enter the username of the user you wish to disable' 

    Try {
            # Check if it's in AD
            $checkUsername = Get-ADUser -Identity $username -ErrorAction Stop
            
        }
        
    Catch {
            # Couldn't be found
            Write-Warning -Message "Could not find a user with the username: $username. Please check the spelling and try again."

            # Loop de loop (Restart)
            $username = $null
          }
    }    
While ($null -eq $username)


#Check if the user is already disabled
$checkintialenabled = (Get-ADUser -Identity $username).enabled
if ($checkintialenabled -match "False") 
    { 
      Write-Warning "User $username is already disabled..."
      $decision 
      Write-Warning "Closing Script"
      exit
    }
else 
    {
        write-host "You have selected to disable the following user account: $username" -foreground Green

    }


#Check if OU Exists

Do {
    # Get OU from the user
    $disableduserOU = read-host 'Enter the OU you want to move the user too' 

   
    Try {
            # Check if it's in AD
            $checkOU = Get-ADOrganizationalUnit -Identity $disableduserOU -ErrorAction Stop
            write-host "You have selected to move the user to this location: $disableduserOU" -foreground Green
        }
    Catch {
            # Couldn't be found
            Write-Warning -Message "Could not find an OU with the name: $disableduserOU. Please check the spelling and try again."

            # Loop de loop (Restart)
            $disableduserOU = $null
          }
   }   
While ($null -eq $disableduserOU)
#Disable AD User Account and Check to Ensure its been disabled. 
Disable-ADAccount -Identity $username
$checkenabled = (Get-ADUser -Identity $username).enabled
if ($checkenabled -match "False") 
    { 
        Write-Host "User $username has been successfully disabled!" -Foreground Green
    }
else 
    {
        Write-Warning 'User can not be disabled'

    }
#Move User to Disabled Users OU then check if User is in Disabled User folder
$guid = Get-ADUser -identity $username -Properties ObjectGUID | Select-Object -ExpandProperty ObjectGUID
Move-ADObject -Identity $guid -TargetPath $disableduserOU
    #Obtain the Folder of Current User - Check if User in OU
    $Properties = get-aduser $username
    $dn = $Properties.distinguishedname.substring($Properties.distinguishedname.indexof(",") + 1,$Properties.distinguishedname.Length - $Properties.distinguishedname.indexof(",") - 1)
if ($dn -match $checkou) 
{ 
     Write-Host "User $username has been successfully moved to the Disabled Users OU!" -Foreground Green
}
else 
{
     Write-Host 'User has not been Moved'
}

#Get Today's date & Current Logged in User for Description
$currentloggedinuser = (Get-WmiObject -Class Win32_Process -Filter 'Name="explorer.exe"').GetOwner().User
$todaysdate = (Get-Date).ToString('dd/MM/yyyy')
#Update Description
Set-ADUser $username -Description "Deactivated on $todaysdate by $currentloggedinuser - $ticketnumber" #Need to create checking mechanism here.

#Check if Running then Run AD Delta Sync
Get-ADSyncScheduler
$confirmation = Read-Host "Is there currently a Sync in Progress? (Y/N)"
if ($confirmation -eq 'n') {
    Start-ADSyncSyncCycle -PolicyType Init
}
else
{
    Write-Warning 'Waiting 15 Minutes for the Sync Cycle to Finish'
    Start-Sleep -s 900
    Write-Host 'Syncing with Office 365' -foreground Green
    Start-ADSyncSyncCycle -PolicyType Init
}


#Install Exchange Online Module
write-host "Installing PowerShell Exchange Online Active Directory Module Now..." -foreground Green
Install-Module -Name ExchangeOnlineManagement -force
$CheckExchangeModule = Get-InstalledModule -Name ExchangeOnlineManagement
if ( $CheckExchangeModule.Name -eq "ExchangeOnlineManagement") 
{
    write-host "ExchangeOnlineManagement Active Directory PowerShell Module Installed Successfully!" -foreground Green
    write-host "Importing ExchangeOnlineManagement Module Now" -foreground Green
    Import-Module ExchangeOnlineManagement
    
}
else{
    write-host "ExchangeOnlineManagement AD Module did not install"
}

#Connect to Exchange Online + Check Credentials

Do {
    #Get Credentials 
    $credential = Get-Credential
    write-host "Connecting to Exchange Online" -foreground Green

   #Connecting
    try {
        if (Connect-ExchangeOnline -Credential $credential) { 
            Write-Host "Connected" }
        }  
        #Check for Error
        catch [System.AggregateException] {
            Write-Warning "Invalid Credentials!"
            #Repeat if wrong
            $credential = $null
        }
   }   
While ($null -eq $credential)
Write-host 'Converting the users mailbox to shared' -foreground Green
Set-Mailbox $username -Type Shared
Start-Sleep -s 90
$Checkmailboxtype = Get-Mailbox -RecipientTypeDetails SharedMailbox
If ($Checkmailboxtype -match $username)
{
    write-host "The Mailbox of $username has been successfully converted to a shared mailbox" -foreground Green
}
Else{
    Write-host "Mailbox was not converted...waiting for the mailbox to be converted"
    Start-Sleep -s 90
    If ($Checkmailboxtype -match $username)
    {
        write-host "The Mailbox of $username has been successfully converted to a shared mailbox" -foreground Green  
    }
    else {
        Write-host "Mailbox was not converted...waiting for the mailbox to be converted"
        Start-Sleep -s 90
        If ($Checkmailboxtype -match $username)
        {
            write-host "The Mailbox of $username has been successfully converted to a shared mailbox" -foreground Green  
        }
        else {
            Write-host "Mailbox was not converted...exiting script to prevent loss of data"
            exit
        }
                 
    }
    
}
#Remove Exchange Session
if ($ExoSession) { Remove-PSSession -Session $ExoSession -ErrorAction SilentlyContinue } 

#Install and Import Azure AD Module. 
write-host "Installing PowerShell Azure Active Directory Module Now..." -foreground Green
Install-Module -Name AzureAD -force
$CheckAzureModule = Get-InstalledModule -Name AzureAD
if ( $CheckAzureModule.Name -eq "AzureAD") 
{
    write-host "Azure Active Directory PowerShell Module Installed Successfully!" -foreground Green
    write-host "Importing Azure Active Directory Module Now" -foreground Green
    Import-Module AzureAD
}
else{
    write-host "Azure AD Module did not install"
}

# Get Admin Credential + Connect to Azure AD Module
write-host "Connecting to Azure AD Now"
Connect-AzureAD -Credential $credential 

#Install MS Online Module
write-host "Installing PowerShell MSOnline Active Directory Module Now..." -foreground Green
Install-Module -Name MSOnline -force
$CheckMSOnline = Get-InstalledModule -Name AzureAD
if ( $CheckMSOnline.Name -eq "AzureAD") 
{
    write-host "MSOnline Active Directory PowerShell Module Installed Successfully!" -foreground Green
    write-host "Importing MSOnline Active Directory Module Now" -foreground Green
    Import-Module MSOnline
}
else{
    write-host "MSOnline AD Module did not install"
}

#Connect to MS Online
write-host 'Connecting to MS Online...'
Connect-MsolService -Credential $credential

#Get O365 Tenant Domain
write-host 'Obtaining Domain Name'
$domain = get-msoldomain | Where-Object {$_.Name.Split('.').Length -eq 3 -and $_.Name -like '*onmicrosoft.com'}
$domainname = $domain.name

#Get UPN of User
write-host 'Obtaining UPN...'
$upn = $username + "@" + $domainname

#Remove all Licenses from user
(get-MsolUser -UserPrincipalName $upn).licenses.AccountSkuId |
ForEach-Object{
    Set-MsolUserLicense -UserPrincipalName $upn -RemoveLicenses $_
}
Write-Host 'All Licenses have been removed from the user: $username' -foreground Green
Write-Host '$username has been deactivated successfully!' -foreground Green



