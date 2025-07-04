Function Get-SQLiteVersion {
    [cmdletbinding()]
    [OutputType('SQLiteVersionInfo')]
    [alias('alias')]
    Param( )

    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Starting $($MyInvocation.MyCommand)"
        if ($MyInvocation.CommandOrigin -eq 'Runspace') {
            #Hide this metadata when the command is called from another command
            Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Running under PowerShell version $($PSVersionTable.PSVersion)"
            Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Detected culture $(Get-Culture)"
        }
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Getting SQLite version information"
        $SQLiteVersion = [System.Reflection.Assembly]::GetAssembly([System.Data.Sqlite.SqLiteConnection]).GetName().version
        $assembly = ([System.AppDomain]::CurrentDomain.GetAssemblies()).Where({$_.ManifestModule.Name -eq 'System.Data.Sqlite.dll'})
        if ($PSVersionTable.OS) {
            $OS = $PSVersionTable.OS
        }
        else {
            $OS = "Microsoft Windows $($PSVersion.Table.BuildVersion)"
        }
        [PSCustomObject]@{
            PSTypeName = 'SQLiteVersionInfo'
            Version = ($assembly.FullName -split ",")[1].trim().split("=")[1] -as [version]
            RunTimeVersion = $assembly.ImageRunTimeVersion
            PSVersion = $PSVersionTable.PSVersion
            OS = $OS
            Location = $assembly.Location
        }
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Ending $($MyInvocation.MyCommand)"
    } #end

} #close Get-SQLiteVersion