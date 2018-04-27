# Use the following commands to bind/unbind SSL cert
netsh http add sslcert hostnameport="localhost:8443" certhash="7494771BBD7F5287B18B1190E6A0CEFB00794DA4" appid='{811909a4-05f0-44cc-81e4-782854473183}' certstorename=my
# Only works for PowerShell 3+
Set-Location -Path $PSScriptRoot
$HttpListener = New-Object System.Net.HttpListener
if(-NOT $HttpListener.IsListening){
  $HttpListener.Prefixes.Add("http://localhost:8080/")
  $HttpListener.Prefixes.Add("https://localhost:8443/")
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
      $content = (GC ($PathToFile))    
      $ResponseBuffer = [Text.Encoding]::UTF8.GetBytes(($content)) 
      $HttpResponse.ContentLength64 = $ResponseBuffer.Length
      $HttpResponse.OutputStream.Write($ResponseBuffer,0,$ResponseBuffer.Length)
      $HttpResponse.Close()
      Write-Output "" # Newline
  }
  $HttpListener.Stop()
}
netsh http delete sslcert ipport="localhost:8443"