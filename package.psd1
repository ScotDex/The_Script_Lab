@{
    Root = 'c:\Users\Gillen\Proton Drive\gillenreid\My files\Work Files\Repos\Script-Library\syn-support-operational-scripts-main\syn-support-operational-scripts-main\Dev\ssl-script-dev.ps1'
    OutputPath = 'c:\Users\Gillen\Proton Drive\gillenreid\My files\Work Files\Repos\Script-Library\syn-support-operational-scripts-main\syn-support-operational-scripts-main\out'
    Package = @{
        Enabled = $true
        Obfuscate = $false
        HideConsoleWindow = $false
        DotNetVersion = 'v4.6.2'
        FileVersion = '1.0.0'
        FileDescription = ''
        ProductName = ''
        ProductVersion = ''
        Copyright = ''
        RequireElevation = $false
        ApplicationIconPath = ''
        PackageType = 'Console'
    }
    Bundle = @{
        Enabled = $true
        Modules = $true
        # IgnoredModules = @()
    }
}
        