Function Open-MySQLiteDB {
    [cmdletbinding(SupportsShouldProcess)]
    [alias("Open-DB")]
    [OutputType("System.Data.SQLite.SQLiteConnection")]

    Param(
        [Parameter(Mandatory)]
        [alias("database")]
        [string]$Path
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay)] $($myinvocation.mycommand)"
    } #begin

    Process {
        $db = resolvedb $Path
        if ($db.exists) {
            if ($pscmdlet.shouldprocess($db.path)) {
                Write-Verbose "[$((Get-Date).TimeOfDay)] Opening $Path"
                opendb $db.path
            }
        }

    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeOfDay)] Ending $($myinvocation.mycommand)"
    } #end

}
