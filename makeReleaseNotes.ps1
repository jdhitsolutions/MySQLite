Param(
    [string]$Path = 'ChangeLog.md',
    [string]$ModuleName = (Split-Path . -Leaf)
    )
$cd = Get-ChangelogData -path $path

$content = @"
# Release Notes

## $ModuleName $($cd.LastVersion)

$($cd.ReleaseNotes)

$( $cd.footer.split("`n")[1])
"@

$content | Set-Content -Path .\ReleaseNotes.md
Get-Item -Path .\ReleaseNotes.md