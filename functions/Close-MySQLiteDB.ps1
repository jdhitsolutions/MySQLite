Function Close-MySQLiteDB {
    [cmdletbinding(SupportsShouldProcess)]
    [alias("Close-DB")]
    [OutputType("None", "System.Data.SQLite.SQLiteConnection")]

    Param(
        [Parameter(
            Mandatory,
            HelpMessage = "Enter a connection object",
            ValueFromPipeline
        )]
        [ValidateNotNullOrEmpty()]
        [System.Data.SQLite.SQLiteConnection]$Connection,
        [switch]$PassThru
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay)] $($MyInvocation.MyCommand)"
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeOfDay)] Closing source $($connection.DataSource)"
        if ($PSCmdlet.ShouldProcess($Connection.DataSource)) {
            $connection.close()
            if ($PassThru) {
                $connection
            }

            $connection.Dispose()
        }
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeOfDay)] ending $($MyInvocation.MyCommand)"
    } #end
}
