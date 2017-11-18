# Get-ExecutionPolicy -List  
# Set-ExecutionPolicy Unrestricted -Scope CurrentUser  
# -CompressionOption [Default / On / Off] (是否压缩)  
# -BackupAction [Database / Log / Files] (备份类型)  
# -Incremental (差异备份)  
  
import-module sqlps;  
$instance = '192.168.2.225,8033'  
$database = 'Test'  
$targetDir = 'E:\Backup\TestBackup'  
$datestr = Get-Date -format yyyyMMddHHmmss  
$backupFile = $targetDir + '\' + $database + '_' + $datestr + '.bak'  
  
Backup-SqlDatabase -ServerInstance $instance -Database $database -CompressionOption On -Checksum -BackupFile $backupFile  