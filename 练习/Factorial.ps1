param(
#[int] $n = $(throw "请输入一个正整数"),
[string]$username,
[string]$pwd,
[string]$servername
)
I:\文档资料\知识库\工具脚本\练习\PSLib.ps1
#$servername = Read-Host "请输入数据库服务器的IP地址:"
#$username = Read-Host "请输入Mysql数据库用户名:"
#$pwd = Read-Host "请输入Mysql数据库密码:" -AsSecureString

#MySql_Conn($username,$pwd,$servername)
Function GetSerSorce(){
    # $memory=(Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory /1gb
    # return $memory
    $ops = Get-WmiObject -Class Win32_OperatingSystem
    "机器名：{0}" -f $ops.csname
    "可用内存（GB):{0}" -f ([math]::round(($ops.FreePhysicalMemory / (1mb))),2)

}
GetSerSorce