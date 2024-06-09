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


winget import packages.json `
    --accept-package-agreements `
    --accept-source-agreements `
    --verbose

SetupHelmPlugins

$oldPathValue = [Environment]::GetEnvironmentVariable(
    "PATH",
    [EnvironmentVariableTarget]::User
) 
[Environment]::SetEnvironmentVariable(
    "PATH", 
    $oldPathValue + ";$Env:LOCALAPPDATA\aquaproj-aqua\bat;$Env:LOCALAPPDATA\aquaproj-aqua\bin", 
    [EnvironmentVariableTarget]::User
)

aqua i

# dotfilesのシンボリックリンク
$dotfiles = @(".gitconfig")
$currentDir = (Get-Location).Path

foreach ($file in $dotfiles) {
    $sourcePath = Join-Path -Path $currentDir -ChildPath "$file"
    $linkPath = Join-Path -Path (Resolve-Path ~) -ChildPath "$file"
    New-Item -ItemType SymbolicLink -Path $linkPath -Target $sourcePath -Force
}
