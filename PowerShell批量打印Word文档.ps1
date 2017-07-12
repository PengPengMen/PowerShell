#$home="C:\Users\menpengpeng\Desktop\文档"
#Get-ChildItem -Path $home -Filter *.doc* -Recurse |
#ForEach-Object{
#  Start-Process -FilePath $_.FullName -Verb Print -Wait
#}


$docpath = 'C:\Users\menpengpeng\Desktop\文档\冯果.doc'
$pdfPath = 'C:\Users\menpengpeng\Desktop\文档\冯果.pdf'
## $wordApp = New-Object -ComObject word.Application

# $document = $wordApp.Documents.Open($docpath)
#$document.SaveAs([ref] $pdfPath,[ref] 17)
#$wordApp.Quit()


Function WordToPdf([string]$Docpath, [string]$pdfPath){
     Write-Host $Docpath
     Write-Host $pdfPath
}

WordToPdf($docpath,$pdfPath)

