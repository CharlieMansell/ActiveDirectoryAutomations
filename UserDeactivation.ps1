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
#Check if AD User Exists.  

Do {
    # Get a username from the user
    $username = read-host 'Enter the username of the user you wish to disable' 

   
    Try {
            # Check if it's in AD
            $checkUsername = Get-ADUser -Identity $username -ErrorAction Stop
            write-host "You have selected to disable the following user account: $username" -foreground Green
        }
    Catch {
            # Couldn't be found
            Write-Warning -Message "Could not find a user with the username: $username. Please check the spelling and try again."

            # Loop de loop (Restart)
            $username = $null
          }
   }   
While ($null -eq $username)
#Check if OU Exists

Do {
    # Get a username from the user
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
        Write-Host 'User has not been disabled...NEED TO PUT IN ERROR CHECKING AND FIX.' #User should not have an issue being disabled but need to include error fixing. 
   
    }

#Move User to Disabled Users OU then check if User is in Disabled User folder
$guid = Get-ADUser -identity $username -Properties ObjectGUID | Select-Object -ExpandProperty ObjectGUID
Move-ADObject -Identity $guid -TargetPath $disableduserOU
    #Obtain the Folder of Current User - Check if User in OU
    $Properties = get-aduser $username
    $dn = $Properties.distinguishedname.substring($Properties.distinguishedname.indexof(",") + 1,$Properties.distinguishedname.Length - $Properties.distinguishedname.indexof(",") - 1)
    $ou = ($dn.split(',')[0])
if ($ou -match "Disabled Users") 
{ 
     Write-Host "User $username has been successfully moved to the Disabled Users OU!" -Foreground Green
}
else 
{
     Write-Host 'User has not been Moved...NEED TO PUT IN ERROR CHECKING AND FIX.' #User should not have an issue being disabled but need to include error fixing. 
}
#Get Today's date & Current Logged in User for Description
$currentloggedinuser = (Get-WmiObject -Class Win32_Process -Filter 'Name="explorer.exe"').GetOwner().User
$todaysdate = (Get-Date).ToString('dd/MM/yyyy')
#Update Description
Set-ADUser $username -Description "Deactivated on $todaysdate by $currentloggedinuser" #Need to create checking mechanism here.
#Run AD Delta Sync

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
    write-host "Azure AD Module did not install"
}

#Connect to Exchange Online 
$O365Username = read-host 'Enter the username of the O365 Tenancy the User Belongs too' 

write-host "Connecting to Exchange Online"
Connect-ExchangeOnline -UserPrincipalName $O365Username
Set-Mailbox $username -Type Shared
$Checkmailboxtype = Get-Mailbox -RecipientTypeDetails SharedMailbox
If ($Checkmailboxtype -match "charlie.brown")
{
    write-host "Work"
}
Else{
    Write-host "broke"
}






# Get Admin Credential + Connect to Azure AD Module
# $credential = Get-Credential
# write-host "Connecting to Azure AD Now"
# Connect-AzureAD -Credential $credential

# Get-MsolUser -All -UnlicensedUsersOnly

