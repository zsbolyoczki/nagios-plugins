'
' Checks all local disks and returns usage in percentage.
' Alerting is based on limits given as arg1 (warning) and arg2 (critical).
'
' Runs on: monitored nodes
' Usage: cscript.exe //NoLogo check_win_disk.vbs WARNINGLIMIT CRITICALLIMIT
'
' zsbolyoczki - 2016.10.10.
'

strComputer = "." 
Set objWMIService = GetObject("winmgmts:" _ 
    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2") 
 
Set colDisks = objWMIService.ExecQuery _ 
    ("Select * from Win32_LogicalDisk") 


codeOK=0
codeWarning=1
codeCritical=2
codeUnknown=3

returnMsg=""
returnCode=codeOK
allOK=1


Set objArgs = Wscript.Arguments

if objArgs.Count <> 2  Then
	Wscript.Echo "UNKNOWN: Missing limit parameters."
	WScript.Quit codeUnknown
End If

wLimit=int(objArgs(0))
cLimit=int(objArgs(1))

if wLimit >= cLimit Then
	Wscript.Echo "UNKNOWN: Warning limit is greater or equal to critical limit."
	WScript.Quit codeUnknown
End If

 
For Each objDisk in colDisks 
    Select Case objDisk.DriveType 
        Case 3 
						diskUsage=int(((objDisk.Size - objDisk.FreeSpace) * 100) / objDisk.Size)
						If diskUsage >= cLimit Then
							allOk=0
							if Len(returnMsg) = 0 Then
								returnMsg="Critical: " & objDisk.DeviceID & "=" & diskUsage & "%"
							Else
								returnMsg=returnMsg & " | Critical: " & objDisk.DeviceID & " -- " & diskUsage & "%"
							End If	
							returnCode = codeCritical
						Else
            	If diskUsage >= wLimit Then

								allOk=0
								if Len(returnMsg) = 0 Then
									returnMsg="Warning: " & objDisk.DeviceID & "=" & diskUsage & "%"
								Else
									returnMsg=returnMsg & " | Warning: " & objDisk.DeviceID & " -- " & diskUsage & "%"
								End If	

								if returnCode < codeCritical Then
									returnCode = codeWarning
								End if

							End If
						End If

    End Select 
Next 

if allOK = 1 Then
	returnMsg="All disks are OK"
	returnCode=0
End If

Wscript.Echo returnMsg
WScript.Quit returnCode
