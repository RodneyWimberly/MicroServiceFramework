Set WinScriptHost = CreateObject("WScript.Shell")
WinScriptHost.CurrentDirectory = "D:\\em\\Core"
Return = WinScriptHost.Run("git add .", 0, true)
Return = WinScriptHost.Run("git commit -a -m ""Automated commit by git-commit-drafts.vbs on " & FormatDateTime(Now(), 2) & " at " & FormatDateTime(Now(), 3) & ".", 0, true)
Set WinScriptHost = Nothing
MsgBox "MicroServiceFramework changes were committed to the DeployCore branch of the repository", VBOKOnly + VBInformation, "GitHub Notification"
