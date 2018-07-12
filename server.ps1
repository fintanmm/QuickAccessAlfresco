# Use the following commands to bind/unbind SSL cert
netsh http add sslcert ipport=127.0.0.1:8443 certhash=2e3dd97430ee7d4b75585de29c447ff51c91aaf4 appid='{bc67e41a-4c00-40a1-95f5-fb1360eec107}' certstorename=my
#netsh http delete sslcert ipport="localhost:8443"

# Only works for PowerShell 3+
Set-Location -Path $PSScriptRoot
$HttpListener = New-Object System.Net.HttpListener
if(-NOT $HttpListener.IsListening) {
  $HttpListener.Prefixes.Add("http://127.0.0.1:8080/")
  $HttpListener.Prefixes.Add("https://127.0.0.1:8443/")
  $HttpListener.Start()
  While ($HttpListener.IsListening) {
      $HttpContext = $HttpListener.GetContext()
      $HttpRequest = $HttpContext.Request
      $RequestUrl = $HttpRequest.Url.OriginalString
      Write-Host "$RequestUrl"
      if($HttpRequest.HasEntityBody) {
        $Reader = New-Object System.IO.StreamReader($HttpRequest.InputStream)
        Write-Output $Reader.ReadToEnd()
      }
      $HttpResponse = $HttpContext.Response
      $HttpResponse.Headers.Add("Content-Type","application/json")
      $HttpResponse.StatusCode = 200
      $PathToFile = Join-Path $Pwd ($HttpRequest).RawUrl
      Write-Host "$PathToFile"
      $content = (Get-Content ($PathToFile))
      $ResponseBuffer = [Text.Encoding]::UTF8.GetBytes(($content)) 
      $HttpResponse.ContentLength64 = $ResponseBuffer.Length
      $HttpResponse.OutputStream.Write($ResponseBuffer,0,$ResponseBuffer.Length)
      $HttpResponse.Close()
      Write-Output "" # Newline
  }
  $HttpListener.Stop()
}
