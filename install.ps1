<#
.SYNOPSIS
    helm pluginのセットアップ

.NOTES
    helm pluginインストーラーはWindows未対応なので、バイナリを別途インストールする
    ref: https://github.com/helm/helm/issues/7117
#>
function SetupHelmPlugins {
    helm plugin install https://github.com/databus23/helm-diff
    Invoke-WebRequest `
        https://github.com/databus23/helm-diff/releases/download/v3.9.6/helm-diff-windows-amd64.tgz `
        -OutFile "helm-diff.tgz"
    tar -xzvf "helm-diff.tgz"
    $appData = [Environment]::GetFolderPath(
        [Environment+SpecialFolder]::ApplicationData 
    )
    $dest = Join-Path -Path $appData -ChildPath "helm\plugins\helm-diff"
    Copy-Item -Path "diff" -Destination $dest -Recurse -Force
    Remove-Item -Path "diff" -Recurse -Force
    Remove-Item -Path "helm-diff.tgz" -Force
}

<#
.SYNOPSIS
    シングルバイナリのインストール

.PARAMETER url
    インストール対象のバイナリのURL

.PARAMETER binFileName
    バイナリのファイル名
#>
function InstallBin {
    param (
        [Parameter(Mandatory)][string]$url,
        [Parameter(Mandatory)][string]$binFileName,
        [string]$type = "tar"
    )
    if (-Not (Test-Path "tmp")) {
        New-Item -ItemType Directory -Path "tmp"
    }
    if ($type -eq "tar") {
        $outFile = "_tarballToInstall.tgz"
    } elseif ($type -eq "zip") {
        $outFile = "_zipToInstall.zip"
    }
    Invoke-WebRequest `
        $url `
        -OutFile $outFile
    if ($type -eq "tar") {
        tar -xzvf $outFile -C "tmp"
    } elseif ($type -eq "zip") {
        Expand-Archive -Path $outFile -DestinationPath "tmp"
    }
    Copy-Item -Path "tmp\$binFileName" -Destination "bin" -Force
    Remove-Item -Path "tmp" -Recurse -Force
    Remove-Item -Path $outFile -Force
}

if (-Not (Test-Path "bin")) {
    New-Item -ItemType Directory -Path "bin"
    $currentDir = (Get-Location).Path
    $oldPathValue = [Environment]::GetEnvironmentVariable(
        "PATH",
        [EnvironmentVariableTarget]::User
    ) 
    [Environment]::SetEnvironmentVariable(
        "PATH", 
        $oldPathValue + ";$currentDir\bin", 
        [EnvironmentVariableTarget]::User
    )
}

winget import packages.json `
    --accept-package-agreements `
    --accept-source-agreements `
    --verbose

SetupHelmPlugins

InstallBin `
    "https://github.com/helmfile/helmfile/releases/download/v0.164.0/helmfile_0.164.0_windows_amd64.tar.gz" `
    "helmfile.exe"
InstallBin `
    "https://github.com/norwoodj/helm-docs/releases/download/v1.13.1/helm-docs_1.13.1_Windows_x86_64.tar.gz" `
    "helm-docs.exe"
InstallBin `
    "https://github.com/x-motemen/ghq/releases/download/v1.6.1/ghq_windows_amd64.zip" `
    "ghq_windows_amd64\ghq.exe" `
    "zip"
