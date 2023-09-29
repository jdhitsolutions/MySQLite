Function Get-MySQLiteDB {
    [cmdletbinding()]
    [alias('Get-DB')]
    [OutputType('MySQLiteDB')]
    Param(
        [Parameter(
            Position = 0,
            Mandatory,
            HelpMessage = "Enter the path to the SQLite database file.",
            ValueFromPipelineByPropertyName
        )]
        [Alias("fullname", "database")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string]$Path
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay)] $($MyInvocation.MyCommand)"
    } #begin

    Process {
        $file = resolvedb -path $path

        If ($file.exists) {
            Write-Verbose "[$((Get-Date).TimeOfDay)] Opening $($file.path)"
            $ThisDB = Get-Item -Path $file.path

            $connection = opendb -Path $file.path

            $tables = Get-MySQLiteTable -Connection $connection -KeepAlive | Select-Object -ExpandProperty Name
            Write-Verbose "[$((Get-Date).TimeOfDay)] Found $($tables.count) Tables"

            $pgSize = (Invoke-MySQLiteQuery -Connection $connection -Query "PRAGMA page_size" -KeepAlive ).page_size
            $pgCount = (Invoke-MySQLiteQuery -Connection $connection -Query "PRAGMA page_count" -KeepAlive ).page_count
            $encoding = (Invoke-MySQLiteQuery -Connection $connection -Query "PRAGMA encoding" -KeepAlive).encoding

            #Get file size, even if using a reparse point
            if ($ThisDB.Attributes -match "reparsepoint") {
                Write-Verbose "[$((Get-Date).TimeOfDay)] Detected reparse point to $($ThisDB.target)"
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
                PSTypename    = "MySQLiteDB"
                DatabaseName  = $connection.Database
                Tables        = $tables
                PageSize      = $pgSize
                PageCount     = $pgCount
                Encoding      = $encoding
                FileName      = $ThisDB.name
                Path          = $File.path
                Size          = $size
                Created       = $creation
                Modified      = $LastWrite
                Age           = (Get-Date) - $LastWrite
                SQLiteVersion = $connection.ServerVersion
            }
        }
        else {
            Write-Warning "Cannot find the database file $path."
        }
    } #process

    End {
        if ($connection.open) {
            Write-Verbose "[$((Get-Date).TimeOfDay)] Closing database connection"
            closedb -connection $connection
        }
        Write-Verbose "[$((Get-Date).TimeOfDay)] Ending $($MyInvocation.MyCommand)"
    } #end
}
