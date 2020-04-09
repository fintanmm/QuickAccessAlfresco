function Append-ToLog($aMessage) {
    # try {
    #     New-EventLog –LogName Application –Source "QuickAccessAlfresco"
    # }
    # catch {
    #     Out-String "Can't create to log event source"
    # }
    Write-EventLog -LogName "Application" -Source "QuickAccessAlfresco" -EventID 1 -EntryType Information -Message $aMessage
    return $aMessage
}