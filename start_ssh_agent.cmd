@echo off

rem Delayed expansion causes !variable! to be re-interpreted each time it is encountered
setlocal EnableDelayedExpansion

rem Is ssh-agent.exe currently running?
tasklist /fi "IMAGENAME eq ssh-agent.exe" | find /i /n "ssh-agent.exe" >NUL

if errorlevel 1 (
    rem No - need to run it

    rem Set the location of ssh-agent.exe here
    rem Run ssh-agent.exe and pipe the output to the file .ssh_agent_info
    "%USERPROFILE%\AppData\Local\Programs\Git\usr\bin\ssh-agent.exe" -c >".ssh_agent_info"

    IF errorlevel 1 (
        echo "Couldn't start ssh-agent"
        exit /b 1
    )

    rem Set environment variables so that SSH applications such as ssh-add.exe
    rem know how to to connect to the SSH agent
    for /f "eol=; tokens=2,3*" %%i in (.ssh_agent_info) do (
        if "%%i" == "SSH_AUTH_SOCK" (
            set "SSH_AUTH_SOCK=%%j"
        )

        if "%%i" == "SSH_AGENT_PID" (
            set "SSH_AGENT_PID=%%j"
        )
    )

    rem Remove semicolon at the end
    set "SSH_AUTH_SOCK=!SSH_AUTH_SOCK:~0,-1!"
    set "SSH_AGENT_PID=!SSH_AGENT_PID:~0,-1!"

    echo SSH_AUTH_SOCK=!SSH_AUTH_SOCK! >.ssh_agent_info
    echo SSH_AGENT_PID=!SSH_AGENT_PID! >>.ssh_agent_info
    echo export SSH_AUTH_SOCK >>.ssh_agent_info
    echo export SSH_AGENT_PID >>.ssh_agent_info
)

endlocal
