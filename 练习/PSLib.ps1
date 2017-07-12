# 这个封装类库的测试方法
Function Factorial([int]$n){
    $total = 1
    for($i=1; $i -le $n; $i++){
        $total*=$i
    }
    return $total
}

#连接MySQL数据库
Function MySql_Conn([string]$username ,[string]$pwd ,[string]$severname){
    #$user = "root"
    $PWord = ConvertTo-SecureString -String $pwd -AsPlainText -Force
    $Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $username, $PWord
    #$dbCred =  Get-Credential -Credential root\123456 

    Connect-MySqlServer  -Credential $Credential -ComputerName '123.206.185.222' -Database workserverstaus
    Write-Output "数据库已经连接成功"
}

Function GetSerSorce(){
    # $memory=(Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory /1gb
    # return $memory
    $ops = Get-WmiObject -Class Win32_OperatingSystem
    "机器名：{0}" -f $ops.csname
    "可用内存（GB):{0}" -f ([math]::round(($ops.FreePhysicalMemory / (1mb))),2)

}


