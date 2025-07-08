Describe "api-auth-script" {
    It "creates the expected Authorization header" {
        Mock Invoke-RestMethod {}
        . "$PSScriptRoot/../API/api-auth-script.ps1"
        $expected = 'Basic MTIzIDk3IDEwMCAxMDkgMTA1IDExMCAxMjUgNTggMTIzIDExMiA5NyAxMTUgMTE1IDExOSAxMTEgMTE0IDEwMCAxMjU='
        $basicAuthHeader | Should -Be $expected
    }
}

