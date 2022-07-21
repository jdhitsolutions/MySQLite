Function Close-MySQLiteDB {
    [cmdletbinding(SupportsShouldProcess)]
    [alias("Close-DB")]
    [OutputType("None", "System.Data.SQLite.SQLiteConnection")]

    Param(
        [Parameter(Mandatory, HelpMessage = "Enter a connection object", ValueFromPipeline)]
        [System.Data.SQLite.SQLiteConnection]$Connection,
        [switch]$Passthru
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay)] $($myinvocation.mycommand)"

    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeOfDay)] Closing source $($connection.DataSource)"
        if ($pscmdlet.ShouldProcess($Connection.DataSource)) {
            $connection.close()
            if ($passthru) {
                $connection
            }

            $connection.Dispose()
        }

    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeOfDay)] ending $($myinvocation.mycommand)"
    } #end

}
