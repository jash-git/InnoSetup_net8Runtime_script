; 定義一些常量
#define RuntimeVersion "8.0.12"
#define RuntimeURL "https://download.visualstudio.microsoft.com/download/pr/f1e7ffc8-c278-4339-b460-517420724524/f36bb75b2e86a52338c4d3a90f8dac9b/windowsdesktop-runtime-8.0.12-win-x64.exe"

[Setup]
AppName=YourAppName
AppVersion=1.0
DefaultDirName={pf}\YourAppName
DefaultGroupName=YourAppName
OutputBaseFilename=setup
Compression=lzma
SolidCompression=yes

[Files]
; 將 wget.exe 打包進安裝檔中
Source: "wget.exe"; DestDir: "{tmp}"; Flags: ignoreversion

[Code]
const
  RuntimeKeyBase1 = 'SOFTWARE\WOW6432Node\dotnet\Setup\InstalledVersions\x64\sharedfx\Microsoft.WindowsDesktop.App';
  RuntimeKeyBase2 = 'SOFTWARE\dotnet\Setup\InstalledVersions\x64\sharedfx\Microsoft.WindowsDesktop.App';
  RuntimeVersionKey = '{#RuntimeVersion}';

function IsRuntimeInstalled: Boolean;
var
  InstallKey1, InstallKey2: String;
  InstallLocation, Version, DebugMsg: String;
begin
  Result := False;
  InstallKey1 := RuntimeKeyBase1 + '\' + RuntimeVersionKey;
  InstallKey2 := RuntimeKeyBase2 + '\' + RuntimeVersionKey;
  MsgBox('正在檢查註冊表鍵：' + InstallKey1, mbInformation, MB_OK);

  if RegQueryStringValue(HKLM, InstallKey1, 'InstallLocation', InstallLocation) then
  begin
    DebugMsg := '找到安裝位置：' + InstallLocation;
    if InstallLocation <> '' then
    begin
      Result := True;
    end
    else
    begin
      DebugMsg := DebugMsg + ' (InstallLocation 為空)';
    end;
  end
  else if RegQueryStringValue(HKLM, InstallKey1, 'Version', Version) then
  begin
    DebugMsg := '找到版本：' + Version;
    if Version <> '' then
    begin
      Result := True;
    end
    else
    begin
      DebugMsg := DebugMsg + ' (Version 為空)';
    end;
  end
  else
  begin
    DebugMsg := '未找到 InstallLocation 或 Version 值在 ' + InstallKey1 + '。';
  end;

  if not Result then
  begin
    MsgBox('正在檢查註冊表鍵：' + InstallKey2, mbInformation, MB_OK);

    if RegQueryStringValue(HKLM, InstallKey2, 'InstallLocation', InstallLocation) then
    begin
      DebugMsg := '找到安裝位置：' + InstallLocation;
      if InstallLocation <> '' then
      begin
        Result := True;
      end
      else
      begin
        DebugMsg := DebugMsg + ' (InstallLocation 為空)';
      end;
    end
    else if RegQueryStringValue(HKLM, InstallKey2, 'Version', Version) then
    begin
      DebugMsg := '找到版本：' + Version;
      if Version <> '' then
      begin
        Result := True;
        MsgBox('.NET 8 WindowsDesktop Runtime 已安裝，版本：' + Version, mbInformation, MB_OK);
      end
      else
      begin
        DebugMsg := DebugMsg + ' (Version 為空)';
      end;
    end
    else
    begin
      DebugMsg := DebugMsg + ' 未找到 InstallLocation 或 Version 值在 ' + InstallKey2 + '。';
    end;
  end;

  MsgBox(DebugMsg, mbInformation, MB_OK);

  if Result then
  begin
    MsgBox('.NET 8 WindowsDesktop Runtime 已安裝。', mbInformation, MB_OK);
  end
  else
  begin
    MsgBox('.NET 8 WindowsDesktop Runtime 未安裝。', mbInformation, MB_OK);
  end;
end;

procedure DownloadAndInstallRuntime();
var
  ResultCode: Integer;
  URL, OutputFile, TempPath: String;
begin
  MsgBox('即將開始下載 .NET 8 WindowsDesktop Runtime。', mbInformation, MB_OK);
  URL := '{#RuntimeURL}';
  TempPath := ExpandConstant('{tmp}');
  OutputFile := TempPath + '\windowsdesktop-runtime-{#RuntimeVersion}-win-x64.exe';
  if not FileExists(OutputFile) then
  begin
    Exec(ExpandConstant('{tmp}\wget.exe'), URL + ' -O ' + OutputFile, '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode);
  end;
  if FileExists(OutputFile) then
  begin
    Exec(OutputFile, '', '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode);
  end;
end;

function InitializeSetup(): Boolean;
begin
  Result := True;
  if IsRuntimeInstalled() then
  begin
    MsgBox('已偵測到 .NET 8 WindowsDesktop Runtime 已安裝。', mbInformation, MB_OK);
  end
  else
  begin
    DownloadAndInstallRuntime();
  end;
end;
