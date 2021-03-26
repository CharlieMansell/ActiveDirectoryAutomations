#Written by Charlie Mansell - Lucidity IT
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

    $YesOrNo = Read-Host "What level of mailbox permissions are required? Please enter your response ('read and manage permissions','send as permissions' or 'send on behalf of permissions')"

    while("read and manage permissions","send as permissions","send on behalf of permissions" -notcontains $YesOrNo )
        {
            $YesOrNo = Read-Host "Please enter your response ('read and manage permissions','send as permissions' or 'send on behalf of permissions')"
        }
#Check if requires User Exists.  

Do {
    # Get a username from the user
    $assigningtomailbox = read-host 'Enter the user that requires access to the mailbox' 

   
    Try {
            # Check if it's in AD
            $checkUsername = Get-ADUser -Identity $assigningtomailbox -ErrorAction Stop
            write-host "You have selected to disable the following user account: $assigningtomailbox" -foreground Green
        }
    Catch {
            # Couldn't be found
            Write-Warning -Message "Could not find a user with the username: $assigningtomailbox. Please check the spelling and try again."

            # Loop de loop (Restart)
            $assigningtomailbox = $null
          }
   }   
While ($null -eq $assigningtomailbox)


#Check if Receiving User Exists.  

Do {
    # Get a username from the user
    $ = read-host 'Enter the user you wish to forward the mail too' 

    Try {
            # Check if it's in AD
            $checkUsername = Get-ADUser -Identity $mailboxassigningtouser -ErrorAction Stop
            write-host "You have selected to disable the following user account: $mailboxassigningtouser" -foreground Green
        }
    Catch {
            # Couldn't be found
            Write-Warning -Message "Could not find a user with the username: $mailboxassigningtouser. Please check the spelling and try again."

            # Loop de loop (Restart)
            $v = $null
          }
   }   
While ($null -eq $mailboxassigningtouser)

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

#Connect to Exchange Online 
write-host "Connecting to Exchange Online"
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

if ($YesOrNo -eq "read and manage permissions")
{
    Add-MailboxPermission -Identity $mailboxassigningtouser -User $assigningtomailbox -AccessRights ReadPermission -InheritanceType All
}
if ($YesOrNo -eq "send as permissions")
{
    Add-RecipientPermission -Identity $mailboxassigningtouser -Trustee $assigningtomailbox -AccessRights SendAs
}
if ($YesOrNo -eq "send on behalf of permissions")
{
    Set-Mailbox -Identity $mailboxassigningtouser -GrantSendOnBehalfTo $assigningtomailbox
}