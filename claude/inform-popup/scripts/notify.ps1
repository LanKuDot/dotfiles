param(
    [string]$Title = 'Claude Code',
    [string]$Message = 'Default message'
)

Import-Module BurntToast

$dllPath = Join-Path $PSScriptRoot 'Win32Focus.dll'
if (-not (Test-Path $dllPath)) {
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32Focus {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")]
    public static extern bool IsZoomed(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern bool IsIconic(IntPtr hWnd);
}
"@ -OutputAssembly $dllPath
}
Add-Type -Path $dllPath -ErrorAction SilentlyContinue

# Walk up the process tree to find the ancestor window (Rider, VS Code, Terminal, etc.)
$hwnd = [IntPtr]::Zero
$wasMaximized = $false
$proc = Get-Process -Id $PID -ErrorAction SilentlyContinue
while ($proc) {
    if ($proc.MainWindowHandle -ne [IntPtr]::Zero) {
        $hwnd = $proc.MainWindowHandle
        $wasMaximized = [Win32Focus]::IsZoomed($hwnd)
        break
    }
    $parentId = (Get-CimInstance Win32_Process -Filter "ProcessId=$($proc.Id)" -ErrorAction SilentlyContinue).ParentProcessId
    if (-not $parentId) { break }
    $proc = Get-Process -Id $parentId -ErrorAction SilentlyContinue
}

$logoPath = Join-Path $PSScriptRoot 'claude-logo-color.png'

New-BurntToastNotification -Text $Title, $Message -AppLogo $logoPath -ExpirationTime (Get-Date).AddSeconds(5) -ActivatedAction {
    if ($hwnd -and $hwnd -ne [IntPtr]::Zero) {
        if ([Win32Focus]::IsIconic($hwnd)) {
            # Window is minimized - restore to maximized or normal based on previous state
            if ($wasMaximized) {
                [Win32Focus]::ShowWindow($hwnd, 3)  # SW_MAXIMIZE
            } else {
                [Win32Focus]::ShowWindow($hwnd, 9)  # SW_RESTORE
            }
        }
        [Win32Focus]::SetForegroundWindow($hwnd)
    }
}

Wait-Event -Timeout 30 | Out-Null