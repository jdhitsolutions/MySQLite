Function Get-MySQLiteDB {
    [cmdletbinding()]
    [alias('Get-DB')]
    [OutputType('MySQLiteDB')]
    Param(
        [Parameter(Position = 0, Mandatory, HelpMessage = "Enter the path to the SQLite database file.", ValueFromPipelineByPropertyName)]
        [Alias("fullname", "database")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path $_})]
        [string]$Path
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay)] $($myinvocation.mycommand)"
    } #begin

    Process {

        $file = resolvedb -path $path

        If ($file.exists) {
            Write-Verbose "[$((Get-Date).TimeOfDay)] Opening $($file.path)"
            $thisdb = Get-Item -Path $file.path

            $connection = opendb -Path $file.path

            $tables = Get-MySQLiteTable -Connection $connection -KeepAlive | Select-Object -ExpandProperty Name
            Write-Verbose "[$((Get-Date).TimeOfDay)] Found $($tables.count) Tables"

            $pgsize = (Invoke-MySQLiteQuery -Connection $connection -Query "PRAGMA page_size" -KeepAlive ).page_size
            $pgcount = (Invoke-MySQLiteQuery -Connection $connection -Query "PRAGMA page_count" -KeepAlive ).page_count
            $encoding = (Invoke-MySQLiteQuery -Connection $connection -Query "PRAGMA encoding" -KeepAlive).encoding

            #Get file size, even if using a reparse point
            if ($thisdb.Attributes -match "reparsepoint") {
                Write-Verbose "[$((Get-Date).TimeOfDay)] Detected reparse point to $($thisdb.target)"
                $target = (Get-Item -Path $thisdb.Target)
                $size = $target.length
                $creation = $target.CreationTime
                $lastwrite = $target.LastWriteTime
            }
            else {
                $size = $thisdb.length
                $creation -= $thisdb.CreationTime
                $lastwrite = $thisdb.LastWriteTime
            }
            [pscustomobject]@{
                PSTypename    = "MySQLiteDB"
                DatabaseName  = $connection.Database
                Tables        = $tables
                PageSize      = $pgsize
                PageCount     = $pgcount
                Encoding      = $encoding
                FileName      = $thisdb.name
                Path          = $File.path
                Size          = $size
                Created       = $creation
                Modified      = $lastwrite
                Age           = (Get-Date) - $lastwrite
                SQLiteVersion = $connection.serverversion
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
        Write-Verbose "[$((Get-Date).TimeOfDay)] Ending $($myinvocation.mycommand)"
    } #end

}
