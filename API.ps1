$Cred = Get-Credential
$url = "https://webservices6.autotask.net/atservicesrest/v1.0/CompletedByResourceID/2"
$Body = @{
    search = "id"
    output_mode = "csv"
}
Invoke-RestMethod -Method 'GET' -Uri $url -Credential $Cred -Body $body -OutFile output.csv
