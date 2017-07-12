Function Search-Position{
param(
[string]$keyword,
[string]$city)
$url="http://sou.zhaopin.com/jobs/searchresult.ashx?jl=$city&kw=$keyword&p=1&isadv=0"
$page=Invoke-RestMethod $url
 
$AverageSalary = [regex]::Matches($page,'zwyx">(?<salary>.*)</td>') |
foreach {
    $salary = $_.Groups['salary'].Value
    if($salary -ne '面议'){
    Write-Debug $salary
    ($salary -split '-' | measure -Average ).Average
    }
} | measure -Average | select -ExpandProperty Average
 
$positonCount = [regex]::Match($page,'共<em>(?<positons>.*)</em>个职位满足条件').Groups['positons'].Value
@{
PositonsCount=$positonCount
AverageSalary=$AverageSalary
}
}
 
'上海','杭州','南京','苏州','南昌','西安' | ForEach-Object{
 
$s= Search-Position -keyword '运维工程师' -city $_
[PSCustomObject]@{
城市=$_
职位个数=$s.PositonsCount
平均市场薪资=[int]$s.AverageSalary
}
} | Format-Table