## 判断网络状态是不正常
## 获取一个服务的状态，并判断当前状态，如果关闭，则开启。
## 获取应用的网站是否正常。HTTP状态码进行判断
## 邮件发送到menpengpeng@qq.com上
## 2017-06-26 menpengpeng

#检测网络连接
Function Net-Status([string]$IP){
   $netstatus = Test-NetConnection $IP | Select-Object -Property PingSucceeded
   return $netstatus
}
#获取应用的HTTP访问状态码
Function Detect-HttpStatusCode ([uri]$Url)
{
    trap [Net.WebException]
    {
        if($_.Exception.Response -eq $null)
        {
            return 100
        }
        return [int]($_.Exception.Response.StatusCode)
    }
    return (Invoke-WebRequest $Url ).StatusCode
}
#获取TomCat服务的状态
Function Get-TomCatSeverStatus([string]$Displayname){
    $seriverstatus = Get-Service -Name "$Displayname" | Select-Object -Property Status
    return $seriverstatus
}
$statusCode = Detect-HttpStatusCode('http://www.baidu.com')
$statusCode
$statusCode.GetType()
Net-Status('localhost')
$a = Get-TomCatSeverStatus('MySQL')
$a
$a.GetType()