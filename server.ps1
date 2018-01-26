$Hso = New-Object Net.HttpListener
$Hso.Prefixes.Add("http://localhost:8080/")
$Hso.Start()
While ($Hso.IsListening) {
    $HC = $Hso.GetContext()
    $HRes = $HC.Response
    $HRes.Headers.Add("Content-Type","application/jsonn")
    $Buf = [Text.Encoding]::UTF8.GetBytes((GC (Join-Path $Pwd ($HC.Request).RawUrl)))
    $HRes.ContentLength64 = $Buf.Length
    $HRes.OutputStream.Write($Buf,0,$Buf.Length)
    $HRes.Close()
}
$Hso.Stop()
