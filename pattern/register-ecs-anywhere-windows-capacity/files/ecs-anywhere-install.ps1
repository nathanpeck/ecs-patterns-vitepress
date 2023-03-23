<#
    .SYNOPSIS
    Performs installation/maintenance of various components for running Amazon ECS on customer managed external instances.

    .DESCRIPTION
    This script enables customers to run Amazon ECS on external instances by supporting-
    - Installation of AWS SSM on the instance
    - Registration of the external instance as an AWS SSM managed instance
    - Installation of ECSTools Powershell module to support Amazon ECS
    - Installation of Amazon ECS container runtime on the instance
    - Installation of Amazon ECS Agent on the instance
    - Uninstallation of Amazon ECS Anywhere components from the customer managed instance
    - Updating Amazon ECS container agent running on the instance

    NOTE: Please run this script with Administrator privileges.

    .PARAMETER Region
    [Optional] Specifies the region of Amazon ECS Cluster and AWS SSM activation. It is required unless -Uninstall is specified.

    .PARAMETER ActivationID
    [Optional] Specifies activation id from the create activation command. Not required if -SkipRegistration or -Uninstall is specified.

    .PARAMETER ActivationCode
    [Optional] Specifies activation code from the create activation command. Not required if -SkipRegistration or -Uninstall is specified.

    .PARAMETER Cluster
    [Optional] Specifies the cluster name to which the Amazon ECS agent will connect to. Defaults to 'default'.

    .PARAMETER ECSVersion
    [Optional] Specifies the Amazon ECS agent version which would be installed on the instance. Defaults to 'latest'.

    .PARAMETER SkipRegistration
    [Optional] Specifies that SSM installation and registration of instance to SSM can be skipped.

    .PARAMETER ContainerRuntimeVersion
    [Optional] Specifies the container runtime version to be installed on the instance. Defaults to 'latest'.

    .PARAMETER Uninstall
    [Optional] Specifies if the uninstallation needs to be performed on the instance.

    .PARAMETER ECSEndpoint
    [Optional] Specifies the endpoint to which the Amazon ECS agent would connect.

    .PARAMETER ECSToolsS3BucketName
    [Optional] Specifies the S3 endpoint bucket to pull the ECSTools module from.

    .INPUTS
    None. You cannot pipe objects to this script.

    .OUTPUTS
    None. This script does not generate an output object.

    .EXAMPLE
    PS> .\ecs-anywhere-install.ps1 -Region us-west-2 -ActivationID <ID> -ActivationCode <Code> -Cluster ecs-anywhere
    Installs Container runtime, AWS SSM, and Amazon ECS (latest container agent) on the instance. It also registers the instance with AWS SSM and registers the instance to Amazon ECS cluster.

    .EXAMPLE
    PS> .\ecs-anywhere-install.ps1 -Region us-west-2 -ActivationID <ID> -ActivationCode <Code> -Cluster ecs-anywhere -ECSVersion 1.57.0
    Installs a specific version of Amazon ECS agent on the instance along with other dependencies as Example 1.

    .EXAMPLE
    PS> .\ecs-anywhere-install.ps1 -Region us-west-2 -ActivationID <ID> -ActivationCode <Code> -Cluster ecs-anywhere -ContainerRuntimeVersion 20.10.7
    Installs a specific version of ContainerRuntimeVersion on the instance along with other dependencies as Example 1.

    .EXAMPLE
    PS> .\ecs-anywhere-install.ps1 -Region us-west-2 -SkipRegistration -Cluster ecs-anywhere
    Installs only container runtime and Amazon ECS on the instance.

    .EXAMPLE
    PS> .\ecs-anywhere-install.ps1 -Region us-west-2 -SkipRegistration -Cluster ecs-anywhere -ECSVersion 1.56.0
    Installs a specific version of Amazon ECS agent on the instance. This can be used for updating the container agent running on the instance.

    .EXAMPLE
    PS> .\ecs-anywhere-install.ps1 -Uninstall
    Stops and removes the AWS SSM and Amazon ECS services from the customer instance.

    .LINK
    Amazon ECS Anywhere documentation: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-anywhere.html

    .NOTES
    Amazon ECS Anywhere on Windows is supported only for the following Windows releases-
    - Windows Server 2022
    - Windows Server 20H2
    - Windows Server 2019
    - Windows Server 2016
#>

#Requires -RunAsAdministrator

Param (
    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]$Region,

    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]$ActivationID,

    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]$ActivationCode,

    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]$Cluster = "default",

    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]$ECSVersion = "latest",

    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [switch]$SkipRegistration,

    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]$ContainerRuntimeVersion = "latest",

    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [switch]$Uninstall,

    [Parameter(Mandatory=$false)]
    [string]$ECSEndpoint,

    [Parameter(Mandatory=$false)]
    [string]$ECSToolsS3BucketName
)

