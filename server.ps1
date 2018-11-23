Write-Host "PRESS ENTER TO BYPASS PASSWORD... DO NOT CLOSE THE PROMPT AFTER CERT IS ADDED"

CERTUTIL -f -importpfx ".\certificates\qaaCert.pfx"

netsh http del sslcert 127.0.0.1:8443

$generateID = "{" + [guid]::NewGuid() + "}"

# Use the following commands to bind/unbind SSL cert
netsh http add sslcert ipport=127.0.0.1:8443 certhash=f77737e7866aa384e3f350f65c7df00c2d724f27 appid=$generateID certstorename=my

# Only works for PowerShell 3+
Set-Location -Path $PSScriptRoot
$HttpListener = New-Object System.Net.HttpListener
if(!$HttpListener.IsListening){
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
