WSH.Echo "############################"
WSH.Echo "# _   _                    #"
WSH.Echo "# | | (_)                  #"
WSH.Echo "# | |_ _  __ _  ___ _ __   #"
WSH.Echo "# | __| |/ _` |/ _ \ '__|  #"
WSH.Echo "# | |_| | (_| |  __/ |     #"
WSH.Echo "#  \__|_|\__, |\___|_|     #"
WSH.Echo "#         __/ |            #"
WSH.Echo "#        |___/             #"
WSH.Echo "############################"
WSH.Echo ""

MAIN_DOMAIN = "REPLACE_MAIN_DOMAIN"
SERVER_IP = "REPLACE_SERVER_IP"
VERSION = "REPLACE_VERSION"

Set WshShell = CreateObject("WScript.Shell")
Set FSO = CreateObject("Scripting.FileSystemObject")
Set environmentVars = WScript.CreateObject("WScript.Shell").Environment("Process")
MAIN_DOMAIN_WITHOUT_COLON = Replace(MAIN_DOMAIN, ":", "_")
tempFolder = environmentVars("TEMP")&"\"&MAIN_DOMAIN_WITHOUT_COLON&"_frp"

url_args=WScript.Arguments(0)
port = Split(url_args, "=")(1)
computerName = WshShell.RegRead("HKLM\SOFTWARE\Microsoft\Cryptography\MachineGuid")

WSH.Echo "MachineGuid: "&computerName
WSH.Echo "tempFolder : "&tempFolder
WSH.Echo "local      : "&"127.0.0.1:"&port
WSH.Echo ""

Call createTempFiles()
Call downloadFrp()
Call startFrp()

Sub createTempFiles ()
  If Not FSO.FolderExists(tempFolder) Then
    FSO.CreateFolder(tempFolder)
  End If
End Sub


Sub downloadFrp ()
  Dim FILENAME
  If IsArm() Then
    FILENAME = "frpc_"&VERSION&"_windows_arm64.zip"
  Else
    FILENAME = "frpc_"&VERSION&"_windows_amd64.zip"
  End If
  WSH.Echo "frpc filename: "&FILENAME
  WSH.Echo ""

  ' WScript.Quit(0)

  curl = "curl.exe -o "&tempFolder&"\frpc.zip http://"&MAIN_DOMAIN&"/download/"&FILENAME
  WSH.Echo "Downloading frpc.zip..."
  WSH.Echo ""
  WshShell.Run curl, 0, True

  unzip = "powershell -command Expand-Archive -Path "&tempFolder&"\frpc.zip -DestinationPath "&tempFolder&" -Force"
  WSH.Echo "Unzip frpc.zip..."
  WSH.Echo ""
  WshShell.Run unzip, 0, True
End Sub

' Check if the CPU is ARM
Function IsArm()
  Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
  Set colItems = objWMIService.ExecQuery("Select * from Win32_Processor")
  For Each objItem in colItems
    ' WSH.Echo "Architecture: "&objItem.Architecture
    If objItem.Architecture = 12 Then
      IsArm = True
    Else
      IsArm = False
    End If
    Next
End Function

Sub OutputCustomText()
    Dim url, spacesNeeded, padding, line

    url = "https://" & computerName & "-" & port & "." & MAIN_DOMAIN
    spacesNeeded = 69 - Len(url)
    padding = String(spacesNeeded, " ")

    Dim box()
    ReDim box(17)
    
    box(0) = "  ___________________________________________________________________________  "
    box(1) = " /         _   _                                                             \ "
    box(2) = "||        | | (_)                                                            ||"
    box(3) = "||        | |_ _  __ _  ___ _ __                                             ||"
    box(4) = "||        | __| |/ _` |/ _ \ '__|                                            ||"
    box(5) = "||        | |_| | (_| |  __/ |                                               ||"
    box(6) = "||         \__|_|\__, |\___|_|.                                              ||"
    box(7) = "||                __/ |                                                      ||"
    box(8) = "||               |___/                                                       ||"
    box(9) = "||___________________________________________________________________________||"
    box(10) = "||                                                                           ||"
    box(11) = "||   You can access your service through the following address:              ||"
    box(12) = "||      " & url & padding & "||"
    box(13) = "||                                                                           ||"
    box(14) = "||   to stop frpc, please press ^C.                                          ||"
    box(15) = "||                                                                           ||"
    box(16) = "||   Enjoy!                                                                  ||"
    box(17) = " \___________________________________________________________________________/ "

    For Each line In box
        WScript.Echo line
    Next
End Sub

Sub startFrp ()
  startCmd = "cmd /c "&tempFolder&"\frpc.exe http --server-addr="&SERVER_IP&" --server-port=7000 --proxy-name="&computerName&"-"&port&" --local-port="&port&" --sd="&computerName&"-"&port

  ' #############################
  Set objFile = FSO.CreateTextFile(tempFolder&"\start.bat", True)
  objFile.WriteLine startCmd
  objFile.Close
  ' #############################


  WSH.Echo "Start frpc.exe..."
  Call OutputCustomText()

  Set oExec = WshShell.Exec(startCmd)
  Set oStdOut = oExec.StdOut
  WSH.Echo "frpc.exe output:"
  While Not oStdOut.AtEndOfStream
    sLine = oStdOut.ReadLine
    WScript.Echo sLine
  Wend
End Sub
