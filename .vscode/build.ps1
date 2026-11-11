# Compile Chummer (Debug, AnyCPU) avec le MSBuild de Visual Studio Build Tools.
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
$ms = & $vswhere -products * -latest -requires Microsoft.Component.MSBuild -find 'MSBuild\**\Bin\MSBuild.exe' | Select-Object -First 1
if (-not $ms) { Write-Error 'MSBuild introuvable : installez les Build Tools (charge de travail Outils de build pour applications de bureau .NET).'; exit 1 }
Write-Host "MSBuild : $ms"
Set-Location (Join-Path $PSScriptRoot '..')
& $ms 'Chummer\Chummer.csproj' '/restore:false' '/p:Configuration=Debug' '/p:Platform=AnyCPU' '/v:m' '/nologo'
exit $LASTEXITCODE
