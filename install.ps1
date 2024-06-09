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
