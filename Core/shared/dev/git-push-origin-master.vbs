Set WinScriptHost = CreateObject("WScript.Shell")
WinScriptHost.CurrentDirectory = "D:\em\Core"
Return = WinScriptHost.Run("git push -u origin master", 0, true)
Set WinScriptHost = Nothing
