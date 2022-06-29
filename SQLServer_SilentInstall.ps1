Write-Host "##########################################################
#  * EXECUTAR COMO ADMINISTRADOR!
#
#  * PARA USAR O VALOR DEFAULT, BASTAR DEIXAR A VARIÁVEL EM BRANCO.
#
#  * INSTALAÇÃO DE SHARED FEATURES COMO: INTEGRATION SERVICES E ANALYSIS SERVICES IRÃO SEGUIR AS CONFIGURAÇÔES PADRÕES DA INSTALAÇÃO.
#
#  * Esse é uma versão modificada by Marcos Lomba, do script disponível no github, link: 
#    https://github.com/majkinetor/Install-SqlServer *
#
##########################################################
"


# Path to ISO file, if empty and current directory contains single ISO file, it will be used.
[ValidateNotNullOrEmpty()]
[string] $IsoPath = Read-Host -Prompt "
Informe o caminho completo da mídia (.iso) de instalação do SQL:
"

# Install type
[ValidateNotNullOrEmpty()]
[string] $Type = Read-Host -Prompt "
Informe 1 para instalação assitida ou 2 para instalação silenciosa:
"

#[ValidateSet('SQLEngine', 'Replication', 'FullText', 'DQ', 'PolyBase', 'AdvancedAnalytics', 'AS', 'RS', 'DQC', 'IS', 'MDS', 'SQL_SHARED_MR', 'Tools', 'BC', 'BOL', 'Conn', 'DREPLAY_CLT', 'SNAC_SDK', 'SDK', 'LocalDB')]
[string[]] $Features = @(Read-Host -Prompt "
*****************************************************
*
* SQLEngine = SQL Server Database Engine.
* Replication = Installs the Replication component.
* FullText = Installs the FullText component.
* AS = Installs all Analysis Services components.
* IS = Installs all Integration Services components.
* Conn = Installs connectivity components.
* See all features on https://docs.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server-from-the-command-prompt?view=sql-server-ver16#Feature
*
* Default = SQLEngine,Conn
*****************************************************

Informe as features que serão instaladas:
")

#If empty, set default value
IF (!$Features){
[string] $Features = 'SQLEngine,Conn'
}

# Service name. Mandatory, by default MSSQLSERVER
#[ValidateNotNullOrEmpty()]
[string] $InstanceName = Read-Host -Prompt "
*****************************************************
* 
* Default: MSSQLSERVER
*
*****************************************************

Informe o nome da instância:
"

#If empty, set default value
#IF (!$InstanceName){
#[string] $InstanceName = 'MSSQLSERVER'
#}


[string] $Collation = Read-Host -Prompt "
*****************************************************
* 
* Default: SQL_Latin1_General_CP1_CI_AS
*
*****************************************************

Informe a collation da instância:
"


# Specify the installation directory. 
[string] $InstallDir = Read-Host -Prompt "
*****************************************************
*
* Default: C:\Program Files\Microsoft SQL Server\
* Suggestion: Na raiz do disco de instalação que foi criado para o SQL. EX: 'I:\'
*
*****************************************************

Informe o caminho da instalação do SQL:
"

#The Database data directory."
[string] $DataDir = Read-Host -Prompt "
*****************************************************
*
* Default: Caminho informado na váriavel anterior + \MSSQL\Data.
* Suggestion: Ter um ou mais discos exclusivo para armazenar os arquivos de dados do SQL Server. EX: 'D:\SQLData\'
*
*****************************************************

Informe o local de armazenamento dos arquivos de dados (mdf):
"

#The Database log directory."
[string] $logDir = Read-Host -Prompt "
*****************************************************
*
* Default: Caminho informado na váriavel anterior + \MSSQL\Data.
* Suggestion: Ter um disco exclusivo para armazenar os arquivos de log do SQL Server. EX: 'L:\SQLLog\'
*
*****************************************************

Informe o local de armazenamento dos arquivos de log (ldf):
"

#The Database backup directory."
[string] $bkpDir = Read-Host -Prompt "
*****************************************************
*
* Default: Caminho informado na váriavel anterior + \MSSQL\Backup.
*
*****************************************************

Informe o caminho do diretório de backup local:
"

#The TempDB data directory."
[string] $TDBDataDir = Read-Host -Prompt "
*****************************************************
*
* Default: Caminho informado na váriavel anterior + \MSSQL\Data.
* Suggestion: Ter um ou mais discos exclusivo para armazenar os arquivos de dados do TempDB. EX: 'T:\SQLData\'
*
*****************************************************

Informe o local de armazenamento dos arquivos de dados (mdf) do TempDB:
"

#The TempDB log directory."
[string] $TDBlogDir = Read-Host -Prompt "
*****************************************************
*
* Default: Caminho informado na váriavel anterior + \MSSQL\Data.
* Suggestion: Isolar a database TempDB, armazenando os arquivos de log, no mesmo disco que os arquivos de dados do TempDB. EX: 'T:\SQLLog\'
*
*****************************************************

Informe o local de armazenamento dos arquivos de log (ldf) do TempDB:
"

#Amount TempDB files."
$TDBfiles = Read-Host -Prompt "
*****************************************************
*
* Default: A instalação do SQL calcula para você, baseado na quantidade de cores do servidor.
* Suggestion: Usar o default. Ou ter um arquivo por CPU core. Limitando máximo de 8 arquivos.
*
*****************************************************

Informe a quantidade de aqruivos de dados do TempDB:
"

#TempDB data files growth."
$TDBdataGrowth = Read-Host -Prompt "
*****************************************************
*
* Default: 64MB
*
*****************************************************

Informe o valor em MB, para AtuoGrowth do arquivo de dados do TempDB:
"

#TempDB log files growth."
$TDBlogGrowth = Read-Host -Prompt "
*****************************************************
*
* Default: 64MB
*
*****************************************************

Informe o valor em MB, para AtuoGrowth do arquivo de log do TempDB:
"

# sa user password. If empty, SQL security mode (mixed mode) is disabled
[ValidateNotNullOrEmpty()]
[string] $SaPassword = Read-Host -Prompt "
Informe a senha do usuário sa:
"

# Account for SQL Server service: Domain\User or system account. 
[string] $ServiceAccountName = Read-Host -Prompt "
*****************************************************
*
* Default: Usuário local. EX: 'NT Service\MSSQL`$`DEV'
* Suggestion: Usuário de serviço do domínio. EX: MEUDOMINIO\svc_sql_engine
*
*****************************************************

Informe o nome do usuário de serviço do SQL Engine:
"

IF ($ServiceAccountName){
# Password for the service account
[string] $ServiceAccountPassword = Read-Host -Prompt "
Informe a senha do usuário de serviço '$ServiceAccountName':
"
}

# Account for Agent Server service: Domain\User or system account. 
[string] $AGServiceAccountName = Read-Host -Prompt "
*****************************************************
*
* Default: Usuário local. EX: 'NT Service\SQLAgent`$`DEV'
* Suggestion: Usuário de serviço do domínio. EX: MEUDOMINIO\svc_sql_agent
*
*****************************************************

Informe o nome do usuário do serviço do SQL Agent:
"

IF ($AGServiceAccountName){
# Password for the service account
[string] $AGServiceAccountPassword = Read-Host -Prompt "
Informe a senha do usuário de serviço '$AGServiceAccountName':
"
}


# List of system administrative accounts in the form <domain>\<user>
# Mandatory, by default current user will be added as system administrator
[string[]] $SystemAdminAccounts = @(Read-Host -Prompt "
****************************************************
*
* Default: MEUDOMINIO\SQL DBAs
* Suggestion: MEUDOMINIO\DBAs; MEUDOMINIO\usrdba.adm
*
****************************************************

Informe os grupos ou usuários do AD que serão sysadmins da instância:
")

IF (!$SystemAdminAccounts){
[string] $SystemAdminAccounts = 'MEUDOMINIO\SQL DBAs'
}

# Set memory
$MemoryMax = @(Read-Host -Prompt "
****************************************************
*
* Default: 80% da memória do servidor. Caso a instalação seja inferior ao SQL 2019, favor definir o valor manualmente.
*
****************************************************

Informe o valor em MB, para o MemoryMax da instância:
")

# Set maxdop
$MaxDop = @(Read-Host -Prompt "
****************************************************
*
* Default: Calculado pela própria instalação, baseado nas cofigurações de nó NUMA e CPU cores. 
*          Caso a instalação seja inferior ao SQL 2019, favor definir o valor manualmente.
*
****************************************************

Informe o valor MaxDop da instância:
")

# Product key, if omitted, evaluation is used unless VL edition which is already activated
#[string] $ProductKey,

# Use bits transfer to get files from the Internet
#[switch] $UseBitsTransfer,

# Enable SQL Server protocols: TCP/IP, Named Pipes
#[switch] $EnableProtocols


#INI: Gerando log da execução do script.
$ErrorActionPreference = 'STOP'
#$scriptName = (Split-Path -Leaf $PSCommandPath).Replace('.ps1', '')

$start = Get-Date
#Start-Transcript "$PSScriptRoot\$scriptName-$($start.ToString('s').Replace(':','-')).log"
#FIM: Gerando log da execução do script.

Write-Host "`IsoPath: " $IsoPath

# Montando ISO
$volume    = Mount-DiskImage $IsoPath -StorageType ISO -PassThru | Get-Volume
$sql_drive = $volume.DriveLetter + ':'
Get-ChildItem $sql_drive | ft -auto | Out-String


# Verificando se não tem uma instalação aberta
Get-CimInstance win32_process | ? { $_.commandLine -like '*setup.exe*/ACTION=install*' } | % {
    Write-Host "Sql Server installer is already running, killing it:" $_.Path  "pid: " $_.processId
    Stop-Process $_.processId -Force}


# Montando a chaamdao do instalado do SQL (setup.exe)
$cmd =@(
    "${sql_drive}setup.exe"
    #Geral
    IF ( $Type -eq 2){
    '/Q'	# Silent install
    }
    #'/INSTALLSHAREDWOWDIR="C:\Program Files (x86)\Microsoft SQL Server"'	# Specify the root installation directory for the WOW64 shared components.  This directory remains unchanged after WOW64 shared components are already installed. 
    #'/INSTALLSHAREDDIR="C:\Program Files\Microsoft SQL Server"'	# Specify the root installation directory for shared components.  This directory remains unchanged after shared components are already installed.
    '/TCPENABLED="1"'	# Specify 0 to disable or 1 to enable the TCP/IP protocol. 
    '/INDICATEPROGRESS'	# Specifies that the verbose Setup log file is piped to the console
    '/IACCEPTSQLSERVERLICENSETERMS'	# Must be included in unattended installations
    '/ACTION=install'	# Required to indicate the installation workflow
    #'/UPDATEENABLED=false'	# Should it discover and include product updates.
    '/ENU="True"'	# Use the /ENU parameter to install the English version of SQL Server on your localized Windows operating system. 
    '/X86="False"'	# Specifies that Setup should install into WOW64. This command line argument is not supported on an IA64 or a 32-bit system. 
    '/SQLSVCINSTANTFILEINIT="True"'	# Set to "True" to enable instant file initialization for SQL Server service.

    #Variable
    "/FEATURES=""" + ($Features -join ',') + '"'	# Specifies features to install
    "/INSTANCENAME=$InstanceName"	# Server instance name
    "/INSTANCEDIR=""$InstallDir"""	# Specify the installation directory.        
    #"/INSTALLSQLDATADIR=""$DataDir"""	# The Database Engine root data directory.      
    "/SQLBACKUPDIR=""$bkpDir"""	# Default directory for the Database Engine backup files. 
    "/SQLUSERDBDIR=""$DataDir"""	# Default directory for the Database Engine user databases.
    "/SQLUSERDBLOGDIR=""$logDir"""	# Default directory for the Database Engine user database logs. 
    "/SQLTEMPDBLOGDIR=""$TDBlogDir"""	# Directory for the Database Engine TempDB log files. 
    "/SQLTEMPDBDIR=""$TDBDataDir"""	# Directories for Database Engine TempDB files.
    "/SQLTEMPDBFILECOUNT=""$TDBfiles"""	# The number of Database Engine TempDB files. 
    "/SQLTEMPDBLOGFILEGROWTH=""$TDBlogGrowth"""	# Specifies the automatic growth increment of the Database Engine TempDB log file in MB. 
    "/SQLTEMPDBFILEGROWTH=""$TDBdataGrowth"""	# Specifies the automatic growth increment of each Database Engine TempDB data file in MB. 
    #'/SQLTEMPDBFILESIZE="100"'	# Specifies the initial size of a Database Engine TempDB data file in MB.
    "/SQLCOLLATION=""$Collation"""	# Specifies a Windows collation or an SQL collation to use for the Database Engine. 
    IF (!$MemoryMax){
        '/USESQLRECOMMENDEDMEMORYLIMITS="True"'	# Use USESQLRECOMMENDEDMEMORYLIMITS to minimize the risk of the OS experiencing detrimental memory pressure. 
        }
    ELSE{
        "/SQLMAXMEMORY=""$MemoryMax"""	# Specifies the Max Server Memory configuration in MB. 
        }
     "/SQLMAXDOP=""$MaxDop"""	# The max degree of parallelism (MAXDOP) server configuration option. 

    #Security
    '/SECURITYMODE="SQL"'	#The default is Windows Authentication. Use "SQL" for Mixed Mode Authentication. 
    "/SQLSYSADMINACCOUNTS=""" + ($SystemAdminAccounts -join ',') + '"'	# Windows account(s) to provision as SQL Server system administrators. 
    "/SAPWD=""$SaPassword"""	# Sa user password
    "/SQLSVCACCOUNT=""$ServiceAccountName"""	# Account for SQL Server service: Domain\User or system account. 
    "/SQLSVCPASSWORD=""$ServiceAccountPassword"""	# Account password
    "/AGTSVCACCOUNT=""$AGServiceAccountName"""	# Agent account name: : Domain\User or system account. 
    "/AGTSVCPASSWORD=""$AGServiceAccountPassword"""	# Agent account domain password.

    
    #Integration Services
    #'/ISSVCACCOUNT="NT Service\MsDtsServer150"' #Account for Integration Services: Domain\User or system account. 
    #'/ISSVCPASSWORD="1q2w3e4r"' #Integration Services account domain password.
    #'/ISSVCSTARTUPTYPE="Automatic"' #Startup type for Integration Services.
    
    # Service startup types
    "/SQLSVCSTARTUPTYPE=automatic"
    "/AGTSVCSTARTUPTYPE=automatic"
)
$cmd_out = $cmd = $cmd -notmatch '/.+?=("")?$'

"$cmd_out"
Invoke-Expression "$cmd"
if ($LastExitCode) {
    if ($LastExitCode -ne 3010) { throw "SqlServer installation failed, exit code: $LastExitCode" }
    Write-Warning "SYSTEM REBOOT IS REQUIRED"
}

"`nInstallation length: {0:f1} minutes" -f ((Get-Date) - $start).TotalMinutes

Dismount-DiskImage $IsoPath
#Stop-Transcript
trap { Stop-Transcript; if ($IsoPath) { Dismount-DiskImage $IsoPath -ErrorAction 0 } }