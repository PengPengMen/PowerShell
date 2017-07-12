## 这个一个监控服务器状态的模板脚本
## 2017/7/10 门鹏鹏 
## 主要功能:
## 1:监控服务器的连通状态，正常，返回OK，错误，返回异常提醒
## 2:监控指定服务状态，正常，正常标识，错误，异常提醒
## 3:监控磁盘空，并低于指定数值进行提醒
## 4:邮件提醒
## 5:监测应用是否可以正常访问

##$computerName = @("192.168.34.184","192.168.34.216")

## 监控服务器的连通状态
Function GetPCStatic([string]$computerName){
  $computerName| %{
    if(!(Test-Connection -ComputerName $_ -Quiet)){
        cmd /c msg *($_)连接出现异常
    }else{
         cmd /c msg *($_)连接正常
    }
  }
}

## 监控指定服务状态
Function GetServiceStatus([string]$DisplayName){
   if($seriverstatus = Get-Service -Name "$Displayname" | where Status -EQ Running ){
      return "服务正在运行中..."
    }
    else {
      return "该服务已经停止...!!!"
    }
}

##监控磁盘空间
Function GetDiskStatus{
$Disks =  Get-WmiObject win32_logicaldisk  |  Where-Object {$_.drivetype -eq 3}
$Diskemailsubject = $ipv4 +"服务器磁盘使用率过高通知"
foreach ($Disk in $Disks) {
    $diskid = $Disk | Select-Object -Property DeviceID | Out-String
    #$diskid = $diskid.Trim(" .-`t`n`r")
    #Write-Host $diskid
    $Size = $Disk.Size 
    $FreeSpace = $Disk.FreeSpace 
    $FreePercent =[Math]::Round( (($FreeSpace /$Size) * 100) , 3)
    #Write-Host $Disk.deviceid $Disk.volumename"盘总空间: $Size"  
    #Write-Host $Disk.deviceid $Disk.volumename"空闲空间: $FreeSpace" 
    #Write-Host $Disk.deviceid $Disk.volumename"使用空间:  $SpaceUsed" 
    #Write-Host $Disk.deviceid $Disk.volumename"剩余百分比:  $FreePercent "  
    if ($FreePercent -lt 10){
      $contentdisk= $Disk.deviceid+ $Disk.volumename+" 盘可用空间不足10%"
      Send-mailTest($contentdisk)
    }

}
}

#发送邮件通知函数
Function Send-mailTest([string]$bodycontent){
   
     $From = "menpengpeng@163.com"
     $To = "liuxj@dpark.com.cn"
     $Subject = "监控服务器状态异常通知" 
     $Body = $bodycontent
     $smtpServer = "smtp.163.com"
     $smtpPort = 25
     $username = "menpengpeng"
     $password = "*******"

     $SMTPMessage = New-Object System.Net.Mail.MailMessage($From, $To, $Subject, $Body)
     $SMTPClient = New-Object Net.Mail.SmtpClient($smtpServer, $SmtpPort) 
     $SMTPClient.EnableSsl = $false 
     $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($username, $password); 
     $SMTPClient.Send($SMTPMessage)
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
