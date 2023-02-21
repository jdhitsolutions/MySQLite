Function Open-MySQLiteDB {
    [cmdletbinding(SupportsShouldProcess)]
    [alias("Open-DB")]
    [OutputType("System.Data.SQLite.SQLiteConnection")]

    Param(
        [Parameter(Position=0,mMandatory)]
        [alias("database")]
        [ValidatePattern("\.((sqlite(3)?)|(db(3)?)|(sl3)|(s3db))$")]
        [string]$Path
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay)] $($MyInvocation.MyCommand)"
    } #begin

    Process {
        $db = resolvedb $Path
        if ($db.exists) {
            if ($PSCmdlet.ShouldProcess($db.path)) {
                Write-Verbose "[$((Get-Date).TimeOfDay)] Opening $Path"
                opendb $db.path
            }
        }
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeOfDay)] Ending $($MyInvocation.MyCommand)"
    } #end
}
