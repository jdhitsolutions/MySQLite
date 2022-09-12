Function New-MySQLiteDB {
    [cmdletbinding(SupportsShouldProcess)]
    [alias("New-DB", "ndb")]
    [outputtype("None", "System.IO.Fileinfo")]
    Param(
        [Parameter(Position = 0, Mandatory, HelpMessage = "Enter the path to the SQLite database file.")]
        [ValidateNotNullOrEmpty()]
        [alias("database")]
        [string]$Path,
        [switch]$Force,
        [Parameter(HelpMessage = "Enter a comment to be inserted into the database's metadata table")]
        [string]$Comment,
        #write the database file to the pipeline
        [switch]$Passthru
    )

    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay)] $($myinvocation.mycommand)"

        $db = resolvedb $Path

        If (($db.exists) -AND (-not $Force)) {
            Write-Warning "The database file $path exists. Use -Force to overwrite the file."
            throw "The database file $path exists."
        }
        else {
            If (($db.exists) -AND $Force) {
                Write-Verbose "[$((Get-Date).TimeOfDay)] Removing $($db.path)"
                Remove-Item -Path $db.path
            }

            if ($pscmdlet.ShouldProcess($Path, "Open Database")) {
                $connection = opendb $db.path
            }

            #This data will be inserted into a new Metadata table
            $meta = @{
                Author   = "$([System.Environment]::UserDomainName)\$([System.Environment]::userName)"
                Created  = (Get-Date).ToString() #(Get-Date -format "yyyy-MM-dd hh:mm:ss.sss")
                Computer = [system.Environment]::machinename
                Comment  = $Comment
            }
        }
    } #begin
    Process {
        Write-Verbose "[$((Get-Date).TimeOfDay)] $($db.Path)"
        Write-Verbose "[$((Get-Date).TimeOfDay)] Adding Metadata table"
        if ($connection.state -eq 'Open' -OR $PSBoundparameters.ContainsKey("WhatIf")) {

            [string]$query = "CREATE TABLE Metadata (Author TEXT,Created TEXT,Computername TEXT,Comment TEXT);"

            if ($pscmdlet.ShouldProcess($query)) {
                $cmd = $connection.CreateCommand()
                $cmd.CommandText = $query
                [void]$cmd.ExecuteNonQuery()
            }

            $query = "Insert Into Metadata (Author,Created,Computername,Comment) Values ('$($meta.author)','$($meta.created)','$($meta.computer)','$($meta.comment)')"

            Write-Verbose "[$((Get-Date).TimeOfDay)] Execute non-query: $query"
            if ($pscmdlet.ShouldProcess($query)) {
                $cmd.CommandText = $query
                [void]$cmd.ExecuteNonQuery()
            }
        }
        else {
            Write-Verbose "[$((Get-Date).TimeOfDay)] There is no open database connection"
        }
    } #process
    End {
        if ($connection.state -eq 'Open') {
            Write-Verbose "[$((Get-Date).TimeOfDay)] Closing database connection"
            $connection.close()
            $connection.Dispose()
        }
        if ($Passthru -AND (Test-Path $db.path)) {
            Get-Item -Path $db.path
        }
        Write-Verbose "[$((Get-Date).TimeOfDay)] Ending $($myinvocation.mycommand)"

    } #end

}
