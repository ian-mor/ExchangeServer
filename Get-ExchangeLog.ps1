function Get-ExchangeLog {

    <#
    .SYNOPSIS
    Get Exchange Server log data.  
    Uses field data defined in log comments to dynamically assign column names. 
    Skips all comment rows to return clean data.

    .DESCRIPTION
    2023-01-31
    ian mor
    
    .EXAMPLE
    Get-ExchangeLog -logPath "C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\FrontEnd\ProtocolLog\SmtpReceive\RECV2023020100-1.LOG"
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$logPath
    )

    # Guard clause to verify access to log
    If (-not (Test-Path $logPath)) {
        Write-Error "Unable to access $logPath"
        Return $null
    }

    $logData = Get-Content $logPath

    $rowsToSkip = 0
    
    # Count Number of comment rows at beginning
    Foreach ($row in $logData) {
        If ($row -like "#*"){
            $rowsToSkip += 1
        }Else{
            Break
        }
    }

    # Get headers out of log comments
    $fieldCommentLine = $logData | Where-Object {$_ -like "#Fields*"}

    If ($null -ne $fieldCommentLine) {
        
        $logHeaders = ($fieldCommentLine).Split(':')[1].Trim().Split(',')
        
        # Skip comment rows at beginning of log and "import" csv data with headers
        $logs = $logData | Select-Object -Skip $rowsToSkip | ConvertFrom-Csv -Header $logHeaders

    }Else{
        # Unable to determine fields - try to convert anyways
        $logs = $logData | Select-Object -Skip $rowsToSkip | ConvertFrom-Csv
    }

    Return $logs
}

