
$PSRoot = Join-Path  $PSScriptRoot function

# Import of all ps1 files
Get-ChildItem -Path $PSRoot -Filter *.ps1  | ForEach-Object {
    # Dot-source hver funktion for at indlæse den i den aktuelle session
    . $_.FullName
}