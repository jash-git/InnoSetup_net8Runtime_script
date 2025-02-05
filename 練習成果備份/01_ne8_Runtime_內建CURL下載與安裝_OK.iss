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
  RuntimeKey = 'SOFTWARE\WOW6432Node\dotnet\Setup\InstalledVersions\x64\sharedfx\Microsoft.WindowsDesktop.App';
  RuntimeVersionKey = '{#RuntimeVersion}';

function IsRuntimeInstalled: Boolean;
var
  InstallKey: String;
  Value: Cardinal;
  DebugMsg: String;
begin
  Result := False;
  InstallKey := RuntimeKey + '\' + RuntimeVersionKey;
  MsgBox('正在檢查註冊表鍵：' + InstallKey, mbInformation, MB_OK);

  if RegQueryDWordValue(HKLM, RuntimeKey, RuntimeVersionKey, Value) then
  begin
    DebugMsg := '找到 DWORD 值：' + IntToStr(Value);
    if Value = 1 then
    begin
      Result := True;
      DebugMsg := DebugMsg + ' (值匹配)';
    end
    else
    begin
      DebugMsg := DebugMsg + ' (值不匹配)';
    end;
  end
  else
  begin
    DebugMsg := '未找到 DWORD 值。';
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
  DownloadSuccess: Boolean;
begin
  MsgBox('即將開始下載 .NET 8 WindowsDesktop Runtime。', mbInformation, MB_OK);
  URL := '{#RuntimeURL}';
  TempPath := ExpandConstant('{tmp}');
  OutputFile := TempPath + '\windowsdesktop-runtime-{#RuntimeVersion}-win-x64.exe';
  DownloadSuccess := False;

  if not FileExists(OutputFile) then
  begin
    Exec(ExpandConstant('{tmp}\wget.exe'), '--no-check-certificate ' + URL + ' -O ' + OutputFile, '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode);
    if ResultCode = 0 then
    begin
      DownloadSuccess := True;
      MsgBox('.NET 8 WindowsDesktop Runtime 下載成功。', mbInformation, MB_OK);
    end
    else
    begin
      MsgBox('.NET 8 WindowsDesktop Runtime 下載失敗。錯誤碼：' + IntToStr(ResultCode), mbError, MB_OK);
    end;
  end
  else
  begin
    DownloadSuccess := True;
    MsgBox('.NET 8 WindowsDesktop Runtime 文件已存在，無需下載。', mbInformation, MB_OK);
  end;

  if DownloadSuccess then
  begin
    Exec(OutputFile, '', '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode);
    if ResultCode = 0 then
    begin
      MsgBox('.NET 8 WindowsDesktop Runtime 安裝成功。', mbInformation, MB_OK);
    end
    else
    begin
      MsgBox('.NET 8 WindowsDesktop Runtime 安裝失敗。錯誤碼：' + IntToStr(ResultCode), mbError, MB_OK);
    end;
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
