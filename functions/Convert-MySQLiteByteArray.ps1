# the updated version from @SeSeKenny to use the new serialization private functions
Function Convert-MySQLiteByteArray {
    [cmdletbinding()]
    [OutputType("Object")]
    Param(
        [Parameter(
            Position = 0,
            Mandatory,
            HelpMessage = "Specify the byte array from the blob property."
        )]
        [byte[]]$BlobProperty
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($MyInvocation.MyCommand)"
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Processing $($BlobProperty).length bytes"
        if ($BlobProperty.count -gt 0) {
            Write-Verbose "[$((Get-Date).TimeOfDay)] Converting from bytes to object"
            [text.encoding]::UTF8.GetString($BlobProperty) | ConvertFrom-CliXml
        }
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($MyInvocation.MyCommand)"
    } #end

} #close Convert-MySQLiteByteArray

