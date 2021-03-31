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
#Defining User Templates (These can be named the same across multiple clients) 
$HRuser = "hrtemplateuser"



#---Generating Username, Password + Creating User---#

#Defining the username of new user
$firstname = read-host "Input the first name of the new user" 
$lastname = read-host "Input the last name of the new user"
$fullname = "$firstname $lastname"
$username = "$firstname.$lastname"
$username

#Defining OU to Create User in
$ou = Read-Host "Input the OU the user needs to be created in" 

#Generating Random Password
write-host "Generating User Password..." -ForegroundColor Green

# requires CSV file in same directory as script
#--------------------------------------------------------------------------------------------------
# You can edit to '-le' value to create more passwords if needed.

$rand = new-object System.Random

# read-in very large file creating smaller list of random words
$words = Get-Content "words.csv" | Sort-Object {Get-Random} -unique | select -first 7776

  # query the smaller list of words for single entry (2 times)
  $word1 = $words | Sort-Object {Get-Random} -unique | select -first 1  
  $word2 = $words | Sort-Object {Get-Random} -unique | select -first 1  


  # create random digits
  $number1 = Get-Random -Minimum 100 -Maximum 999

  # create random special character
  $specialCharacters = '~,!,@,#,$,%,^,&,*,(,),>,<,?,\,/,_,-,=,+'
  $array = @()
  $specialcharacter1 = $array += $specialCharacters.Split(',') | Get-Random -Count 1

  $specialCharacters2 = '~,!,@,#,$,%,^,&,*,(,),>,<,?,\,/,_,-,=,+'
  $array2 = @()
  $specialcharacter2 = $array2 += $specialCharacters2.Split(',') | Get-Random -Count 1


  # add together and return new random password
  $password = $word1 + $specialcharacter2 + $word2 + $number1 + $specialcharacter1
  $password = $password.replace(' ','')
  $userpassword = ConvertTo-SecureString $password -AsPlainText -Force
  
  #Obtain the UPN 

  #Connect to MS Online
  write-host 'Connecting to MS Online...'
  $credential = Get-Credential

  #Connect to MSONLINE + Store Credentials
Do {
    $credential = Get-Credential
    write-host 'Connecting to MS Online...' -foreground Green
   #Connecting
    try {
        if (Connect-MsolService -Credential $credential) { 
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


  #Get O365 Tenant Domain
  write-host 'Obtaining Domain Name'
  $domain = get-msoldomain | Where-Object {$_.Name.Split('.').Length -eq 3 -and $_.Name -like '*FOOBAR.com'} #PULL IN Domainsgit ad
  $domainname = $domain.name
  
  #Get UPN of User
  write-host 'Obtaining UPN...'
  $upn = $username + "@" + $domainname

  #Install and Connect to Exchange Online Module

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
    Connect-ExchangeOnline -Credential $credential
    write-host "Connecting to Exchange Online" -foreground Green


    Set-mailbox $username -PrimarySmtpAddress "$username@$domainname"

    #Remove Exchange Session
    if ($ExoSession) { Remove-PSSession -Session $ExoSession -ErrorAction SilentlyContinue } 


#   New-ADUser -Name $fullname -GivenName $firstname -Surname $lastname -DisplayName $fullname -Email $upn -SamAccountName $username -UserPrincipalName $upn -Path "OU=Users,OU=FOOBAR,DC=FOOBAR,DC=com" -AccountPassword($userpassword) -Enabled $true


#---------------------------------------------------------------------------#

$ChoosingDepartmentofUser = Read-Host "What Department does this user belong too? Please enter your response ('HR','Finance','Property Manager' or 'MORE')" -Foreground Green

    while("HR","Finance","Property Manager" -notcontains $ChoosingDepartmentofUser )
        {
            $ChoosingDepartmentofUser = Read-Host "Please enter your response ('HR','Finance','Property Manager' or 'MORE')"
        }
if ($ChoosingDepartmentofUser -eq 'HR')
{
    $userInstance = Get-ADUser -Identity "hrtemplateuser" 
    New-ADUser -Name $fullname -Instance $HRuser -GivenName $firstname -Surname $lastname -DisplayName $fullname -SamAccountName $username -Email $upn -UserPrincipalName $upn -Path $ou -AccountPassword($userpassword) -Enabled $true #OU to read from the INI File.

}
if ($ChoosingDepartmentofUser -eq 'Finance')
{
    $CopyFromUser = Get-ADUser $FinanceUser -prop MemberOf
    $CopyToUser = Get-ADUser $ -prop MemberOf
    $CopyFromUser.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Members $CopyToUser

}
if ($ChoosingDepartmentofUser -eq 'Property Manager')
{
    $CopyFromUser = Get-ADUser $PropertyManagerUser -prop MemberOf
    $CopyToUser = Get-ADUser $ -prop MemberOf
    $CopyFromUser.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Members $CopyToUser

}
if ($ChoosingDepartmentofUser -eq 'OTHER')
{
    $CopyFromUser = Get-ADUser $HRUser -prop MemberOf
    $CopyToUser = Get-ADUser $ -prop MemberOf
    $CopyFromUser.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Members $CopyToUser

}
if ($ChoosingDepartmentofUser -eq 'OTHER')
{
    $CopyFromUser = Get-ADUser $HRUser -prop MemberOf
    $CopyToUser = Get-ADUser $ -prop MemberOf
    $CopyFromUser.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Members $CopyToUser

}
if ($ChoosingDepartmentofUser -eq 'OTHER')
{
    $CopyFromUser = Get-ADUser $HRUser -prop MemberOf
    $CopyToUser = Get-ADUser $ -prop MemberOf
    $CopyFromUser.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Members $CopyToUser

}
Get-ADSyncScheduler
$YesOrNo = Read-Host "Is there currently a Sync in Progress? (Y/N)"
while("y","n" -notcontains $YesOrNo )
    {
        $YesOrNo = Read-Host "Please enter your response (Y/N)"
    }

if ($YesOrNo -eq 'n') {
    Start-ADSyncSyncCycle -PolicyType Init
}
else
{
    Write-Warning 'Waiting 15 Minutes for the Sync Cycle to Finish'
    Start-Sleep -s 900
    Write-Host 'Syncing with Office 365' -foreground Green
    Start-ADSyncSyncCycle -PolicyType Init
}
#// TODO PULL IN LICENSE TYPES FROM INI FILE ETC

#Confirm user sync completed
Do {
    "Waiting on AzureAD Sync to complete..."
    Start-Sleep -s 20
    $isusersetup = Get-MsolUser -UserPrincipalName $upn
} 
While ($isusersetup -eq $null)

Set-MsolUser -UserPrincipalName $upn -UsageLocation AU
Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses "reseller-account:O365_BUSINESS_ESSENTIALS"
