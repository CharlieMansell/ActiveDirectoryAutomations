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

    $YesOrNo = Read-Host "Will a copy of the mail be required in the originating mailbox? Please enter your response (y/n)"
    while("y","n" -notcontains $YesOrNo )
        {
            $YesOrNo = Read-Host "Please enter your response (y/n)"
        }
#Check if Sending User Exists.  

Do {
    # Get a username from the user
    $originusername = read-host 'Enter the user, you wish to forward from' 

   
    Try {
            # Check if it's in AD
            $checkUsername = Get-ADUser -Identity $originusername -ErrorAction Stop
            write-host "You have forward the mail in this users mailbox: $originuser" -foreground Green
        }
    Catch {
            # Couldn't be found
            Write-Warning -Message "Could not find a user with the username: $originusername. Please check the spelling and try again."

            # Loop de loop (Restart)
            $originusername = $null
          }
   }   
While ($null -eq $originusername)

#Check if Receiving User Exists.  

Do {
    # Get a username from the user
    $forwardingusername = read-host 'Enter the user you wish to forward the mail too' 

    Try {
            # Check if it's in AD
            $checkUsername = Get-ADUser -Identity $forwardingusername -ErrorAction Stop
            write-host "You have selected to forward the mail to the following user account: $forwardingusername" -foreground Green
        }
    Catch {
            # Couldn't be found
            Write-Warning -Message "Could not find a user with the username: $forwardingusername. Please check the spelling and try again."

            # Loop de loop (Restart)
            $forwardingusername = $null
          }
   }   
While ($null -eq $forwardingusername)

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

if ($YesOrNo -eq "Y" )
{
    Set-Mailbox -Identity $originusername -DeliverToMailboxAndForward $true -ForwardingAddress $forwardingusername 
}
else{
    Set-Mailbox -Identity $originusername -DeliverToMailboxAndForward $false -ForwardingAddress $forwardingusername 
}
