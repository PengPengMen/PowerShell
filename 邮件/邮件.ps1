     $From = "menpengpeng@163.com"
     $To = "menpengpeng@qq.com"
     $Subject = "TestSubject" 
     $Body = "TestBody"
     $smtpServer = "smtp.163.com"
     $smtpPort = 25
     $username = "menpengpeng"
     $password = "menpengfei521"

     $SMTPMessage = New-Object System.Net.Mail.MailMessage($From, $To, $Subject, $Body)
     $SMTPClient = New-Object Net.Mail.SmtpClient($smtpServer, $SmtpPort) 
     $SMTPClient.EnableSsl = $false 
     $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($username, $password); 
     $SMTPClient.Send($SMTPMessage)
