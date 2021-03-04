Add-WindowsFeature RSAT-AD-PowerShell
$checkmodule = Get-WindowsFeature -Name RSAT-AD-PowerShell
 if ( $checkmodule.Name -eq "RSAT-AD-PowerShell") 
    {
        write-host "Active Directory PowerShell Module Installed Successfully!" -foreground Green
        write-host "Importing Active Directory Module Now" -foreground Green
        Import-Module ActiveDirectory
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
$checkenabled
$username.DistinguishedName
if ($checkenabled -match "False") 
    { 
        Write-Host "User $username has been successfully disabled!" -Foreground Green
    }
else 
    {
        Write-Host 'User has not been disabled...NEED TO PUT IN ERROR CHECKING AND FIX.' #User should not have an issue being disabled but need to include error fixing. 
   
    }
#Move User to Disabled Users OU
$userGuid = $username.ObjectGUID

Move-ADObject -Identity $userGuid -TargetPath $disableduserOU