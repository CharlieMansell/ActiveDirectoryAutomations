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

#Generating Random Password
write-host "Generating User Password..." -Foreground Green

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
  Connect-MsolService -Credential $credential

  #Get O365 Tenant Domain
  write-host 'Obtaining Domain Name'
  $domain = get-msoldomain | Where-Object {$_.Name.Split('.').Length -eq 3 -and $_.Name -like '*onmicrosoft.com'}
  $domainname = $domain.name
  
  #Get UPN of User
  write-host 'Obtaining UPN...'
  $upn = $username + "@" + $domainname
  

  #Creating user
  $userInstance = Get-ADUser -Identity "hrtemplateuser" 
  New-ADUser -SAMAccountName "ellenAdams"  -Instance $userInstance -DisplayName "Ellen Adams"


  New-ADUser -Name $fullname -GivenName $firstname -Surname $lastname -DisplayName $fullname -Email $upn -SamAccountName $username -UserPrincipalName $upn -Path "OU=Users,OU=FOOBAR,DC=FOOBAR,DC=com" -AccountPassword($userpassword) -Enabled $true


#---------------------------------------------------------------------------#






$ChoosingDepartmentofUser = Read-Host "What Department does this user belong too? Please enter your response ('HR','Finance','Property Manager' or 'MORE')" -Foreground Green

    while("HR","Finance","Property Manager" -notcontains $ChoosingDepartmentofUser )
        {
            $ChoosingDepartmentofUser = Read-Host "Please enter your response ('HR','Finance','Property Manager' or 'MORE')"
        }
if ($ChoosingDepartmentofUser -eq 'HR')
{
    $CopyFromUser = Get-ADUser $HRuser -prop MemberOf
    $CopyToUser = Get-ADUser $username -prop MemberOf
    $CopyFromUser.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Members $CopyToUser

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

