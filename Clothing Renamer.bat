@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION


:: Check if I've been opened with anything
IF "%~1" == "" GOTO :ERROR_NOFOLDER


:: Environment variables
FOR %%I IN ("%~1") DO SET target_foldername=%%~nxI
SET /A total_filecount = 0
SET /A renamed_filecount = 0
SET /A skipped_filecount = 0
SET /A backup_foldercount = 0


:: Find out how many files would be affected
FOR /F "delims=|" %%D IN ('DIR /A:D /B "%~1"') DO (
    FOR /F "delims=|" %%F IN ('DIR /B "%~1\%%D"') DO (
        SET /A total_filecount += 1
    )
)


:: No files detected
IF %total_filecount% EQU 0 (
    CLS
    ECHO You told me to convert "%~1"
    ECHO That directory does not contain anything though.
    PAUSE
    EXIT
)


:: Main menu thing
:MAIN_MENU
CLS
ECHO You told me to convert "%~1"
ECHO This will affect %total_filecount% file(s).
ECHO.
ECHO Please choose one of the options below:
ECHO 1) Make backup before renaming
ECHO 2) Rename original files
ECHO 3) Cancel
CHOICE /C 123 /N
IF %errorlevel% == 1 GOTO :COPY_FOLDER
IF %errorlevel% == 2 GOTO :RENAME_CONFIRMATION
IF %errorlevel% == 3 GOTO :CANCEL


:: Copy folder (check if copy already exists)
:COPY_FOLDER
CLS
IF EXIST "%~1_BAK_%backup_foldercount%\" (
    CLS
    SET /A backup_foldercount += 1
    GOTO :COPY_FOLDER
) ELSE (
    ROBOCOPY "%~1" "%~1_BAK_%backup_foldercount%" /E /NS /NC /NFL
    GOTO :RENAME
)


:: Asking for rename confirmation
:RENAME_CONFIRMATION
CLS
ECHO Are you sure you want to rename the original files? This can not be undone!
ECHO.
ECHO 1) Yes I'm sure!
ECHO 2) No, abort.
CHOICE /C 12 /N
IF %errorlevel% == 1 GOTO :RENAME
IF %errorlevel% == 2 GOTO :MAIN_MENU


:: Rename
:RENAME
CLS
ECHO Renaming files, please wait...
FOR /F "delims=|" %%D IN ('DIR /A:D /B "%~1"') DO (
    FOR /F "delims=|" %%F IN ('DIR /B "%~1\%%D"') DO (
        ECHO %%F | FINDSTR "%%D" > NUL
        IF errorlevel 1 (
            RENAME "%~1\%%D\%%F" "%%D^%%F"
            SET /A renamed_filecount += 1
        ) ELSE (
            SET /A skipped_filecount += 1
        )
    )
)
CLS
ECHO Successfully renamed %renamed_filecount% file(s).
ECHO %skipped_filecount% were skipped.
PAUSE
EXIT


:: Cancel
:CANCEL
CLS
ECHO Task failed successfully.
PAUSE
EXIT


:: I wasn't opened with a folder.
:ERROR_NOFOLDER
CLS
ECHO You have to drag and drop the 'stream' folder onto me,
ECHO otherwise I can't work. Sorry for the inconvenience.
PAUSE
EXIT