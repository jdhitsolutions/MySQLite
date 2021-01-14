
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
Add-Type -Path "$PSScriptRoot\assembly\System.Data.SQLite.dll"

Get-ChildItem -Path $psscriptroot\functions\*.ps1 |
ForEach-Object {
    . $_.fullname
}
