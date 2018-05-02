# netsh http show sslcert
# certutil -addstore my "C:\users\chiribest\desktop\i-CA-I-CA.cer"
# makecert.exe -n "CN=TudorCA" -r -sv TudorCA.pvk TudorCA.cer
# makecert.exe -sk TudorCASigned -iv TudorCA.pvk -n "CN=TudorCASigned" -ic TudorCA.cer TudorCASigned.cer -sr localmachine -ss MY
# netsh http add sslcert ipport=127.0.0.1:8443 certhash=de6483044f2a9325c4ce0083b897be1d0d83ae55 appid='{bc67e41a-4c00-40a1-95f5-fb1360eec107}'
# [guid]::NewGuid()

# Use the following commands to bind/unbind SSL cert
$version = [System.Environment]::OSVersion.Version.Major
#if($version -gt 6){
  #netsh http add sslcert hostnameport="localhost:8443" certhash="7494771BBD7F5287B18B1190E6A0CEFB00794DA4" appid='{811909a4-05f0-44cc-81e4-782854473183}' certstorename=my
#} else {
  # netsh http add sslcert ipport=127.0.0.1:8443 certhash=de6483044f2a9325c4ce0083b897be1d0d83ae55 appid='{bc67e41a-4c00-40a1-95f5-fb1360eec107}'
#}

netsh http add sslcert ipport=127.0.0.1:8443 certhash=de6483044f2a9325c4ce0083b897be1d0d83ae55 appid='{bc67e41a-4c00-40a1-95f5-fb1360eec107}'

# Only works for PowerShell 3+
Set-Location -Path $PSScriptRoot
$HttpListener = New-Object System.Net.HttpListener
if(-NOT $HttpListener.IsListening){
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