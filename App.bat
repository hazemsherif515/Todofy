@echo off
setlocal EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do  rem"') do (
	set "DEL=%%a"
)
for /f %%A in ('wmic os get LocalDateTime ^| find "."') do set "dt=%%A"
set "today=!dt:~0,4!!dt:~4,2!!dt:~6,2!"

:Main
goto :mainMenu

:Flush
cls
goto :EOF

:mainMenu
call :titleScreen
call :colorEcho 0e "1-Add new tasks"
echo.
call :colorEcho 0b "2-View tasks"
echo.
call :colorEcho 0a "3-Mark completed tasks"
echo.
call :colorEcho 0c "4-Delete tasks"
echo.
call :colorEcho 0d "5-Search tasks"
echo.
call :colorEcho 09 "6-Clear tasks"
echo.
call :colorEcho 02 "7-Exit"
echo.
call :lastBorder
set /p "var=Select option number : "

if "%var%" == "1" (
	call :addTasks
) else (
	if "%var%" == "2" (
		call :viewTasks
	) else (
		if "%var%" == "3" (
			call :markTasks
		) else (
			if "%var%" == "4" (
				call :deleteTask
			) else (
				if "%var%" == "5" (
					call :searchTasks
				) else (
					if "%var%" == "6" (
						call :clearTasks
					) else (
						if "%var%" == "7" (
							Exit
						) else (
							echo Invalid number
						)
					)
				)	
			)
		)
	)
)
goto :EOF

:titleScreen
cls
echo ==============================
echo             Todofy
echo ==============================
goto :EOF

:lastBorder
echo ==============================
goto :EOF

:addTasks
call :titleScreen
::count number of lines for ID
set "file=%~dp0todo.txt"
set /a id=0
for /f %%A in ('find /c /v "" ^< "%file%"') do set /a id=%%A+1

::task format
echo.
echo Task format : ID^|Status^|Task Description^|Due Date^|Priority
echo.
call :lastBorder

::get task inputs
set /p "description=Enter task description : "
set /p "date=Enter due date(YYYY-MM-DD) : "
set /p "priority=Enter task priority(Low-Medium-High) : "
for /f %%P in ('powershell -command "$input = '%priority%'; $input.ToLower()"') do set "priority=%%P"

::append
echo !id!^|[_]^|!description!^|!date!^|!priority! >> "%~dp0todo.txt"

echo Task added with ID = %id%
Pause
call :fixFormatting2
goto :mainMenu

:viewTasks
setlocal enabledelayedexpansion
call :fixFormatting
call :titleScreen
set "file=%~dp0todo.txt"
for /F "usebackq tokens=1,2,3,4,5 delims=|" %%A in ("%file%") do (
	<nul set /p="%%A | ["
	echo %%B | findstr /i "X" >nul
	if not errorlevel 1 (
		call :colorEcho 0c "X"
	) else (
		<nul set /p="_" 
	)
	<nul set /p="] | %%C | "
	
	set "d=%%D"
	set "dueDate=!d:-=!"
	if !dueDate! LSS !today! (
		call :colorEcho 0c !d! 
	) else (
		if !dueDate! == !today! (
			call :colorEcho 0e !d!  
		) else (
			call :colorEcho 0a !d!  
		)
	)
	
	<nul set /p=" | "
	
	if "%%E"=="high" (
		call :colorEcho 0c "high"
	) else (
		if "%%E"=="medium" (
			call :colorEcho 0e "medium"
		) else (
			if "%%E"=="low" (
				call :colorEcho 0a "low"
			) else (
				echo %%E
			)
		)
	)
	echo.
)
call :lastBorder
endlocal
pause
goto :mainMenu

