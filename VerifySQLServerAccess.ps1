param(
	[string]$VFile = "c:\test\List.txt",
	[string]$VFailedLog = 'c:\test\FailedToConnect.txt',   
	[string]$VSuccessLog = 'c:\test\SucceededToConnect.txt'
	)

$ServerList = Get-Content $VFile -ErrorAction SilentlyContinue

Out-File -FilePath $VFailedLog
Out-File -FilePath $VSuccessLog

ForEach($computername in $ServerList)

{
	$ConnectionStringForSQL = $computername
	try{
		#Create connection
		$sqlConn = New-Object System.Data.SqlClient.SqlConnection
		$sqlConn.ConnectionString = “Server=$ConnectionStringForSQL;Integrated Security=true;Initial Catalog=master;Connection Timeout=1”
		$sqlConn.Open()

		#create command
		$sqlcmd = $sqlConn.CreateCommand()
		$sqlcmd = New-Object System.Data.SqlClient.SqlCommand
		$sqlcmd.Connection = $sqlConn
		$query = “SELECT @@ServerName”
		$sqlcmd.CommandText = $query

		#create data adapter
		$adp = New-Object System.Data.SqlClient.SqlDataAdapter $sqlcmd

		#Create Your DataSet (and fill it)
		$data = New-Object System.Data.DataSet
		$adp.Fill($data) | Out-Null

		#Retrieving Your Data
		$data.Tables
		$computername | out-file $VSuccessLog -Append
		}

	catch{
		$exception = $_.Exception.Message
		Out-File -FilePath $VFailedLog -Append -InputObject $computername
		}
}