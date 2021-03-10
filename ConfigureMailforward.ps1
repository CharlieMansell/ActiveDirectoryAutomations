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
$ticketnumber = read-host 'Enter Ticket Number'
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
$credential = Get-Credential
write-host "Connecting to Exchange Online"
Connect-ExchangeOnline -Credential $credential