:deleteTask
call :titleScreen
set "file=%~dp0todo.txt"
for /F "usebackq tokens=1,2,3,4,5 delims=|" %%A in ("%file%") do (
	<nul set /p="%%A | ["
	echo %%B | findstr /i "X" >nul
	if not errorlevel 1 (
		call :colorEcho 0c "X"
	) else (
		<nul set /p="_" 
	)
	<nul set /p="] | %%C | "
	
	set "d=%%D"
	set "dueDate=!d:-=!"
	if !dueDate! LSS !today! (
		call :colorEcho 0c !d! 
	) else (
		if !dueDate! == !today! (
			call :colorEcho 0e !d!  
		) else (
			call :colorEcho 0a !d!  
		)
	)
	
	<nul set /p=" | "
	
	if "%%E"=="high" (
		call :colorEcho 0c "high"
	) else (
		if "%%E"=="medium" (
			call :colorEcho 0e "medium"
		) else (
			if "%%E"=="low" (
				call :colorEcho 0a "low"
			) else (
				echo %%E
			)
		)
	)
	echo.
)
call :lastBorder
set /p "delID=Enter the ID you want to delete : "
set "tempfile=%~dp0temp_todo.txt"
> "%tempfile%" (
    for /f "usebackq tokens=1* delims=|" %%A in ("%file%") do (
        set "id=%%A"
        set "rest=%%B"

        if not "!id!"=="%delID%" (
            echo %%A^|%%B
        )
    )
)
move /Y "%tempFile%" "%file%" >nul
call :fixFormatting
goto :mainMenu

:fixFormatting
setlocal enabledelayedexpansion
set "file=%~dp0todo.txt"
set "tempfile=%~dp0temp_todo.txt"
set /a counter=1
break > "%tempfile%"

REM Process each line and fix formatting
for /f "usebackq tokens=1,2,3,4,5 delims=|" %%A in ("%file%") do (
    set "id=%%A"
    set "b=%%B"
    set "c=%%C"
    set "d=%%D"
    set "e=%%E"

    REM Trim each field
    for %%X in (b c d e) do (
        for /f "tokens=* delims= " %%Y in ("!%%X!") do set "%%X=%%Y"
        call :TrimTrailing "!%%X!" trimmed
        set "%%X=!trimmed!"
    )
	
	REM === Fix date format to YYYY-MM-DD ===
	for /f "tokens=1-3 delims=-" %%D in ("!d!") do (
		set /a yyyy=%%D
		set /a mm=%%E
		set /a dd=%%F
	)
	set "mm=0!mm!"
	set "dd=0!dd!"
	set "d=!yyyy!-!mm:~-2!-!dd:~-2!"

    echo !counter!^|!b!^|!c!^|!d!^|!e!>> "%tempfile%"
    set /a counter+=1
)

move /Y "%tempfile%" "%file%" >nul
endlocal
goto :EOF

:TrimTrailing
setlocal enabledelayedexpansion
set "str=%~1"
:trimLoop
set "prev=!str!"
set "str=!str: =!"
if not "!str!"=="!prev!" goto trimLoop
endlocal & set "%~2=%str%"
goto :eof


:markTasks
setlocal enabledelayedexpansion
call :titleScreen
set "file=%~dp0todo.txt"
set "tempfile=%~dp0temp_todo.txt"
break > "%tempfile%"
for /F "usebackq tokens=1,2,3,4,5 delims=|" %%A in ("%file%") do (
	<nul set /p="%%A | ["
	echo %%B | findstr /i "X" >nul
	if not errorlevel 1 (
		call :colorEcho 0c "X"
	) else (
		<nul set /p="_" 
	)
	<nul set /p="] | %%C | "
	
	set "d=%%D"
	set "dueDate=!d:-=!"
	if !dueDate! LSS !today! (
		call :colorEcho 0c !d! 
	) else (
		if !dueDate! == !today! (
			call :colorEcho 0e !d!  
		) else (
			call :colorEcho 0a !d!  
		)
	)
	
	<nul set /p=" | "
	
	if "%%E"=="high" (
		call :colorEcho 0c "high"
	) else (
		if "%%E"=="medium" (
			call :colorEcho 0e "medium"
		) else (
			if "%%E"=="low" (
				call :colorEcho 0a "low"
			) else (
				echo %%E
			)
		)
	)
	echo.
)
call :lastBorder
echo Note : if you want to go back type 0!
set /p "markID=Enter the ID you want to mark : "
if "%markID%"=="0" (
	goto :mainMenu
)
    for /f "usebackq tokens=1,2,3,4,5 delims=|" %%A in ("%file%") do (
        set "id=%%A"
        set "b=%%B"
        set "c=%%C"
        set "d=%%D"
        set "e=%%E"
		setlocal EnableDelayedExpansion
        if "!id!"=="%markID%" (
            if "!b!"=="[X]" (
				echo !id!^|[_]^|!c!^|!d!^|!e! >> "%tempfile%"
			) else (
				echo !id!^|[X]^|!c!^|!d!^|!e! >> "%tempfile%"
			) 
        ) else (
            echo !id!^|!b!^|!c!^|!d!^|!e! >> "%tempfile%"
			REM echo !id!^|!b!^|!c!^|!d!^|!e! 
        )
		endlocal
    )
