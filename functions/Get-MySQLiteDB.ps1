Function Get-MySQLiteDB {
    [cmdletbinding()]
    [alias('Get-DB')]
    [OutputType('MySQLiteDB')]
    Param(
        [Parameter(
            Position = 0,
            Mandatory,
            HelpMessage = 'Enter the path to the SQLite database file.',
            ValueFromPipelineByPropertyName
        )]
        [Alias('fullname', 'database')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string]$Path
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
        $file = resolvedb -path $path

        If ($file.exists) {
            Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Opening $($file.path)"
            $ThisDB = Get-Item -Path $file.path

            $connection = opendb -Path $file.path
            $dbName = $connection.Database
            $serverVersion = $connection.ServerVersion
            $lastInsertRow = $connection.LastInsertRowId
            $memUsed = $connection.MemoryUsed

            $tables = Get-MySQLiteTable -Connection $connection -KeepAlive | Select-Object -ExpandProperty Name
            Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Found $($tables.count) Tables"

            Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Getting database page size, page count, and encoding"
            # 30 May 2025 Combined these queries into a single call
            #$pgSize = (Invoke-MySQLiteQuery -Connection $connection -Query 'PRAGMA page_size' -KeepAlive ).page_size
            #$pgCount = (Invoke-MySQLiteQuery -Connection $connection -Query 'PRAGMA page_count' -KeepAlive ).page_count
            #$encoding = (Invoke-MySQLiteQuery -Connection $connection -Query 'PRAGMA encoding' -KeepAlive).encoding
            $dbInfo = Invoke-MySQLiteQuery -Query 'select * from pragma_page_count,pragma_page_size,pragma_encoding' -Connection $connection

            #Get file size, even if using a reparse point
            #if ($ThisDB.Attributes -match 'ReparsePoint') {
            # 30 May 2025 Testing for Target property instead of Attributes to
            # handle OneDrive Issue #27
            If ($thisDB.Target) {
                Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Detected reparse point to $($ThisDB.target)"
                # 1 May 2025 JH reparse point might now resolve to ResolvedTarget
                $target = (Get-Item -Path $ThisDB.Target)
                $size = $target.length
                $creation = $target.CreationTime
                $LastWrite = $target.LastWriteTime
            }
            else {
                $size = $ThisDB.length
                $creation = $ThisDB.CreationTime
                $LastWrite = $ThisDB.LastWriteTime
            }
            [PSCustomObject]@{
                PSTypename      = 'MySQLiteDB'
                DatabaseName    = $dbName
                Tables          = $tables
                PageSize        = $dbInfo.page_size
                PageCount       = $dbInfo.page_count
                LastInsertRowID = $lastInsertRow
                Encoding        = $dbInfo.encoding
                FileName        = $ThisDB.name
                Path            = $File.path
                Size            = $size
                MemoryUsed      = $memUsed
                Created         = $creation
                Modified        = $LastWrite
                Age             = (Get-Date) - $LastWrite
                SQLiteVersion   = $serverVersion
            }
        }
        else {
            Write-Warning "Cannot find the database file $path."
        }
    } #process

    End {
        if ($connection.open) {
            Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Closing database connection"
            closedb -connection $connection
        }
        Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Ending $($MyInvocation.MyCommand)"
    } #end
}
