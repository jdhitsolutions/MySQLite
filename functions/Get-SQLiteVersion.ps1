Function Get-SQLiteVersion {
    [cmdletbinding()]
    [OutputType('SQLiteVersionInfo')]
    [alias('alias')]
    Param( )

    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Starting $($MyInvocation.MyCommand)"
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Running under PowerShell version $($PSVersionTable.PSVersion)"

    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Getting SQLite version information"
        $SQLiteVersion = [System.Reflection.Assembly]::GetAssembly([System.Data.Sqlite.SqLiteConnection]).GetName().version
        $assembly = ([System.AppDomain]::CurrentDomain.GetAssemblies()).Where({$_.ManifestModule.Name -eq 'System.Data.Sqlite.dll'})
        [PSCustomObject]@{
            PSTypeName = 'SQLiteVersionInfo'
            Version = ($assembly.FullName -split ",")[1].trim().split("=")[1] -as [version]
            RunTimeVersion = $assembly.ImageRunTimeVersion
            PSVersion = $PSVersionTable.PSVersion
            Location = $assembly.Location
        }
    } #process

    End {

        Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Ending $($MyInvocation.MyCommand)"
    } #end

} #close Get-SQLiteVersion