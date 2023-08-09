param(
    $apiKey,
    $apiBaseUrl,
    $localPath
)
$headers = @{
    "X-Api-Key" = $apiKey
}
$artistNames = Get-ChildItem $localPath | Select-Object -ExpandProperty Name
foreach ($artistName in $artistNames) {
    $Parameters = @{
        term = $artistName
    }
    $possibleArtists = Invoke-WebRequest -Uri "$apiBaseUrl/api/v1/artist/lookup" -Body $Parameters -Method Get -Headers $headers | ConvertFrom-Json -AsHashtable
    $topArtist = $possibleArtists |  Select-Object -First 1
    $topArtistName = $topArtist["artistName"]
    Write-Output "Adding artist $topArtistName for folder named $artistName"
    $scv = $null
    $topArtist["qualityProfileId"] = 1
    $topArtist["metadataProfileId"] = 1
    $topArtist["path"] = "/music/$artistName"
    $topArtist["rootFolderPath"] = "/music/"
    $addArtistResponse = Invoke-RestMethod -SkipHttpErrorCheck -StatusCodeVariable "scv" -Method 'Post' -Uri  "$apiBaseUrl/api/v1/artist" -Headers $headers -Body ($topArtist | ConvertTo-Json) -ContentType "application/json"
    if ($scv -ge 200 && $scv -le 299) {
        Write-Output "Artist $topArtistName was added successfully`n"
    }
    else {
        if ($addArtistResponse.errorCode -eq "ArtistExistsValidator") {
            Write-Output "Artist $topArtistName already exists`n"
        }
        else {
            Write-Output "Error when adding artist $topArtistName : $addArtistResponse`n" 
        }
        
    }
}
