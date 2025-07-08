<#
.SYNOPSIS
    Simulates periodic key presses in Windows, specifically designed for automating tasks such as D-scan in Eve Online.

.DESCRIPTION
    This script loads the necessary Windows Forms assembly and defines a function, Press-Key, which uses the Windows API to simulate keyboard key presses. 
    The script then enters an infinite loop, pressing the 'V' key every 10 seconds. This can be useful for automating repetitive key press actions in applications or games.

.FUNCTIONS
    Press-Key
        Simulates a key press and release event for a specified key using the Windows API.

.PARAMETER key
    The key to be pressed, specified as a [System.Windows.Forms.Keys] enumeration value.

.EXAMPLE
    Press-Key -key ([System.Windows.Forms.Keys]::V)
    # Simulates pressing and releasing the 'V' key.

.NOTES
    - Requires Windows OS.
    - Running this script may interfere with other applications by sending simulated key presses.
    - Use responsibly and in accordance with the terms of service of any software being automated.

.AUTHOR
    (Your Name Here)
#>
# Load the required assembly
Add-Type -AssemblyName System.Windows.Forms

# Function to simulate key press
function Invoke-KeyPress {
    param (
        [Parameter(Mandatory = $true)]
        [System.Windows.Forms.Keys]$key
    )

    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class Keyboard {
        [DllImport("user32.dll", CharSet = CharSet.Auto, ExactSpelling = true)]
        public static extern void keybd_event(byte bVk, byte bScan, int dwFlags, int dwExtraInfo);
    }
"@

    # Define key down and key up event constants
    $KEYEVENTF_KEYDOWN = 0x0000
    $KEYEVENTF_KEYUP = 0x0002

    # Press key down
    [Keyboard]::keybd_event([byte]$key, 0, $KEYEVENTF_KEYDOWN, 0)
    # Release key up
    [Keyboard]::keybd_event([byte]$key, 0, $KEYEVENTF_KEYUP, 0)
}

# Example of pressing the 'V' key every 10 seconds
while ($true) {
    Invoke-KeyPress -key ([System.Windows.Forms.Keys]::V)
    Start-Sleep -Seconds 10
}

