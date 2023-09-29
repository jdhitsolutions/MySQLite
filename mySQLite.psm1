if ($IsLinux -OR $IsMacOS) {
    Write-Warning "The module is unsupported on this platform. See https://github.com/jdhitsolutions/mysqlite/issues/21 for how you can help."
    Return
}
#borrowing some code from https://github.com/TobiasPSP/ReallySimpleDatabase/blob/main/Modules/ReallySimpleDatabase/loadbinaries.ps1

$code = @'
[DllImport("kernel32.dll")]
public static extern IntPtr LoadLibrary(string dllToLoad);
[DllImport("kernel32.dll")]
public static extern bool FreeLibrary(IntPtr hModule);
'@

Add-Type -MemberDefinition $code -Namespace Internal -Name Helper

# pre-load the platform specific DLL version
$Path = "$PSScriptRoot\assembly\SQLite.Interop.dll"
[void]([Internal.Helper]::LoadLibrary($Path))

# next, load the .NET assembly. Since the Interop DLL is already
# pre-loaded, all is good:
if ($PSEdition -eq 'Desktop' ) {
    Add-Type -Path "$PSScriptRoot\assembly\net46\System.Data.SQLite.dll"
}
elseif ($IsWindows) {
    Add-Type -Path "$PSScriptRoot\assembly\net20\System.Data.SQLite.dll"
}
Else {
    #this should never get called
    Write-Warning "This is an unsupported platform."
}

Get-ChildItem -Path $PSScriptRoot\functions\*.ps1 |
ForEach-Object {
    . $_.FullName
}

#define a regex pattern to match database file extensions
#[regex]$rxExtension = "\.((sqlite(3)?)|(db(3)?)|(sl3)|(s3db))$"