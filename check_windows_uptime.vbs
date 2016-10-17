' ================================================================================================== 
' ================================================================================================== 
' Original script by Harold "Waldo" Grunenwald (waldo@ge.com, harold.grunenwald@gmail.com) 
'
' Hacked for Nagios.
'
' ================================================================================================== 
' Usage: cscript //NoLogo system_uptime.vbs warningdays criticaldays
'
' ================================================================================================== 
 
 
' Inital Values 
uptimeDays    = 0 
uptimeHrs    = 0 
uptimeMin    = 0 
strComputer = "localhost"

 
' ===Establish target machine(s)=== 
If Wscript.Arguments.Count <> 2 Then 
	Wscript.Echo "UNKNOWN: Wrong number of arguments. Required: warning and critical."
	WScript.Quit codeUnknown
End If 

Set objArgs = WScript.Arguments
warningTreshold = objArgs(0)
crtiticalTreshold = objArgs(1)
 
fnUptime(strComputer) 
 
 
' ===Really the only way to get the uptime=== 
Function fnUptime(strComputer) 
    Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2") 
    Set colOperatingSystems = objWMIService.ExecQuery("Select * from Win32_OperatingSystem") 
    For Each objOS in colOperatingSystems 
        dtmBootup = objOS.LastBootUpTime 
        dtmLastBootupTime = WMIDateStringToDate(dtmBootup) 
        dtmSystemUptime = DateDiff("n", dtmLastBootUpTime, Now)        'uptime in minutes 
    Next 
     
    timeConversion(dtmSystemUptime)        'convert to days, hours, & minutes 
End Function 
 
 
' ===Convert the WMI date string to Minutes=== 
' Microsoft date cleanup code, bless 'em for doing it 
 
' TODO: 
' Fix this function on Win2k machines 
' Type Coercion (on CDate) 
' http://www.microsoft.com/technet/scriptcenter/guide/sas_vbs_eves.mspx?mfr=true 
Function WMIDateStringToDate(dtmBootup) 
    WMIDateStringToDate = CDate(Mid(dtmBootup, 5, 2) & "/" & _ 
        Mid(dtmBootup, 7, 2) & "/" & Left(dtmBootup, 4) _ 
            & " " & Mid (dtmBootup, 9, 2) & ":" & _ 
                Mid(dtmBootup, 11, 2) & ":" & Mid(dtmBootup,13, 2)) 
End Function 
 
 
' ===Convert the time in Minutes to Days, Hours, & Minutes=== 
Function timeConversion(dtmSystemUptime) 
' Set some variables 
    uptimeMin = dtmSystemUptime 
 
' Convert to hours 
    if uptimeMin >= 60 then 
        uptimeHrs = Int(uptimeMin / 60)    'convert to integer 
        uptimeMin = (uptimeMin mod 60)        'final value for minutes 
    end if 
 
' Convert to Days 
    if uptimeHrs >= 24 then 
        uptimeDays = Int(uptimeHrs / 24)    'convert to integer 
        uptimeHrs = (uptimeHrs mod 24)        'final value for hours 
    end if 
 
 
' ===Output=== 
'    wscript.echo 
'   wscript.echo strComputer & " has been up for " & dtmSystemUptime & " minutes, which comes out to:" 
'    wscript.echo uptimeDays & " Days" 
'    wscript.echo uptimeHrs & " Hours" 
'    wscript.echo uptimeMin & " Minutes" & vbCrLf 

		if uptimeDays <= warningTreshold then
			wscript.echo "OK (" & uptimeDays& " days)"
			wscript.quit(0)
		else
			if uptimeDays <= criticalTreshold then
				wscript.echo "Warning: (" & uptimeDays& " days)"
				wscript.quit(1)
			else
				wscript.echo "Critical: (" & uptimeDays& " days)"
				wscript.quit(3)
			end if
		end if

End Function
