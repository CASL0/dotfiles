@echo off

@REM 実行バイナリ用のディレクトリ
if not exist "bin" (
    mkdir "bin"
    setx PATH "%PATH%;%CD%\bin"
)

winget import packages.json --accept-package-agreements --accept-source-agreements --verbose

@REM helm plugin
@REM helm pluginインストーラーはWindows未対応なので、バイナリを別途インストールする
@REM ref: https://github.com/helm/helm/issues/7117
helm plugin install https://github.com/databus23/helm-diff
curl -Lo helm-diff.tgz https://github.com/databus23/helm-diff/releases/download/v3.9.6/helm-diff-windows-amd64.tgz
tar -xzvf helm-diff.tgz
xcopy /E /Y diff %APPDATA%\helm\plugins\helm-diff 
rmdir /S /Q diff 
del /Q helm-diff.tgz

@REM helmfile
curl -Lo helmfile.tgz https://github.com/helmfile/helmfile/releases/download/v0.164.0/helmfile_0.164.0_windows_amd64.tar.gz
if not exist "tmp" mkdir "tmp"
tar -xzvf helmfile.tgz -C tmp
copy /Y tmp\helmfile.exe bin 
rmdir /S /Q tmp
del /Q helmfile.tgz
