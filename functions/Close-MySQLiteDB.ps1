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
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Starting $($MyInvocation.MyCommand)"
        if ($MyInvocation.CommandOrigin -eq 'Runspace') {
            #Hide this metadata when the command is called from another command
            Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Running under PowerShell version $($PSVersionTable.PSVersion)"
            Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Detected culture $(Get-Culture)"
        }
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Closing source $($connection.DataSource)"
        if ($PSCmdlet.ShouldProcess($Connection.DataSource)) {
            $connection.close()
            if ($PassThru) {
                $connection
            }

            $connection.Dispose()
        }
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Ending $($MyInvocation.MyCommand)"
    } #end
}
