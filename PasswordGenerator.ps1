# requires CSV file in same directory as script
#--------------------------------------------------------------------------------------------------
# You can edit to '-le' value to create more passwords if needed.

$rand = new-object System.Random

# read-in very large file creating smaller list of random words
$words = Get-Content "words.csv" | Sort-Object {Get-Random} -unique | select -first 7776

Function Create-Password
{ 
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
  
write-host "Password is $password"
}
Create-Password