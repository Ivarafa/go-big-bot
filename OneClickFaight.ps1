Write-Host @'

 /$$$$$$$$ /$$$$$$  /$$$$$$  /$$$$$$  /$$   /$$ /$$$$$$$$        /$$$$$$   /$$$$$$    /$$   /$$$$$$$$
| $$_____//$$__  $$|_  $$_/ /$$__  $$| $$  | $$|__  $$__/       /$$__  $$ /$$$_  $$ /$$$$  |_____ $$/
| $$     | $$  \ $$  | $$  | $$  \__/| $$  | $$   | $$         |__/  \ $$| $$$$\ $$|_  $$       /$$/ 
| $$$$$  | $$$$$$$$  | $$  | $$ /$$$$| $$$$$$$$   | $$           /$$$$$$/| $$ $$ $$  | $$      /$$/  
| $$__/  | $$__  $$  | $$  | $$|_  $$| $$__  $$   | $$          /$$____/ | $$\ $$$$  | $$     /$$/   
| $$     | $$  | $$  | $$  | $$  \ $$| $$  | $$   | $$         | $$      | $$ \ $$$  | $$    /$$/    
| $$     | $$  | $$ /$$$$$$|  $$$$$$/| $$  | $$   | $$         | $$$$$$$$|  $$$$$$/ /$$$$$$ /$$/     
|__/     |__/  |__/|______/ \______/ |__/  |__/   |__/         |________/ \______/ |______/|__/    

Fundator Artifical IntelliGence Heritage Tournament 2017
-----------------------------------------------------------------------------------------------

NB: This script downloads a bunch of files. Run the script inside a clean folder of your choice.


Pre-requisites before running this script:

  - A GitHub user account (consult the tournament manual (or Google) if you don't have one)
  - An empty GitHub repository for your AI bot (^-ditto)
  - A bot name

This script does the following:
    
    - Collects your AI bot's GitHub repository URL
    - Collects your AI bot's name
    - Registers the repository URL and bot name in a Google Sheet
    - Downloads ghostly - a PAC-MAN server application (your bot is a client)
    - Downloads a sample bot written in python (use it as a starting point, if you like)
    - Starts ghostly
    - Launches the sample bot, connecting it to ghostly


Got questions? Grab the nearest Fundator representative :)

-----------------------------------------------------------------------------------------------

'@


do {
    try {
        $urlOk = $true;
        $repo_url = Read-Host -Prompt "GitHub repository URL in SSH-format (ex: git@github.com:yourusername/yourrepo.git))";

        if ($repo_url -notmatch '^git@github.com:.+[/].+\.git$'){
            Write-Host "Invalid repo URL. Must match this regex: ^git@github.com:.+[/].+\.git$"
            $urlOk = $false
        }
    }
    catch {
        Write-Host "Something bad happened. Try again :)";
        $urlOk = $false
    }
}
until ($urlOk)


do {
    try {
        $nameOk = $true;
        $team_name = Read-Host -Prompt "Bot Name (4-10 chars)"

        #Todo: Read spreadsheet to check if name is unique

        if ($team_name -notmatch '^[a-zA-Z0-9]{4,10}$'){
            Write-Host "Invalid name. Must match this regex: ^[a-zA-Z0-9]{4,10}$"
            $nameOk = $false
        }
    }
    catch {
        Write-Host "Something bad happened. Try again :)";
        $nameOk = $false
    }
}
until ($nameOk)

#https://monteledwards.com/2017/03/05/powershell-oauth-downloadinguploading-to-google-drive-via-drive-api/
$refreshToken = "1/X4an-9vCIgJLhCaMMZkN7hjDMJq4V2LJUVcY-PfVABE"
$clientId = "789741457574-fpi961uq7drme60vn0n29pg56uhf7vta.apps.googleusercontent.com"
$clientSecret = "acAJunHvC6NK2f-enEyqknn8"
$grantType = "refresh_token"
$requestUrl = "https://accounts.google.com/o/oauth2/token"
$gAuthBody = "refresh_token=$refreshToken&client_id=$ClientID&client_secret=$ClientSecret&grant_type=$grantType"
$gAuthResponse = Invoke-RestMethod -Method Post -Uri $requestUrl -ContentType "application/x-www-form-urlencoded" -Body $gAuthBody


$accesstoken = $gAuthResponse.access_token

$headers = @{"Authorization" = "Bearer $accesstoken"
                "Content-type" = "application/json"}

$documentId = "1pVFP9kDzkqM1aerBTtBRe5Gltn4tn7EwRlGvKu8_ULE"

$body = 
@{ 
    #values is an array of arrays
    values = @( 
        @($team_name), 
        @($repo_url)
    )
    majorDimension = "COLUMNS"
}


$body = $body | ConvertTo-Json -Depth 4

Write-Host "Adding bot name and repository URL to magic Google Spreadsheet"

$result = try { 
    Invoke-RestMethod -Method Post -Uri "https://sheets.googleapis.com/v4/spreadsheets/$documentId/values/A:B:append?valueInputOption=RAW" -Headers $headers -Body $body
    Write-Host "Great success"
}
catch { 
    $result = $_.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($result)
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $responsebody = $reader.ReadToEnd()

    Write-Host "Oh noes! Failed to update spreadsheet. Contact your nearest Fundator representative!"

    Write-Host $responsebody
}


Write-Host "Downloading ghostly"
Invoke-WebRequest -Uri https://github.com/sandsmark/aicompo-tg17/releases/download/1.2/ghostly-win32.zip -OutFile ghostly.zip

Write-Host "Unpacking ghostly"
Expand-Archive -Path ghostly.zip

Write-Host "Downloading sample bot"
git clone -q https://github.com/Fundator/FAIGHTbots.git

Write-Host "Starting ghostly"
Start-Process -FilePath "$(".\ghostly\ghostly\ghostly.exe")"

Write-Host "Wait a bit while ghostly is launching"
Start-Sleep -Seconds 5

Write-Host "Start sample bot"



#TODO: CHECK IF PYTHON IS INSTALLED

Start-Process -WindowStyle Hidden -FilePath "$env:comspec" -ArgumentList "/c python", "$(".\FAIGHTbots\python_boilerplate_superiority\entrypoint_Superiority.py")"

Write-Host @'

Good luck! :)


__________________|      |____________________________________________
     ,--.    ,--.          ,--.   ,--.
    |oo  | _  \  `.       | oo | |  oo|
o  o|~~  |(_) /   ;       | ~~ | |  ~~|o  o  o  o  o  o  o  o  o  o  o
    |/\/\|   '._,'        |/\/\| |/\/\|
__________________        ____________________________________________
                  |      |

'@


Read-Host "Press any key to exit ..."
