@echo off
setlocal
rem ------------------------------------------------------------------
rem  Fabrique dist\ChummerRoll20_AAAAMMJJ.zip a envoyer aux joueurs.
rem  Contenu : le dossier bin SANS l'ancien ChummerGenSR4.exe, SANS les
rem  .pdb et SANS le dossier saves (51 Mo d'exemples) ; un dossier saves
rem  vide et un LISEZMOI.txt sont ajoutes.
rem  Pre-requis : avoir compile (Ctrl+Maj+B) -> bin\ChummerGenSR4_Debug.exe
rem ------------------------------------------------------------------
cd /d "%~dp0"
set "SRC=%~dp0bin"
if not exist "%SRC%\ChummerGenSR4_Debug.exe" goto :noexe

for /f %%d in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd"') do set "STAMP=%%d"
set "STAGE=%TEMP%\ChummerRoll20_stage"
set "OUT=%~dp0dist\ChummerRoll20_%STAMP%.zip"

if exist "%STAGE%" rmdir /s /q "%STAGE%"
mkdir "%STAGE%"
if not exist "%~dp0dist" mkdir "%~dp0dist"
if exist "%OUT%" del "%OUT%"

echo Copie des fichiers...
robocopy "%SRC%" "%STAGE%" /E /XD saves /XF ChummerGenSR4.exe *.pdb *.vshost.exe* /NFL /NDL /NJH /NJS /NP
if errorlevel 8 goto :copyfail
mkdir "%STAGE%\saves"

> "%STAGE%\LISEZMOI.txt" echo Chummer 4 - version de test avec export Roll20
>> "%STAGE%\LISEZMOI.txt" echo.
>> "%STAGE%\LISEZMOI.txt" echo 1. Avant de decompresser le zip : clic droit sur le zip, Proprietes, cocher "Debloquer", OK.
>> "%STAGE%\LISEZMOI.txt" echo 2. Decompresser le dossier complet, puis lancer ChummerGenSR4_Debug.exe.
>> "%STAGE%\LISEZMOI.txt" echo    Si Windows affiche "Windows a protege votre PC" : Informations complementaires, puis Executer quand meme.
>> "%STAGE%\LISEZMOI.txt" echo    Il faut .NET Framework 4.8 (present sur Windows 11 et Windows 10 a jour).
>> "%STAGE%\LISEZMOI.txt" echo 3. Options : decocher la mise a jour automatique.
>> "%STAGE%\LISEZMOI.txt" echo 4. Ouvrir votre personnage en mode Carriere : Fichier, Exporter vers Roll20.
>> "%STAGE%\LISEZMOI.txt" echo    Copier dans le presse-papiers : coller ensuite dans le handout "Import NPC" de Roll20 (ou envoyer le texte au MJ).
>> "%STAGE%\LISEZMOI.txt" echo    Enregistrer un fichier : envoyer le .json au MJ.
>> "%STAGE%\LISEZMOI.txt" echo 5. Signaler au MJ toute erreur a l'ouverture d'un .chum ou tout JSON incomplet.

echo Creation du zip...
where tar >nul 2>nul
if errorlevel 1 goto :psZip
tar -a -c -f "%OUT%" -C "%STAGE%" .
goto :zipDone
:psZip
powershell -NoProfile -Command "Compress-Archive -Path '%STAGE%\*' -DestinationPath '%OUT%'"
:zipDone
if not exist "%OUT%" goto :zipfail

rmdir /s /q "%STAGE%"
echo.
echo Zip pret : %OUT%
for %%f in ("%OUT%") do echo Taille : %%~zf octets
echo Penser a retirer de bin\settings tes propres fichiers si tu ne veux pas les partager.
echo.
pause
exit /b 0

:noexe
echo ERREUR : bin\ChummerGenSR4_Debug.exe introuvable. Compile d'abord avec Ctrl+Maj+B.
pause
exit /b 1

:copyfail
echo ERREUR pendant la copie des fichiers.
pause
exit /b 1

:zipfail
echo ERREUR : le zip n'a pas ete cree.
pause
exit /b 1
