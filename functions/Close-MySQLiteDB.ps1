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
        Write-Verbose "[$((Get-Date).TimeOfDay)] Running under PowerShell version $($PSVersionTable.PSVersion)"
        Write-Verbose "[$((Get-Date).TimeOfDay)] Detected culture $(Get-Culture)"
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
