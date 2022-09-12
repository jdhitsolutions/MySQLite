Function Convert-MySQLiteByteArray {
    [cmdletbinding()]
    [Outputtype("Object")]
    Param(
        [Parameter(Position = 0, Mandatory,HelpMessage = "Specify the byte array from the blob property.")]
        [byte[]]$BlobProperty
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Processing $($BlobProperty).length bytes"
        if ($BlobProperty.count -gt 0) {
            Write-Verbose "[$((Get-Date).TimeOfDay)] Converting from bytes to object"
            $tmpFile = [system.io.path]::GetTempFileName()
            [text.encoding]::UTF8.getstring($BlobProperty) | Out-File -FilePath $tmpfile -Encoding utf8
            Import-Clixml -Path $tmpFile
            if (Test-Path $tmpfile) {
                Remove-Item $tmpFile
            }
        }
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    } #end

} #close Convert-MySQLiteByteArray