move /Y "%tempfile%" "%file%" >nul
call :fixFormatting
endlocal
goto :mainMenu

:searchTasks
call :titleScreen
set "file=%~dp0todo.txt"
setlocal EnableDelayedExpansion
set "keyword="
set /p "keyword=Enter search keyword: "
echo.
echo Matching tasks for "!keyword!":
call :lastBorder

for /f "usebackq tokens=1,2,3,4,5 delims=|" %%A in ("%file%") do (
    set "id=%%A"
    set "status=%%B"
    set "description=%%C"
    set "dueDate=%%D"
    set "priority=%%E"
    
    :: Search in description, due date, and priority
    set "found=0"
	echo !description! | findstr /i "!keyword!" >nul
    if "!errorlevel!"=="0" ( 
		set "found=1"
    )
    echo !dueDate! | findstr /i "!keyword!" >nul
    if "!errorlevel!"=="0" (
		set "found=1"
    )
    echo !priority! | findstr /i "!keyword!" >nul
    if "!errorlevel!"=="0" (
		set "found=1"
	)
    :: If found, display the whole task
    if "!found!"=="1" (
        REM echo !id! ^| !status! ^| !description! ^| !dueDate! ^| !priority!
		<nul set /p="%%A | ["
		echo %%B | findstr /i "X" >nul
		if not errorlevel 1 (
			call :colorEcho 0c "X"
		) else (
			<nul set /p="_" 
		)
		<nul set /p="] | %%C | "
		
		set "d=%%D"
		set "dueDate=!d:-=!"
		if !dueDate! LSS !today! (
			call :colorEcho 0c !d! 
		) else (
			if !dueDate! == !today! (
				call :colorEcho 0e !d!  
			) else (
				call :colorEcho 0a !d!  
			)
		)
		
		<nul set /p=" | "
		
		if "%%E"=="high" (
			call :colorEcho 0c "high"
		) else (
			if "%%E"=="medium" (
				call :colorEcho 0e "medium"
			) else (
				if "%%E"=="low" (
					call :colorEcho 0a "low"
				) else (
					echo %%E
				)
			)
		)
		echo.
    )
)

call :lastBorder
endlocal
pause
goto :mainMenu

:clearTasks
call :titleScreen
set "file=%~dp0todo.txt"
break > "%file%"
for /f %%A in ('find /c /v "" ^< "%file%"') do set lineCount=%%A
if "%lineCount%"=="0" (
    echo The todo list is now cleared.
) else (
    echo Failed to clear the todo list.
)
call :lastBorder
pause
goto :mainMenu

::coloring of words 
:colorEcho
if "%~2"=="" (
    echo(
    goto :EOF
)
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1
goto :EOF

:getCurrentDate
for /f %%A in ('wmic os get LocalDateTime ^| find "."') do set "dt=%%A"
set "today=!dt:~0,4!!dt:~4,2!!dt:~6,2!"
set "YYYY=%dt:~0,4%"
set "MM=%dt:~4,2%"
set "DD=%dt:~6,2%"
set "currentDate=%YYYY%-%MM%-%DD%"
echo %currentDate%
goto :EOF
