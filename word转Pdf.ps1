param (
 #[string]$source = $(Throw "Need a directory or file"))
 [string]$source = "C:\Users\menpengpeng\Desktop\文档")
$word = new-object -ComObject "word.application"
$formatPDF = 17
$total = 0
$failed = @{}
foreach ($f in (ls -Recurse $source *.doc*)) {
$source = $f.fullname
$extensionSize = 3
if ($source.EndsWith("docx")) {
$extensionSize = 4
}
try {
$destiny = $source.Substring(0, $source.Length - $extensionSize) + "pdf"
                $saveaspath = $destiny
$doc = $word.documents.open($source)
$doc.SaveAs($saveaspath, $formatPDF)
$doc.Close()
echo "Converted file: $source"
$total += 1
}catch{
$failed.Add("$source","$_");//fileName=errorMessage
}
}
ps winword | kill

echo "Done, converted $total files."
if ($failed.Count -gt 0) {
$colors = @{foreground="red";}  
Write-Host @colors "But there are $($failed.Count) files faield to converted:"
        foreach ($fn in $failed.keys) {
Write-Host @colors "$($fn)"
}
#$failed | Format-List #list files and error messages.
}