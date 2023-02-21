Function Get-MySQLiteTable {
    [cmdletbinding(DefaultParameterSetName = "file")]
    [Alias("gtb", "Get-DBTable")]
    [OutputType("PSCustomObject")]
    Param(
        [Parameter(
            Position = 0,
            Mandatory,
            HelpMessage = "Enter the path to the SQLite database file.",
            ValueFromPipelineByPropertyName, ParameterSetName = "file"
        )]
        [ValidateNotNullOrEmpty()]
        [alias("database", "fullname")]
        [string]$Path,
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            HelpMessage = "Specify an existing open database connection.",
            ParameterSetName = "connection"
        )]
        [System.Data.SQLite.SQLiteConnection]$Connection,
        [Parameter(
            HelpMessage = "Do not close the connection.",
            ParameterSetName = "connection"
        )]
        [switch]$KeepAlive,
        [switch]$Detail
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay)] $($MyInvocation.MyCommand)"
    } #begin

    Process {
        $iqParams = @{
            query = "Select Name from sqlite_master where type='table'"
        }
        if ($PSCmdlet.ParameterSetName -eq 'file') {
            $db = resolvedb -Path $path
            Write-Verbose "[$((Get-Date).TimeOfDay)] Using path $($db.Path)"
            if ($db.exists) {
                $iqParams.Add("Path", $db.path)
                $source = $db.path
            }
            else {
                Write-Warning "Failed to find $($db.path)"
            }
        } #if file parameter set
        else {
            Write-Verbose "[$((Get-Date).TimeOfDay)] Using connection $($connection.ConnectionString)"
            Write-Verbose "[$((Get-Date).TimeOfDay)] KeepAlive is $KeepAlive"
            $iqParams.Add("Connection", $Connection)
            $iqParams.Add("KeepAlive", $KeepAlive)
            #parse out the path from the connection
            $source = $connection.ConnectionString.split("=", 2)[1].split(";")[0]

        }
        $TableNames = Invoke-MySQLiteQuery @iqParams
        if ($TableNames) {

            if ($Detail) {
                Write-Verbose "[$((Get-Date).TimeOfDay)] Getting table details"
                foreach ($item in $TableNames.name) {
                    $iqParams.query = "PRAGMA table_info($item)"
                    Write-Verbose "[$((Get-Date).TimeOfDay)] $($iqparams.query)"
                    $details = Invoke-MySQLiteQuery @iqParams
                    foreach ($tbl in $details) {
                        [PSCustomObject]@{
                            PSTypename  = "MySQLiteTableDetail"
                            Source      = $Source
                            Table       = $item
                            ColumnIndex = $tbl.cid
                            ColumnName  = $tbl.name
                            ColumnType  = $tbl.type
                        }
                    } #foreach tbl
                } #foreach item
            }
            else {
                [PSCustomObject]@{
                    Source = $source
                    Name   = $TableNames.name
                }
            }
        }
        else {
            Write-Warning "No tables found in $source"
        }
    } #process

    End {
        if ($connection -AND (-Not $KeepAlive)) {
            closedb -connection $connection
        }

        Write-Verbose "[$((Get-Date).TimeOfDay)] Ending $($MyInvocation.MyCommand)"
    } #end
}
