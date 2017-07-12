do{
 try{
 [ValidatePattern('^server\d{1,4}$')]$Server = Read-Host "Enter a servername (serverXXX)"
 } catch{
 #Write-Host "输入不正确"
 }
}until($?)