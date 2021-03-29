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
#Defining the username of new user
$firstname = read-host "Input the first name of the new user"
$lastname = read-host "Input the last name of the new user"
$username = "$firstname.$lastname"
$username

#Generating Random Password

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
  $password


write-host "New Users Password is '$password'"

$ChoosingDepartmentofUser = Read-Host "What Department does this user belong too? Please enter your response ('HR','Finance','Property Manager' or 'MORE')" #ENTER MORE HERE

    while("HR","Finance","Property Manager" -notcontains $ChoosingDepartmentofUser )
        {
            $ChoosingDepartmentofUser = Read-Host "Please enter your response ('HR','Finance','Property Manager' or 'MORE')"
        }
if ($ChoosingDepartmentofUser -eq 'HR')
{
    $CopyFromUser = Get-ADUser $HRUser -prop MemberOf
    $CopyToUser = Get-ADUser $ -prop MemberOf
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

