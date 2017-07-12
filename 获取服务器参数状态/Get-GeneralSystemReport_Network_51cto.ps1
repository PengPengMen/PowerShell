

#region Parameters



[CmdletBinding()]
param
(
	[Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
	[AllowEmptyString()]
	[Alias('Server Name')]
	$ServerName=(Get-Content ".\serverlist.txt"),				
	[Parameter(Position=1,Mandatory=$false,ValueFromPipeline=$false,ValueFromPipelineByPropertyName=$true)]
	[Alias('Email Relay')]
	[String]$EmailRelay = "mail.szmaxcent.com",		
	[Parameter(Position=2,Mandatory=$false,ValueFromPipeline=$false,ValueFromPipelineByPropertyName=$true)]
	[Alias('Email Sender')]
	[String]$EmailSender='johnson.xiang@szmaxcent.com',
	[Parameter(Position=3,Mandatory=$false,ValueFromPipeline=$false,ValueFromPipelineByPropertyName=$true)]
	[Alias('Email Recipient')]
	[String]$EmailRecipient='13047615@qq.com',
	[Parameter(Position=4,Mandatory=$false,ValueFromPipeline=$false,ValueFromPipelineByPropertyName=$true)]
	[Alias('Send Mail')]
	[Bool]$SendMail=$false,
	[Parameter(Position=5,Mandatory=$false,ValueFromPipeline=$false,ValueFromPipelineByPropertyName=$true)]
	[Bool]$SaveReport=$true,
	[Parameter(Position=6,Mandatory=$false,ValueFromPipeline=$false,ValueFromPipelineByPropertyName=$true)]
	[String]$ReportName=".\$(get-date -format yyyyMMdd)-SystemStatus.html"
)
#endregion Parameters

#region Configuration
## Environment Specific - Change These ##
$EventNum = 3         # Number of events to fetch for system report
$ProccessNumToFetch = 10   # Number of processes to fetch for system report

## Required - Leave These Alone ##
# System and Error Report Headers
$HTMLHeader = @'
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Frameset//EN' 'http://www.w3.org/TR/html4/frameset.dtd'>
<html><head><title>我的系统报告</title>
<style type='text/css'>
<!--
body {
font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
}

    #report { width: 835px; }

    table{
   border-collapse: collapse;
   border: none;
   font: 10pt Verdana, Geneva, Arial, Helvetica, sans-serif;
   color: black;
   margin-bottom: 10px;
}
   table td{
   font-size: 12px;
   padding-left: 0px;
   padding-right: 20px;
   text-align: left;
}
   table th {
   font-size: 12px;
   font-weight: bold;
   padding-left: 0px;
   padding-right: 20px;
   text-align: left;
}

h2{ clear: both; font-size: 130%; }

h3{
   clear: both;
   font-size: 115%;
   margin-left: 20px;
   margin-top: 30px;
}

p{ margin-left: 20px; font-size: 12px; }

table.list{ float: left; }
   table.list td:nth-child(1){
   font-weight: bold;
   border-right: 1px grey solid;
   text-align: right;
}

table.list td:nth-child(2){ padding-left: 7px; }
table tr:nth-child(even) td:nth-child(even){ background: #CCCCCC; }
table tr:nth-child(odd) td:nth-child(odd){ background: #F2F2F2; }
table tr:nth-child(even) td:nth-child(odd){ background: #DDDDDD; }
table tr:nth-child(odd) td:nth-child(even){ background: #E5E5E5; }
div.column { width: 320px; float: left; }
div.first{ padding-right: 20px; border-right: 1px  grey solid; }
div.second{ margin-left: 30px; }
table{ margin-left: 20px; }
-->
</style>
</head>
<body>
'@

$HTMLEnd = @'
</div>
</body>
</html>
'@

# Date Format
$DateFormat      = Get-Date -Format "MM/dd/yyyy_HHmmss" 
#endregion Configuration

#region Help
<#
.SYNOPSIS
   Get-GeneralSystemReport.ps1
.DESCRIPTION

.PARAMETER
   <none>
.INPUTS
   <none>
.OUTPUTS
   <none>
.EXAMPLE
   Run stand alone
      Get-GeneralSystemReport.ps1
.LINK
   http://blogs.technet.com/b/exchange/archive/2011/01/18/3411844.aspx
#>
#endregion help

#region Functions
$computers = Get-Content ".\serverlist.txt";

foreach($computer in $computers)
{
Function Get-DriveSpace() 
{
   
   $Title="Drive Report"

   #define an array for html fragments
   $fragments=@()

   #get the drive data
   $data=get-wmiobject -Class Win32_logicaldisk -filter "drivetype=3" -computer $computer

   #group data by computername
   $groups=$Data | Group-Object -Property SystemName

   #this is the graph character
   [string]$g=[char]9608 

   #create html fragments for each computer
   #iterate through each group object
           
   ForEach ($computer in $groups) {
       #define a collection of drives from the group object
       $Drives=$computer.group
       
       #create an html fragment
       $html=$drives | Select @{Name="分区";Expression={$_.DeviceID}},
	   @{Name="卷名";Expression={$_.VolumeName}},
       @{Name='容量 GB';Expression={$_.Size/1GB  -as [int]}},
       @{Name='已用 GB';Expression={"{0:N2}" -f (($_.Size - $_.Freespace)/1GB) }},
       @{Name='可用 GB';Expression={"{0:N2}" -f ($_.FreeSpace/1GB) }},
	   @{Name='可用 %';Expression={"{0:N2}" -f (($_.FreeSpace/$_.Size)*100)}},
       @{Name="使用状态";Expression={
         $UsedPer= (($_.Size - $_.Freespace)/$_.Size)*100
         $UsedGraph=$g * ($UsedPer/2)
         $FreeGraph=$g* ((100-$UsedPer)/2)
         #I'm using place holders for the < and > characters
         "xopenFont color=Redxclose{0}xopen/FontxclosexopenFont Color=Greenxclose{1}xopen/fontxclose" -f $usedGraph,$FreeGraph
       }} | ConvertTo-Html -Fragment 
       
       #replace the tag place holders. It is a hack but it works.
       $html=$html -replace "xopen","<"
       $html=$html -replace "xclose",">"
       
       #add to fragments
       $Fragments+=$html
       
       #insert a return between each computer
       $fragments+="<br>"
       
   } #foreach computer

   #write the result to a file
   Return $fragments
}

Function Get-HostUptime 
{
#   param ([string]$Computer)
   $Uptime = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer
   $LastBootUpTime = $Uptime.ConvertToDateTime($Uptime.LastBootUpTime)
   $Time = (Get-Date) - $LastBootUpTime
   Return '{0:00} 天, {1:00} 小时, {2:00} 分钟, {3:00} 秒' -f $Time.Days, $Time.Hours, $Time.Minutes, $Time.Seconds
}
#endregion functions

#region General System Report
$DriveSpaceReport = Get-DriveSpace $Computer
# General System Info
$OS = (Get-WmiObject Win32_OperatingSystem -computername $Computer).caption
$OSArchitecture = (Get-WmiObject Win32_OperatingSystem -computername $Computer).OSArchitecture
$SystemInfo = Get-WmiObject -Class Win32_OperatingSystem -computername $Computer | Select-Object Name, TotalVisibleMemorySize, FreePhysicalMemory
$CPULoad=(Get-WmiObject  win32_Processor -computername $Computer ).LoadPercentage
$TotalRAM = $SystemInfo.TotalVisibleMemorySize/1MB
$FreeRAM = $SystemInfo.FreePhysicalMemory/1MB
$UsedRAM = $TotalRAM - $FreeRAM
$RAMPercentFree = ($FreeRAM / $TotalRAM) * 100
$RAMPercentUsed = ($UsedRAM / $TotalRAM) * 100
$TotalRAM = [Math]::Round($TotalRAM, 2)
$FreeRAM = [Math]::Round($FreeRAM, 2)
$UsedRAM = [Math]::Round($UsedRAM, 2)
$RAMPercentFree = [Math]::Round($RAMPercentFree, 2)
$RAMPercentUsed = [Math]::Round($RAMPercentUsed, 2)
$TopProcesses = Get-Process -ComputerName $Computer | Sort WS -Descending | `
  Select ProcessName, Id, WS -First $ProccessNumToFetch | ConvertTo-Html -Fragment

# Services Report
$ServicesReport = @()
$Services = Get-WmiObject -Class Win32_Service -ComputerName $Computer | `
  Where {($_.StartMode -eq "Auto") -and ($_.State -eq "Stopped")}

foreach ($Service in $Services) {
  $row = New-Object -Type PSObject -Property @{
        Name = $Service.Name
     Status = $Service.State
     StartMode = $Service.StartMode
  } 
  $ServicesReport += $row
}

$ServicesReport = $ServicesReport | ConvertTo-Html -Fragment
   
# Event Logs Report
$SystemEventsReport = @()
$SystemEvents = Get-EventLog -ComputerName $Computer -LogName System -EntryType Error,Warning -Newest $EventNum
foreach ($event in $SystemEvents) {
   $row = New-Object -Type PSObject -Property @{
      TimeGenerated = $event.TimeGenerated
      EntryType = $event.EntryType
      Source = $event.Source
      Message = $event.Message
   }
   $SystemEventsReport += $row
}
      
$SystemEventsReport = $SystemEventsReport | ConvertTo-Html -Fragment

$ApplicationEventsReport = @()
$ApplicationEvents = Get-EventLog -ComputerName $Computer -LogName Application -EntryType Error,Warning -Newest $EventNum
foreach ($event in $ApplicationEvents) {
   $row = New-Object -Type PSObject -Property @{
      TimeGenerated = $event.TimeGenerated
      EntryType = $event.EntryType
      Source = $event.Source
      Message = $event.Message
   }
   $ApplicationEventsReport += $row
}

$ApplicationEventsReport = $ApplicationEventsReport | ConvertTo-Html -Fragment

# Uptime
# Fetch the Uptime of the current system using our Get-HostUptime Function.
$SystemUptime = Get-HostUptime -ComputerName $Computer

# Create HTML Report for the current System being looped through
$CurrentSystemHTML = ''
$CurrentSystemHTML += "<hr noshade size=3 width='100%'>"
$CurrentSystemHTML += "<div id='report'>"
$CurrentSystemHTML += "<p><h2>$Computer</p></h2>"
$CurrentSystemHTML += "<h3>$computer 系统信息</h3>"
$CurrentSystemHTML += '<table class="list">'
$CurrentSystemHTML += '<tr>'
$CurrentSystemHTML += '<td>主机名</td>'
$CurrentSystemHTML += "<td>$Computer</td>"
$CurrentSystemHTML += "</tr>"
$CurrentSystemHTML += '<tr>'
$CurrentSystemHTML += '<td>系统运行时间</td>'
$CurrentSystemHTML += "<td>$SystemUptime</td>"
$CurrentSystemHTML += "</tr>"
$CurrentSystemHTML += "<tr>"
$CurrentSystemHTML += "<td>操作系统</td>"
$CurrentSystemHTML += "<td>$OS</td>"
$CurrentSystemHTML += "</tr>"
$CurrentSystemHTML += "<tr>"
$CurrentSystemHTML += "<td>系统架构</td>"
$CurrentSystemHTML += "<td>$OSArchitecture</td>"
$CurrentSystemHTML += "</tr>"
$CurrentSystemHTML += "<tr>"
$CurrentSystemHTML += "<td>CPU占用(%)</td>"
$CurrentSystemHTML += "<td>$CPULoad</td>"
$CurrentSystemHTML += "</tr>"
$CurrentSystemHTML += "<tr>"
$CurrentSystemHTML += "<td>总内存(GB)</td>"
$CurrentSystemHTML += "<td>$TotalRAM</td>"
$CurrentSystemHTML += "</tr>"
$CurrentSystemHTML += "<tr>"
$CurrentSystemHTML += "<td>可用内存(GB)</td>"
$CurrentSystemHTML += "<td>$FreeRAM</td>"
$CurrentSystemHTML += "</tr>"
$CurrentSystemHTML += "<tr>"
$CurrentSystemHTML += "<td>可用内存(%)</td>"
$CurrentSystemHTML += "<td>$RAMPercentFree</td>"
$CurrentSystemHTML += "</tr>"
$CurrentSystemHTML += "</table>"
$CurrentSystemHTML += "<h3>$computer 硬盘信息</h3>"
$CurrentSystemHTML += "$DriveSpaceReport"
$CurrentSystemHTML += "<br></br>"
$CurrentSystemHTML += "<table class='normal'>"
$CurrentSystemHTML += "$DiskInfo</table>"
$CurrentSystemHTML += "<br></br>"
$CurrentSystemHTML += "<div class='first column'>"
$CurrentSystemHTML += "<h3>$computer 系统进程 - 使用内存最多的前 $ProccessNumToFetch 位</h3>"
$CurrentSystemHTML += "<p>下面 $ProccessNumToFetch 个为使用内存最多的进程(bytes)</p>"
$CurrentSystemHTML += "<table class='normal'>"
$CurrentSystemHTML += "$TopProcesses</table>"
$CurrentSystemHTML += "</div>"
$CurrentSystemHTML += "<div class='second column'>"
$CurrentSystemHTML += "<h3>$computer 系统服务 - 需要自动启动，但没有运行的服务</h3>"
$CurrentSystemHTML += "<p>下列服务启用类型设置为自动，但当前并没有运行</p>"
$CurrentSystemHTML += "<table class='normal'>"
$CurrentSystemHTML += "$ServicesReport"
$CurrentSystemHTML += "</table>"
$CurrentSystemHTML += "</div>"
$CurrentSystemHTML += "<h3>$computer 事件日志报告 - 最后 $EventNum 个系统、应用程序日志中显示为警告或错误</h3>"
$CurrentSystemHTML += "<p>下面列表是为最后 $EventNum <b>个系统日志</b> 中有任何警告或是错误类型的日志内容</p>"
$CurrentSystemHTML += "<table class='normal'>"
$CurrentSystemHTML += "$SystemEventsReport</table>"
$CurrentSystemHTML += "<p>下面列表是为最后 $EventNum <b>个应用程序日志</b> 中有任何警告或是错误类型的日志内容</p>"
$CurrentSystemHTML += "<table class='normal'>"
$CurrentSystemHTML += "$ApplicationEventsReport</table>"

# Add the current System HTML Report into the final HTML Report body
$HTMLMiddle += $CurrentSystemHTML

# Assemble the final report from all our HTML sections
$HTMLmessage = $HTMLHeader + $HTMLMiddle + $HTMLEnd
}

if ($SendMail)
{
	$HTMLmessage = $HTMLmessage | Out-String
	$email= 
	@{
		From = $EmailSender
		To = $EmailRecipient
#		CC = "johnson.xiang@szmaxcent.com"
		Subject = "General Server Report - $ServerName"
		SMTPServer = $EmailRelay
		Body = $HTMLmessage
		Encoding = ([System.Text.Encoding]::UTF8)
		BodyAsHTML = $true
	}
	Send-MailMessage @email
	Sleep -Milliseconds 200
}
elseif ($SaveReport)
{
	$HTMLMessage | Out-File $ReportName
}
else
{
   Return $HTMLmessage
}
#endregion General System Report