Function Initialize-ScriptDependencies {
    # AllowedOSBuildNumberToRelease corresponds to the map of build number of allowed Windows releases to the release name.
    # Reference- https://docs.microsoft.com/en-us/windows-server/get-started/windows-server-release-info
    [HashTable]$Script:AllowedOSBuildNumberToRelease = @{
        "20348"="2022";
        "19042"="20H2";
        "17763"="2019";
        "14393"="2016";
    }

    # TempDirectory is the temporary directory created to store the artifacts.
    [String]$Script:TempDirectory = Join-Path $env:TEMP (New-Guid)

    # Remove the contents of temp directory if it exists. Otherwise, create a new folder.
    if (Test-Path -Path $Script:TempDirectory) {
        Remove-Item -Path $Script:TempDirectory/* -Recurse -Force
    } else {
        New-Item -Path $Script:TempDirectory -ItemType Directory
    }

    # ECSProgramData is the Amazon ECS ProgramData directory.
    [String]$Script:ECSProgramData = Join-Path $ENV:ProgramData "Amazon\ECS"
    # ECSCache is the cache location for ECS artifacts.
    [String]$Script:ECSCache = Join-Path $ENV:ProgramData "Amazon\ECS\cache"
    # ECSModulePath is the path of ECSTools powershell module.
    [String]$Script:ECSModulePath = Join-Path $ENV:ProgramFiles "WindowsPowerShell\Modules\ECSTools"
    # ECSInstallationPath is the path of Amazon ECS artifacts on the instance.
    [String]$Script:ECSInstallationPath = Join-Path $ENV:ProgramFiles "Amazon\ECS"

    # S3URLSuffix is the suffix for the S3 URLs. For example- In China regions, this would be .cn
    [String]$Script:S3URLSuffix = ""
    if ($Region.StartsWith("cn-")) {
        $Script:S3URLSuffix = ".cn"
    }

    # SSMAgentInstaller is the name of the Amazon SSM agent installer.
    [String]$Script:SSMAgentInstaller = "AmazonSSMAgentSetup.exe"
    # SSMAgentS3URL is the S3 url for AWS SSM Agent installer.
    [String]$Script:SSMAgentS3URL = Join-S3PathParts -S3Bucket  "https://amazon-ssm-$($Region).s3.$($Region).amazonaws.com$($Script:S3URLSuffix)/latest/windows_amd64" -FileName $Script:SSMAgentInstaller
    # SSMAgentInstallerFullPath is the absolute path of the location of SSM agent installer.
    [String]$Script:SSMAgentInstallerFullPath = Join-Path $Script:TempDirectory $Script:SSMAgentInstaller

    # SSMBinPath is the path where SSM agent would be installed.
    # On Windows, this path is the default path of 'C:\Program Files\Amazon\SSM' and cannot be changed.
    [String]$Script:SSMBinPath = Join-Path $ENV:ProgramFiles "Amazon\SSM"
    # ECSExecArtifactsArchiveName is the name of the ECS Exec artifacts archive.
    [string]$Script:ECSExecArtifactsArchiveName = "execute-command-binaries.zip"
    # AmazonECSExecBinaries is the list of SSM binaries required for ECS Exec on Windows.
    [Array]$Script:AmazonECSExecBinaries = "amazon-ssm-agent.exe","ssm-agent-worker.exe","ssm-session-logger.exe","ssm-session-worker.exe","Plugins\SessionManagerShell\winpty.dll","Plugins\SessionManagerShell\winpty-agent.exe"

    # ECSAgentSourceBucket is the source bucket for the agent artifacts.
    [String]$Script:ECSAgentSourceBucket = "amazon-ecs-agent-$($Region)"
    if (-not([string]::IsNullOrEmpty($ECSToolsS3BucketName)))
    {
        $Script:ECSAgentSourceBucket = $ECSToolsS3BucketName
    }

    [String]$ECSToolsS3BucketRoot = "https://s3.$($Region).amazonaws.com$($Script:S3URLSuffix)/$($Script:ECSAgentSourceBucket)"
    # ECSToolsPSM1 is the name for the file ECSTools.psm1.
    [String]$Script:ECSToolsPSM1 = "ECSTools.psm1"
    # ECSToolsPSD1 is the name for the file ECSTools.psd1.
    [String]$Script:ECSToolsPSD1 = "ECSTools.psd1"
    # ECSToolsPSM1S3URL is the S3 url for ECSTools.psm1.
    [String]$Script:ECSToolsPSM1S3URL = Join-S3PathParts -S3Bucket $ECSToolsS3BucketRoot -FileName "ECSTools.psm1"
    # ECSToolsPSD1S3URL is the S3 url for ECSTools.psd1.
    [String]$Script:ECSToolsPSD1S3URL = Join-S3PathParts -S3Bucket $ECSToolsS3BucketRoot -FileName "ECSTools.psd1"

    # SSMAgentServiceName is the name of the Amazon SSM Agent service.
    [String]$Script:SSMAgentServiceName = "AmazonSSMAgent"
    # AmazonECSServiceName is the name of the Amazon ECS Agent service.
    [String]$Script:AmazonECSServiceName = "AmazonECS"
    # ECSContainerRuntimeName is the name of the ECS container runtime.
    [String]$Script:ECSContainerRuntimeName = "Docker"
}

Function Write-Log {
    <#
    .SYNOPSIS
    This is a helper method for writing the output logs to stdout.
    #>
    [cmdletbinding()]
    Param (
        $Message
    )

    $fullMessage = "$(((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))) - $($message)"
    Write-Host $fullMessage
}

Function Join-S3PathParts {
    Param (
        [ValidateNotNullOrEmpty()]
        [string]$S3Bucket,

        [ValidateNotNullOrEmpty()]
        [string]$FileName
    )

    if ($S3Bucket[$S3Bucket.Length - 1] -ne '/')
    {
        return "{0}/{1}" -f $S3Bucket, $FileName
    }
    return $S3Bucket + $FileName
}

Function Test-OSRelease {
    <#
    .SYNOPSIS
    This method tests if the current OS release is supported by Amazon ECS Anywhere.
    #>

    [String]$CurrentOSBuildNumber = $PSVersionTable.PSVersion.Build
    if (-not $Script:AllowedOSBuildNumberToRelease.ContainsKey($CurrentOSBuildNumber)) {
        throw "The current Windows release with build number {0} is not supported." -f $CurrentOSBuildNumber
    }
    Write-Log ("OS release {0} is supported" -f $Script:AllowedOSBuildNumberToRelease[$CurrentOSBuildNumber])
}

Function Test-ScriptParameters {
    <#
    .SYNOPSIS
    This method performs validation of the parameters for the script.
    #>

    if (-not $Uninstall)
    {
        if (-not $Cluster) {
            throw "Cluster is required unless -Uninstall was specified"
        }

        if ((-not $SkipRegistration) -and ((-not $ActivationCode) -or (-not $ActivationID)))
        {
            throw "Activation Code and ID are required if -SkipRegistration is not used."
        }

        if ($SkipRegistration) {
            # If the registration is skipped then the SSM Agent service must be running.
            Test-ServiceStatus -ServiceName $Script:SSMAgentServiceName
        }
    }
}

Function Get-FileFromS3 {
    <#
    .SYNOPSIS
    This method downloads a file from Amazon S3 at the specified path.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$S3FileURL,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputFilePath
    )

    Begin {
        if (Test-Path -Path $OutputFilePath) {
            Write-Log ("Existing file found at {0}. Deleting it." -f $OutputFilePath)
            Remove-Item -Recurse -Force $OutputFilePath
        }
    } Process {
            try {
                Write-Log ("Downloading file from S3: {0}" -f $S3FileURL)
                Invoke-RestMethod -Uri $S3FileURL -OutFile $OutputFilePath
            } catch {
                throw "Error downloading file from S3: {0} at {1}. Message: {2}" -f $S3FileURL,$OutputFilePath,$_.Exception.Message
            }
    } End {
        if (-not (Test-Path -Path $OutputFilePath)) {
            throw "Failed to download file from S3: {0} at {1}. Message: {2}" -f $S3FileURL,$OutputFilePath,$_.Exception.Message
        }
    }
}

Function Test-ServiceStatus {
    <#
    .SYNOPSIS
    This method tests if the specified service is in running status.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ServiceName,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [int]$SleepTime = 5
    )

    if (-not (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue)) {
        throw "{0} service not found" -f $ServiceName
    }

    Write-Log ("Validating if the {0} service is running..." -f $ServiceName)
    for ($iteration=1; $iteration -le 10; $iteration++) {
        if ((Get-Service -Name $ServiceName).Status -eq "Running") {
            Write-Log ("{0} service is running!" -f $ServiceName)
            return
        } else {
            Write-Log ("{0} service is not running. Waiting for it to move into running status after {1} retry." -f $ServiceName,$iteration)
            Start-Sleep $SleepTime
        }
    }

    throw "{0} service failed to start" -f $ServiceName
}

Function Install-SSMAgent {
    <#
    .SYNOPSIS
    This method downloads and installs the AWS SSM agent.
    It also registers the external instance with AWS SSM using the provided activation code and ID.
    #>

    try {
        # Download SSM Agent installer from S3.
        Get-FileFromS3 -S3FileURL $Script:SSMAgentS3URL -OutputFilePath $Script:SSMAgentInstallerFullPath
        # TODO: Currently, SSM Agent does not publish hash for their artifacts and therefore, we are not validating the hash for now.
        # In the future, when hash is published along with the agent artifacts, we need to start validating the hash as well.

        # Remove any existing SSM artifacts before starting a fresh install.
        Remove-SSMArtifacts

        # Install latest SSM agent on the instance.
        Write-Log "Starting installation of Amazon SSM agent..."
        Start-Process $Script:SSMAgentInstallerFullPath -ArgumentList @("/q", "/log", "install.log", "CODE=$($ActivationCode)", "ID=$($ActivationID)", "REGION=$($Region)") -Wait
        Test-ServiceStatus -ServiceName $Script:SSMAgentServiceName
    } catch {
        throw "Failed to install SSM agent on the instance: {0}" -f $_.Exception.Message
    }
}

Function Install-ContainerRuntime {
    <#
    .SYNOPSIS
    This method downloads and installs container runtime for Amazon ECS.
    #>

    try {
        Write-Log "Starting installation of ECS container runtime..."
        Import-Module ECSTools
        $RestartNeeded = Install-ECSRuntime -RequiredVersion $ContainerRuntimeVersion
        if ($RestartNeeded) {
            Write-Log "Restart the system to complete installation of Windows feature: Containers"
            exit 0
        }
        Test-ServiceStatus $Script:ECSContainerRuntimeName
    } catch {
        throw "Failed to install container runtime on the instance: {0}" -f $_.Exception.Message
    }
}

Function Install-ECSToolsModule {
    <#
    .SYNOPSIS
    This method downloads and installs the ECSTools Powershell module.
    #>

    try {
        Write-Log "Starting installation of ECSTools powershell module..."

        $ECSToolsPSM1FullPath = Join-Path $Script:TempDirectory $Script:ECSToolsPSM1
        Get-FileFromS3 -S3FileURL $Script:ECSToolsPSM1S3URL -OutputFilePath $ECSToolsPSM1FullPath

        $ECSToolsPSD1FullPath = Join-Path $Script:TempDirectory $Script:ECSToolsPSD1
        Get-FileFromS3 -S3FileURL $Script:ECSToolsPSD1S3URL -OutputFilePath $ECSToolsPSD1FullPath

        # If module exists in the current session, then remove it.
        Get-Module -Name ECSTools | Remove-Module

        # Remove the module itself from Powershell.
        if (Test-Path -Path $Script:ECSModulePath) {
            Remove-Item -Recurse -Force -Path $Script:ECSModulePath
        }

        # Add the downloaded module to the Powershell.
        Write-Log "Setting up ECSTools inside powershell modules."
        New-Item -ItemType "directory" -Path $Script:ECSModulePath
        Copy-Item $ECSToolsPSM1FullPath -Destination $Script:ECSModulePath
        Copy-Item $ECSToolsPSD1FullPath -Destination $Script:ECSModulePath
        if ((-not (Test-Path $Script:ECSModulePath)) -or ((Get-ChildItem $Script:ECSModulePath | Measure-Object).Count -ne 2)) {
            throw "Expected files for ECSTools not found."
        }

        if (-not (Get-Module -ListAvailable -Name ECSTools)) {
            throw "ECSTools not found among installed powershell modules."
        }
    } catch {
        throw "Failed to install ECSTools module on the instance: {0}" -f $_.Exception.Message
    }
}

Function Compress-ECSExecArtifacts {
    <#
    .SYNOPSIS
    This method creates the artifact archive required for ECS Exec initialization.
    Since we are installing SSM on the instance using the installer, therefore, all the
    required binaries would be present on the instance. We copy them into an archive.
    #>

    try {
        Write-Log "Starting creation of ECS Exec artifacts archive..."

        $archivePath = "$Script:ECSProgramData\$Script:ECSExecArtifactsArchiveName"
        # If the archive exists, then return.
        # Only in case of uninstallation, we would remove the cache.
        if (Test-Path -Path $archivePath) {
            Write-Log "ECS Exec artifacts archive already exists."
            return
        }

        # Temp directory where all the files will be copied.
        $tempPath = "C:\ecs-exec-artifacts"
        New-Item -Path $tempPath -ItemType "directory"

        Write-Log "Copying required binaries into $tempPath"
        foreach ($bin in $Script:AmazonECSExecBinaries) {
            $binSourcePath = "$SSMBinPath\$bin"
            $binDestinationPath = "$tempPath\$bin"

            if (!(Test-Path -path "$binSourcePath")) {
                throw "$binSourcePath not found"
            }

            # Create parent path for destination if it doesn't exist.
            # This is required for nested folders.
            $rootPath = Split-Path -Path $binDestinationPath
            if (-not (Test-Path -Path $rootPath)) {
                New-Item -Type Directory -Path $rootPath | Out-Null
            }
            # Copy the binary to the temp folder.
            Copy-Item -Path "$binSourcePath" -Destination "$binDestinationPath"
        }

        # Create the cache folder if not present.
        if (-not (Test-Path -Path $Script:ECSCache)) {
            New-Item -Path $Script:ECSCache -ItemType "directory"
        }

        # Create the archive.
        Write-Log "Compressing the artifacts into a zip."
        Compress-Archive -Path "$tempPath\*" -DestinationPath $archivePath

        # Remove the temp folder where we copied the binaries.
        Remove-Item -Recurse -Force $tempPath
    } catch {
        throw "Failed to create ECS Exec artifacts archive : {0}" -f $_.Exception.Message
    }
}

Function Install-ECSAgent {
    <#
    .SYNOPSIS
    This method downloads and installs the Amazon ECS Agent on the instance along with all the prerequisites.

    .DESCRIPTION
    This method performs the following actions-
    - Downloads the required version of Amazon ECS agent
    - Sets up various environment variables required for Amazon ECS agent to run on the external instance
    - Starts Amazon ECS Agent as a Windows service
    #>

    try {
        Write-Log "Starting installation of ECS Agent..."
        Import-Module ECSTools

        $InitializeAgentArgs = @{
            RequiredRuntimeVersion = $ContainerRuntimeVersion;
            AWSDefaultRegion = $Region;
            OverrideSourceRegion = $Region;
            OverrideSourceBucket = $Script:ECSAgentSourceBucket;
            Version = $ECSVersion;
            Cluster = $Cluster;
            ECSEndpoint = $ECSEndpoint;
            LoggingDrivers = '["json-file","awslogs"]';
        }
        Initialize-ECSAgent @InitializeAgentArgs -ExternalInstance -EnableTaskIAMRole
        Test-ServiceStatus -ServiceName $Script:AmazonECSServiceName
    } catch {
        throw "Failed to install ECS Agent on the instance: {0}" -f $_.Exception.Message
    }
}

Function Remove-SSMArtifacts {
    <#
    .SYNOPSIS
    This method stops and uninstalls AWS SSM from the customer instance.

    .DESCRIPTION
    This method stop the AmazonSSM service and uninstalls AWS SSM from the customer instance.
    #>

    try {
        Write-Log "Starting uninstallation of any existing SSM agent version..."
        # Check and remove the SSM Agent service, if it exists.
        $existingSvc = Get-WmiObject -Class Win32_Service -Filter "Name='$Script:SSMAgentServiceName'"
        if ($existingSvc -ne $null) {
            Write-Log "Existing SSM agent installation found. Stopping and deleting the service."
            $existingSvc.StopService()
            $existingSvc.Delete()
            # Wait few seconds for the service to be deleted.
            Start-Sleep 1
        }

        Write-Log "Uninstalling any existing SSM agent installation"
        if (-not (Test-Path $Script:SSMAgentInstallerFullPath)) {
            Get-FileFromS3 -S3FileURL $Script:SSMAgentS3URL -OutputFilePath $Script:SSMAgentInstallerFullPath
            # TODO: Currently, SSM Agent does not publish hash for their artifacts and therefore, we are not validating the hash for now.
            # In the future, when hash is published along with the agent artifacts, we need to start validating the hash as well.
        }
        Start-Process $Script:SSMAgentInstallerFullPath -ArgumentList @('/uninstall', '/q', '/norestart') -Wait
    } catch {
        throw "Failed to uninstall SSM on the instance: {0}" -f $_.Exception.Message
    }
    Write-Log "Uninstallation of SSM agent succeeded."
}

Function Remove-ECSArtifacts {
    <#
    .SYNOPSIS
    This method stops and uninstalls Amazon ECS along with other components from the customer instance.

    .DESCRIPTION
    This method stops the AmazonECS service and removes the service along with ECSTools from the external instance.
    #>

    try {
        Write-Log "Starting uninstallation of any existing ECS artifacts..."
        # Remove Amazon ECS service.
        Import-Module ECSTools
        Remove-ECSAgentInstallation

        # Remove the installation folder for Amazon ECS.
        Remove-Item -Recurse -Force $Script:ECSInstallationPath

        # Remove the cache folder for Amazon ECS.
        Remove-Item -Recurse -Force $Script:ECSCache

        # If ECSTools module exists in the current session, then remove it.
        Get-Module -Name ECSTools | Remove-Module

        # Remove the module from Powershell.
        if (Test-Path $Script:ECSModulePath)
        {
            Remove-Item -Recurse -Force $Script:ECSModulePath
        }
        Write-Log "Uninstallation of ECS artifacts succeeded."
    } catch {
        throw "Failed to uninstall ECS Agent on the instance: {0}" -f $_.Exception.Message
    }
}

try {
    # Initialize all the dependencies for running this script.
    Initialize-ScriptDependencies
    # Validate if the current OS release is supported for running Amazon ECS Anywhere.
    Test-OSRelease
    # Validate the parameters with which the script was invoked.
    Test-ScriptParameters

    # Install the helper Amazon ECS Powershell module.
    Install-ECSToolsModule

    if (-not $Uninstall)
    {
        # Install container runtime before installing AWS SSM or Amazon ECS.
        Install-ContainerRuntime

        if (-not $SkipRegistration)
        {
            Install-SSMAgent
        }

        Compress-ECSExecArtifacts

        Install-ECSAgent

        Write-Log "Installation of Amazon ECS on this instance was successful."
    }
    else
    {
        # Uninstallation order is opposite of installation order.
        Remove-ECSArtifacts
        Remove-SSMArtifacts

        Write-Log "Uninstallation of AWS SSM and Amazon ECS on this instance was successful."
    }
} catch {
    Write-Log ("[ERROR] Failed to setup Amazon ECS Anywhere on this instance. Exception: {0}" -f $_.Exception.Message)
    Exit 1
} finally {
    Remove-Item -Recurse -Force $Script:TempDirectory
}

# SIG # Begin signature block
# MIIuewYJKoZIhvcNAQcCoIIubDCCLmgCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCALjZwukjkRvNOL
# TuK/5XSC/As+hvqyNTNCzH2hbeFW8KCCE+kwggXAMIIEqKADAgECAhAP0bvKeWvX
# +N1MguEKmpYxMA0GCSqGSIb3DQEBCwUAMGwxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xKzApBgNV
# BAMTIkRpZ2lDZXJ0IEhpZ2ggQXNzdXJhbmNlIEVWIFJvb3QgQ0EwHhcNMjIwMTEz
# MDAwMDAwWhcNMzExMTA5MjM1OTU5WjBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMM
# RGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQD
# ExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwggIiMA0GCSqGSIb3DQEBAQUAA4IC
# DwAwggIKAoICAQC/5pBzaN675F1KPDAiMGkz7MKnJS7JIT3yithZwuEppz1Yq3aa
# za57G4QNxDAf8xukOBbrVsaXbR2rsnnyyhHS5F/WBTxSD1Ifxp4VpX6+n6lXFllV
# cq9ok3DCsrp1mWpzMpTREEQQLt+C8weE5nQ7bXHiLQwb7iDVySAdYyktzuxeTsiT
# +CFhmzTrBcZe7FsavOvJz82sNEBfsXpm7nfISKhmV1efVFiODCu3T6cw2Vbuyntd
# 463JT17lNecxy9qTXtyOj4DatpGYQJB5w3jHtrHEtWoYOAMQjdjUN6QuBX2I9YI+
# EJFwq1WCQTLX2wRzKm6RAXwhTNS8rhsDdV14Ztk6MUSaM0C/CNdaSaTC5qmgZ92k
# J7yhTzm1EVgX9yRcRo9k98FpiHaYdj1ZXUJ2h4mXaXpI8OCiEhtmmnTK3kse5w5j
# rubU75KSOp493ADkRSWJtppEGSt+wJS00mFt6zPZxd9LBADMfRyVw4/3IbKyEbe7
# f/LVjHAsQWCqsWMYRJUadmJ+9oCw++hkpjPRiQfhvbfmQ6QYuKZ3AeEPlAwhHbJU
# KSWJbOUOUlFHdL4mrLZBdd56rF+NP8m800ERElvlEFDrMcXKchYiCd98THU/Y+wh
# X8QgUWtvsauGi0/C1kVfnSD8oR7FwI+isX4KJpn15GkvmB0t9dmpsh3lGwIDAQAB
# o4IBZjCCAWIwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQU7NfjgtJxXWRM3y5n
# P+e6mK4cD08wHwYDVR0jBBgwFoAUsT7DaQP4v0cB1JgmGggC72NkK8MwDgYDVR0P
# AQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMDMH8GCCsGAQUFBwEBBHMwcTAk
# BggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEkGCCsGAQUFBzAC
# hj1odHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRIaWdoQXNzdXJh
# bmNlRVZSb290Q0EuY3J0MEsGA1UdHwREMEIwQKA+oDyGOmh0dHA6Ly9jcmwzLmRp
# Z2ljZXJ0LmNvbS9EaWdpQ2VydEhpZ2hBc3N1cmFuY2VFVlJvb3RDQS5jcmwwHAYD
# VR0gBBUwEzAHBgVngQwBAzAIBgZngQwBBAEwDQYJKoZIhvcNAQELBQADggEBAEHx
# qRH0DxNHecllao3A7pgEpMbjDPKisedfYk/ak1k2zfIe4R7sD+EbP5HU5A/C5pg0
# /xkPZigfT2IxpCrhKhO61z7H0ZL+q93fqpgzRh9Onr3g7QdG64AupP2uU7SkwaT1
# IY1rzAGt9Rnu15ClMlIr28xzDxj4+87eg3Gn77tRWwR2L62t0+od/P1Tk+WMieNg
# GbngLyOOLFxJy34riDkruQZhiPOuAnZ2dMFkkbiJUZflhX0901emWG4f7vtpYeJa
# 3Cgh6GO6Ps9W7Zrk9wXqyvPsEt84zdp7PiuTUy9cUQBY3pBIowrHC/Q7bVUx8ALM
# R3eWUaNetbxcyEMRoacwggawMIIEmKADAgECAhAIrUCyYNKcTJ9ezam9k67ZMA0G
# CSqGSIb3DQEBDAUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJ
# bmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0
# IFRydXN0ZWQgUm9vdCBHNDAeFw0yMTA0MjkwMDAwMDBaFw0zNjA0MjgyMzU5NTla
# MGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8GA1UE
# AxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcgUlNBNDA5NiBTSEEz
# ODQgMjAyMSBDQTEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDVtC9C
# 0CiteLdd1TlZG7GIQvUzjOs9gZdwxbvEhSYwn6SOaNhc9es0JAfhS0/TeEP0F9ce
# 2vnS1WcaUk8OoVf8iJnBkcyBAz5NcCRks43iCH00fUyAVxJrQ5qZ8sU7H/Lvy0da
# E6ZMswEgJfMQ04uy+wjwiuCdCcBlp/qYgEk1hz1RGeiQIXhFLqGfLOEYwhrMxe6T
# SXBCMo/7xuoc82VokaJNTIIRSFJo3hC9FFdd6BgTZcV/sk+FLEikVoQ11vkunKoA
# FdE3/hoGlMJ8yOobMubKwvSnowMOdKWvObarYBLj6Na59zHh3K3kGKDYwSNHR7Oh
# D26jq22YBoMbt2pnLdK9RBqSEIGPsDsJ18ebMlrC/2pgVItJwZPt4bRc4G/rJvmM
# 1bL5OBDm6s6R9b7T+2+TYTRcvJNFKIM2KmYoX7BzzosmJQayg9Rc9hUZTO1i4F4z
# 8ujo7AqnsAMrkbI2eb73rQgedaZlzLvjSFDzd5Ea/ttQokbIYViY9XwCFjyDKK05
# huzUtw1T0PhH5nUwjewwk3YUpltLXXRhTT8SkXbev1jLchApQfDVxW0mdmgRQRNY
# mtwmKwH0iU1Z23jPgUo+QEdfyYFQc4UQIyFZYIpkVMHMIRroOBl8ZhzNeDhFMJlP
# /2NPTLuqDQhTQXxYPUez+rbsjDIJAsxsPAxWEQIDAQABo4IBWTCCAVUwEgYDVR0T
# AQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUaDfg67Y7+F8Rhvv+YXsIiGX0TkIwHwYD
# VR0jBBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMG
# A1UdJQQMMAoGCCsGAQUFBwMDMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYY
# aHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2Fj
# ZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNV
# HR8EPDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRU
# cnVzdGVkUm9vdEc0LmNybDAcBgNVHSAEFTATMAcGBWeBDAEDMAgGBmeBDAEEATAN
# BgkqhkiG9w0BAQwFAAOCAgEAOiNEPY0Idu6PvDqZ01bgAhql+Eg08yy25nRm95Ry
# sQDKr2wwJxMSnpBEn0v9nqN8JtU3vDpdSG2V1T9J9Ce7FoFFUP2cvbaF4HZ+N3HL
# IvdaqpDP9ZNq4+sg0dVQeYiaiorBtr2hSBh+3NiAGhEZGM1hmYFW9snjdufE5Btf
# Q/g+lP92OT2e1JnPSt0o618moZVYSNUa/tcnP/2Q0XaG3RywYFzzDaju4ImhvTnh
# OE7abrs2nfvlIVNaw8rpavGiPttDuDPITzgUkpn13c5UbdldAhQfQDN8A+KVssIh
# dXNSy0bYxDQcoqVLjc1vdjcshT8azibpGL6QB7BDf5WIIIJw8MzK7/0pNVwfiThV
# 9zeKiwmhywvpMRr/LhlcOXHhvpynCgbWJme3kuZOX956rEnPLqR0kq3bPKSchh/j
# wVYbKyP/j7XqiHtwa+aguv06P0WmxOgWkVKLQcBIhEuWTatEQOON8BUozu3xGFYH
# Ki8QxAwIZDwzj64ojDzLj4gLDb879M4ee47vtevLt/B3E+bnKD+sEq6lLyJsQfmC
# XBVmzGwOysWGw/YmMwwHS6DTBwJqakAwSEs0qFEgu60bhQjiWQ1tygVQK+pKHJ6l
# /aCnHwZ05/LWUpD9r4VIIflXO7ScA+2GRfS0YW6/aOImYIbqyK+p/pQd52MbOoZW
# eE4wggdtMIIFVaADAgECAhADicOQeHZ3hNc0dJdGQP0hMA0GCSqGSIb3DQEBCwUA
# MGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8GA1UE
# AxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcgUlNBNDA5NiBTSEEz
# ODQgMjAyMSBDQTEwHhcNMjIxMjA3MDAwMDAwWhcNMjMxMjA2MjM1OTU5WjCB8jET
# MBEGCysGAQQBgjc8AgEDEwJVUzEZMBcGCysGAQQBgjc8AgECEwhEZWxhd2FyZTEd
# MBsGA1UEDwwUUHJpdmF0ZSBPcmdhbml6YXRpb24xEDAOBgNVBAUTBzQxNTI5NTQx
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdTZWF0
# dGxlMSIwIAYDVQQKExlBbWF6b24gV2ViIFNlcnZpY2VzLCBJbmMuMRMwEQYDVQQL
# EwpBbWF6b24gRUNTMSIwIAYDVQQDExlBbWF6b24gV2ViIFNlcnZpY2VzLCBJbmMu
# MIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEAx5mmTRFcmkTM07rFN8/Y
# 1Wlxlq5bqUdOZq60f5B5BZzEnGBTsHBE3o+t7FSfyTmiPVa0iqts6xU+dxxV6HCq
# 0gRyH3wBq4F2O0xswduJ72n6JerCPO77sfFXk402Ua4rExg65uKiXro2LQCoWgNL
# HXdtk+YoyVFJpp6GyAqPCleToFhuEU5GHMw2UtO+4QzHPOmRBQMPgqXdex8KRkFT
# FtLUwA/6z2sNg6+ACO0LkE/vcib5MrqkNTxGr/d1A57KP50g88LfRU+2mIBwvK8L
# dHQZQMBuZAF0DDMYL2+JJzEueTm+R08B/mk20oipninC7DcqlWUihyu3rucJP4gi
# +wFOCSDnEnTQkD13+YJ3wZZX7HEyPDbvivUQ9qBU2NhjkrEAwEePWCpV2b7YB15K
# vdYv3G01QgXzkJTbc3iJLx1U8uyqCTbycJzimQZpJ2OioAcSMZJ0yM+u6gYx7m9S
# MUYtbPnBGDCAFlW/iaQHE8nos509qjH/kBhEXE+mHR+lAgMBAAGjggIFMIICATAf
# BgNVHSMEGDAWgBRoN+Drtjv4XxGG+/5hewiIZfROQjAdBgNVHQ4EFgQUAg6CsGoe
# kZrY0RZkXcvUXBtpEIAwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUF
# BwMDMIG1BgNVHR8Ega0wgaowU6BRoE+GTWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydFRydXN0ZWRHNENvZGVTaWduaW5nUlNBNDA5NlNIQTM4NDIwMjFD
# QTEuY3JsMFOgUaBPhk1odHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRU
# cnVzdGVkRzRDb2RlU2lnbmluZ1JTQTQwOTZTSEEzODQyMDIxQ0ExLmNybDA9BgNV
# HSAENjA0MDIGBWeBDAEDMCkwJwYIKwYBBQUHAgEWG2h0dHA6Ly93d3cuZGlnaWNl
# cnQuY29tL0NQUzCBlAYIKwYBBQUHAQEEgYcwgYQwJAYIKwYBBQUHMAGGGGh0dHA6
# Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBcBggrBgEFBQcwAoZQaHR0cDovL2NhY2VydHMu
# ZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0Q29kZVNpZ25pbmdSU0E0MDk2
# U0hBMzg0MjAyMUNBMS5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOC
# AgEAvAOvM7x2ofTqjuIu8A2Qy4gIgIYUQZ+aHyff8kMMoKY/9nUyTgbmfB3if8Ww
# f2xN5nV0V2325gOSJhdkfiHva17WYznleF06cMBc/8RaLZ94jkycMpIMs+JhpM73
# TLZqua1w8YuQNN8ihiCcGF+Bmy7/Wr8vSCfXRMXmv8soHbF1lv8DHbhCJYZEah29
# lMtHFvmDE0SySEWCcvr3QBSSPuC0z+aDSyb/ylrYOt97QnzE8IFtSToU7R1PSej4
# pxjf5FEhFruwLcXLjhx1OyFdh0F7XqSvmcaGUnOuoVcAqj6uZk0TVR2F0ih95INE
# GUcTorl+yS7BWyzhdAh+uOwvFBjaS0F61xLMTxNy1jtmR/0qxXQ0UYVk7eSsUptd
# adHSoi0+EblxzGoyvIdaxh1IqoTbZrJcRpWY+5gvfuHpcdShpGkyti8bWH1mSHzm
# y52tVFRf9N2wZkw85OIWuVNrFN95fTFxfA0vWjoOizG9T83+wstSrrSiIF0ZmO8b
# Lerr6CA+kgZCR7alYyWq/8sPmZb2YDbCuCYS9IXsZuo7l4DKqkpa/Tk0hhSVVpBC
# y/3CaqGEEUn3wqFD4/iHMk3m+kQSkBcNAA5UZ7TBETlewrH3cuOyVAZSTtaXwrq+
# u0BhXPsHuyMcKomxN4oUfoDndu3JSeZfISPMXsEDX5a9p2UxghnoMIIZ5AIBATB9
# MGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8GA1UE
# AxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcgUlNBNDA5NiBTSEEz
# ODQgMjAyMSBDQTECEAOJw5B4dneE1zR0l0ZA/SEwDQYJYIZIAWUDBAIBBQCgfDAQ
# BgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQgOXSztUnR
# CuRiJED7tTWypwf0Z1pwth3NQ49uueUSAgUwDQYJKoZIhvcNAQEBBQAEggGANGp6
# dKjCIBiqdfzchB0zThrAauFifCZXZeAjyUOSKPmCQB3tP6w6IlwtTCMiJSxG3Ptj
# 1wrf+4q89ONvUDt4PxuOCBZYjAbcbLir/Q8ijSvVkcbGOHL3w6OfymOVcZkAYCS8
# EnX4Plzr5KulxgTKwuwf5CtTv0wfUv+BRuEAs93bhCZ3h3l1UNHTyZAc/Dtcj6A2
# 9+C037h6FtCoh98oppng/kz2dc4NUlbTclG4gd1QKwBv02AjO5sLUCi4Ij1jTYAh
# UUr6eMEQRRrTpwr4aokuPCNVsc6vi1Zidm237D0WJMX/70XIKceJTFhU2Wmt/NDJ
# KaZVUfvpxOqE2mRur1Ll6RwzufQqSS4/0D8pWkY7a7a8XIQzg9FfG2UAELw7mwzK
# bX2ulLmNb6cwOT9oyiXnmtuYyz0dn2gh72E1Pqyp33w6e/ZTPa5vighAnTATqqrn
# 5dG011Iwr0sm7cRFgLvSYD5wBMaNq+iqriemKLUeE7J1UmRyYODjGy9tkKyboYIX
# PjCCFzoGCisGAQQBgjcDAwExghcqMIIXJgYJKoZIhvcNAQcCoIIXFzCCFxMCAQMx
# DzANBglghkgBZQMEAgEFADB4BgsqhkiG9w0BCRABBKBpBGcwZQIBAQYJYIZIAYb9
# bAcBMDEwDQYJYIZIAWUDBAIBBQAEIPRnPMLTdfq6KUT83OE1s977Ms81c4IK1wi5
# Ye65Yc1jAhEAwNFunSqZ0RqpCk8M2RZ8ARgPMjAyMzAyMjEwMTA5MDRaoIITBzCC
# BsAwggSooAMCAQICEAxNaXJLlPo8Kko9KQeAPVowDQYJKoZIhvcNAQELBQAwYzEL
# MAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJE
# aWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBD
# QTAeFw0yMjA5MjEwMDAwMDBaFw0zMzExMjEyMzU5NTlaMEYxCzAJBgNVBAYTAlVT
# MREwDwYDVQQKEwhEaWdpQ2VydDEkMCIGA1UEAxMbRGlnaUNlcnQgVGltZXN0YW1w
# IDIwMjIgLSAyMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAz+ylJjrG
# qfJru43BDZrboegUhXQzGias0BxVHh42bbySVQxh9J0Jdz0Vlggva2Sk/QaDFteR
# kjgcMQKW+3KxlzpVrzPsYYrppijbkGNcvYlT4DotjIdCriak5Lt4eLl6FuFWxsC6
# ZFO7KhbnUEi7iGkMiMbxvuAvfTuxylONQIMe58tySSgeTIAehVbnhe3yYbyqOgd9
# 9qtu5Wbd4lz1L+2N1E2VhGjjgMtqedHSEJFGKes+JvK0jM1MuWbIu6pQOA3ljJRd
# GVq/9XtAbm8WqJqclUeGhXk+DF5mjBoKJL6cqtKctvdPbnjEKD+jHA9QBje6CNk1
# prUe2nhYHTno+EyREJZ+TeHdwq2lfvgtGx/sK0YYoxn2Off1wU9xLokDEaJLu5i/
# +k/kezbvBkTkVf826uV8MefzwlLE5hZ7Wn6lJXPbwGqZIS1j5Vn1TS+QHye30qsU
# 5Thmh1EIa/tTQznQZPpWz+D0CuYUbWR4u5j9lMNzIfMvwi4g14Gs0/EH1OG92V1L
# bjGUKYvmQaRllMBY5eUuKZCmt2Fk+tkgbBhRYLqmgQ8JJVPxvzvpqwcOagc5YhnJ
# 1oV/E9mNec9ixezhe7nMZxMHmsF47caIyLBuMnnHC1mDjcbu9Sx8e47LZInxscS4
# 51NeX1XSfRkpWQNO+l3qRXMchH7XzuLUOncCAwEAAaOCAYswggGHMA4GA1UdDwEB
# /wQEAwIHgDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMCAG
# A1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATAfBgNVHSMEGDAWgBS6Ftlt
# TYUvcyl2mi91jGogj57IbzAdBgNVHQ4EFgQUYore0GH8jzEU7ZcLzT0qlBTfUpww
# WgYDVR0fBFMwUTBPoE2gS4ZJaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lD
# ZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NBLmNybDCBkAYI
# KwYBBQUHAQEEgYMwgYAwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0
# LmNvbTBYBggrBgEFBQcwAoZMaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0Rp
# Z2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NBLmNydDAN
# BgkqhkiG9w0BAQsFAAOCAgEAVaoqGvNG83hXNzD8deNP1oUj8fz5lTmbJeb3coqY
# w3fUZPwV+zbCSVEseIhjVQlGOQD8adTKmyn7oz/AyQCbEx2wmIncePLNfIXNU52v
# YuJhZqMUKkWHSphCK1D8G7WeCDAJ+uQt1wmJefkJ5ojOfRu4aqKbwVNgCeijuJ3X
# rR8cuOyYQfD2DoD75P/fnRCn6wC6X0qPGjpStOq/CUkVNTZZmg9U0rIbf35eCa12
# VIp0bcrSBWcrduv/mLImlTgZiEQU5QpZomvnIj5EIdI/HMCb7XxIstiSDJFPPGaU
# r10CU+ue4p7k0x+GAWScAMLpWnR1DT3heYi/HAGXyRkjgNc2Wl+WFrFjDMZGQDvO
# XTXUWT5Dmhiuw8nLw/ubE19qtcfg8wXDWd8nYiveQclTuf80EGf2JjKYe/5cQpSB
# lIKdrAqLxksVStOYkEVgM4DgI974A6T2RUflzrgDQkfoQTZxd639ouiXdE4u2h4d
# jFrIHprVwvDGIqhPm73YHJpRxC+a9l+nJ5e6li6FV8Bg53hWf2rvwpWaSxECyIKc
# yRoFfLpxtU56mWz06J7UWpjIn7+NuxhcQ/XQKujiYu54BNu90ftbCqhwfvCXhHjj
# CANdRyxjqCU4lwHSPzra5eX25pvcfizM/xdMTQCi2NYBDriL7ubgclWJLCcZYfZ3
# AYwwggauMIIElqADAgECAhAHNje3JFR82Ees/ShmKl5bMA0GCSqGSIb3DQEBCwUA
# MGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsT
# EHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9v
# dCBHNDAeFw0yMjAzMjMwMDAwMDBaFw0zNzAzMjIyMzU5NTlaMGMxCzAJBgNVBAYT
# AlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQg
# VHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0EwggIiMA0G
# CSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDGhjUGSbPBPXJJUVXHJQPE8pE3qZdR
# odbSg9GeTKJtoLDMg/la9hGhRBVCX6SI82j6ffOciQt/nR+eDzMfUBMLJnOWbfhX
# qAJ9/UO0hNoR8XOxs+4rgISKIhjf69o9xBd/qxkrPkLcZ47qUT3w1lbU5ygt69Ox
# tXXnHwZljZQp09nsad/ZkIdGAHvbREGJ3HxqV3rwN3mfXazL6IRktFLydkf3YYMZ
# 3V+0VAshaG43IbtArF+y3kp9zvU5EmfvDqVjbOSmxR3NNg1c1eYbqMFkdECnwHLF
# uk4fsbVYTXn+149zk6wsOeKlSNbwsDETqVcplicu9Yemj052FVUmcJgmf6AaRyBD
# 40NjgHt1biclkJg6OBGz9vae5jtb7IHeIhTZgirHkr+g3uM+onP65x9abJTyUpUR
# K1h0QCirc0PO30qhHGs4xSnzyqqWc0Jon7ZGs506o9UD4L/wojzKQtwYSH8UNM/S
# TKvvmz3+DrhkKvp1KCRB7UK/BZxmSVJQ9FHzNklNiyDSLFc1eSuo80VgvCONWPfc
# Yd6T/jnA+bIwpUzX6ZhKWD7TA4j+s4/TXkt2ElGTyYwMO1uKIqjBJgj5FBASA31f
# I7tk42PgpuE+9sJ0sj8eCXbsq11GdeJgo1gJASgADoRU7s7pXcheMBK9Rp6103a5
# 0g5rmQzSM7TNsQIDAQABo4IBXTCCAVkwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNV
# HQ4EFgQUuhbZbU2FL3MpdpovdYxqII+eyG8wHwYDVR0jBBgwFoAU7NfjgtJxXWRM
# 3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMI
# MHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNl
# cnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20v
# RGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNVHR8EPDA6MDigNqA0hjJodHRw
# Oi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNybDAg
# BgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwDQYJKoZIhvcNAQELBQAD
# ggIBAH1ZjsCTtm+YqUQiAX5m1tghQuGwGC4QTRPPMFPOvxj7x1Bd4ksp+3CKDaop
# afxpwc8dB+k+YMjYC+VcW9dth/qEICU0MWfNthKWb8RQTGIdDAiCqBa9qVbPFXON
# ASIlzpVpP0d3+3J0FNf/q0+KLHqrhc1DX+1gtqpPkWaeLJ7giqzl/Yy8ZCaHbJK9
# nXzQcAp876i8dU+6WvepELJd6f8oVInw1YpxdmXazPByoyP6wCeCRK6ZJxurJB4m
# wbfeKuv2nrF5mYGjVoarCkXJ38SNoOeY+/umnXKvxMfBwWpx2cYTgAnEtp/Nh4ck
# u0+jSbl3ZpHxcpzpSwJSpzd+k1OsOx0ISQ+UzTl63f8lY5knLD0/a6fxZsNBzU+2
# QJshIUDQtxMkzdwdeDrknq3lNHGS1yZr5Dhzq6YBT70/O3itTK37xJV77QpfMzmH
# QXh6OOmc4d0j/R0o08f56PGYX/sr2H7yRp11LB4nLCbbbxV7HhmLNriT1ObyF5lZ
# ynDwN7+YAN8gFk8n+2BnFqFmut1VwDophrCYoCvtlUG3OtUVmDG0YgkPCr2B2RP+
# v6TR81fZvAT6gt4y3wSJ8ADNXcL50CN/AAvkdgIm2fBldkKmKYcJRyvmfxqkhQ/8
# mJb2VVQrH4D6wPIOK+XW+6kvRBVK5xMOHds3OBqhK/bt1nz8MIIFjTCCBHWgAwIB
# AgIQDpsYjvnQLefv21DiCEAYWjANBgkqhkiG9w0BAQwFADBlMQswCQYDVQQGEwJV
# UzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQu
# Y29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3QgQ0EwHhcNMjIw
# ODAxMDAwMDAwWhcNMzExMTA5MjM1OTU5WjBiMQswCQYDVQQGEwJVUzEVMBMGA1UE
# ChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYD
# VQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwggIiMA0GCSqGSIb3DQEBAQUA
# A4ICDwAwggIKAoICAQC/5pBzaN675F1KPDAiMGkz7MKnJS7JIT3yithZwuEppz1Y
# q3aaza57G4QNxDAf8xukOBbrVsaXbR2rsnnyyhHS5F/WBTxSD1Ifxp4VpX6+n6lX
# FllVcq9ok3DCsrp1mWpzMpTREEQQLt+C8weE5nQ7bXHiLQwb7iDVySAdYyktzuxe
# TsiT+CFhmzTrBcZe7FsavOvJz82sNEBfsXpm7nfISKhmV1efVFiODCu3T6cw2Vbu
# yntd463JT17lNecxy9qTXtyOj4DatpGYQJB5w3jHtrHEtWoYOAMQjdjUN6QuBX2I
# 9YI+EJFwq1WCQTLX2wRzKm6RAXwhTNS8rhsDdV14Ztk6MUSaM0C/CNdaSaTC5qmg
# Z92kJ7yhTzm1EVgX9yRcRo9k98FpiHaYdj1ZXUJ2h4mXaXpI8OCiEhtmmnTK3kse
# 5w5jrubU75KSOp493ADkRSWJtppEGSt+wJS00mFt6zPZxd9LBADMfRyVw4/3IbKy
# Ebe7f/LVjHAsQWCqsWMYRJUadmJ+9oCw++hkpjPRiQfhvbfmQ6QYuKZ3AeEPlAwh
# HbJUKSWJbOUOUlFHdL4mrLZBdd56rF+NP8m800ERElvlEFDrMcXKchYiCd98THU/
# Y+whX8QgUWtvsauGi0/C1kVfnSD8oR7FwI+isX4KJpn15GkvmB0t9dmpsh3lGwID
# AQABo4IBOjCCATYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQU7NfjgtJxXWRM
# 3y5nP+e6mK4cD08wHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wDgYD
# VR0PAQH/BAQDAgGGMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDov
# L29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5k
# aWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0MEUGA1UdHwQ+
# MDwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3Vy
# ZWRJRFJvb3RDQS5jcmwwEQYDVR0gBAowCDAGBgRVHSAAMA0GCSqGSIb3DQEBDAUA
# A4IBAQBwoL9DXFXnOF+go3QbPbYW1/e/Vwe9mqyhhyzshV6pGrsi+IcaaVQi7aSI
# d229GhT0E0p6Ly23OO/0/4C5+KH38nLeJLxSA8hO0Cre+i1Wz/n096wwepqLsl7U
# z9FDRJtDIeuWcqFItJnLnU+nBgMTdydE1Od/6Fmo8L8vC6bp8jQ87PcDx4eo0kxA
# GTVGamlUsLihVo7spNU96LHc/RzY9HdaXFSMb++hUD38dglohJ9vytsgjTVgHAID
# yyCwrFigDkBjxZgiwbJZ9VVrzyerbHbObyMt9H5xaiNrIv8SuFQtJ37YOtnwtoeW
# /VvRXKwYw02fc7cBqZ9Xql4o4rmUMYIDdjCCA3ICAQEwdzBjMQswCQYDVQQGEwJV
# UzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRy
# dXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBAhAMTWlyS5T6
# PCpKPSkHgD1aMA0GCWCGSAFlAwQCAQUAoIHRMBoGCSqGSIb3DQEJAzENBgsqhkiG
# 9w0BCRABBDAcBgkqhkiG9w0BCQUxDxcNMjMwMjIxMDEwOTA0WjArBgsqhkiG9w0B
# CRACDDEcMBowGDAWBBTzhyJNhjOCkjWplLy9j5bp/hx8czAvBgkqhkiG9w0BCQQx
# IgQgMXe5PoffFHOmR1Us0dMpHGOEJKR+A6sD/NMfzIyjYpQwNwYLKoZIhvcNAQkQ
# Ai8xKDAmMCQwIgQgx/ThvjIoiSCr4iY6vhrE/E/meBwtZNBMgHVXoCO1tvowDQYJ
# KoZIhvcNAQEBBQAEggIAHCVCdLIwdxqTSkRH+cYhAPqeS4d0c6dXV83gDRYttXPz
# vp5kCC+caQ+7vpKYhsQ4JObUaKCXjA5lG8ZhLtjohgNGcIDRG0BOyKi1wcskjnJ3
# vlxg1qvj8r17Xzwpz9GvR+al2Y9lwA7/QhmqDLtIsb3AgHnJv0GmSvIqDLfXVCWU
# Vvsh/Ewf8fQ6F0LXoC75djBXC4tzW/KXZOCrrC6DallbOCFumKUX55M/objDn0Aj
# iFw0V918ojdZpJJWzMtMV07R3yWVlUoQQVStOd79anYhrEYYhO0YUsor9L/pkKzy
# Q/945c/sNAxmpxfhHoT0bt2gTedOA6gUqAkBUYuOGJVNUDv+kfae0za9zGKbMOV/
# lrWYB1sGEHYBmhgSxXiVRKeLj1115N1tbq+rZ1ZBdHAXbQ3wwhz3G+1fQbaoa6Fj
# hRhO41W+eZajZwbhWjMjsnRgrA9QcI7s4PfbXfvbqR8u0klK6YXSkmGEkBamsb9l
# ZqVEbNouwZVVly1TazqHlOV9iGi9E1bHSpoxUrdgLSpZ9Gqo4sr2gf29HzJWgetY
# nqmJilWJclHuzBrLkWAGS+fnGO3XCp8yS3NAAAcxH1p7+KzBG+Mo6eCoUVXABx67
# u7HVXFoHY4MhXQJ/nwJf40Prb4nUyL9MGdXYltum88QjthGyftRxi9aJTzZFlK4=
# SIG # End signature block
