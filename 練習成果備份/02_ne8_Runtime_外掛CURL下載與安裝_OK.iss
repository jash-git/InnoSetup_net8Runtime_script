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
; 將 curl.exe 和 curl-ca-bundle.crt 打包進安裝檔中
Source: "curl.exe"; DestDir: "{tmp}"; Flags: ignoreversion
Source: "curl-ca-bundle.crt"; DestDir: "{tmp}"; Flags: ignoreversion

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

function CopyCurlFilesToTemp(): Boolean;
begin
  Result := False;
  if FileExists(ExpandConstant('{tmp}\curl.exe')) and FileExists(ExpandConstant('{tmp}\curl-ca-bundle.crt')) then
  begin
    MsgBox('curl.exe 和 curl-ca-bundle.crt 已成功複製到 {tmp} 資料夾。', mbInformation, MB_OK);
    Result := True;
  end
  else
  begin
    MsgBox('curl.exe 或 curl-ca-bundle.crt 未成功複製到 {tmp} 資料夾。', mbError, MB_OK);
  end;
end;

procedure ExtractCurlFiles();
begin
  ExtractTemporaryFile('curl.exe');
  ExtractTemporaryFile('curl-ca-bundle.crt');
end;

procedure DownloadAndInstallRuntime();
var
  ResultCode: Integer;
  URL, TempPath: String;
  DownloadSuccess: Boolean;
begin
  MsgBox('即將開始下載 .NET 8 WindowsDesktop Runtime。', mbInformation, MB_OK);
  URL := '{#RuntimeURL}';
  TempPath := ExpandConstant('{tmp}');
  DownloadSuccess := False;

  if CopyCurlFilesToTemp() then
  begin
    Exec(TempPath + '\curl.exe', '-L -O ' + URL + ' --cacert ' + TempPath + '\curl-ca-bundle.crt', TempPath, SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode);
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
    Exit; // 終止安裝過程
  end;

  if DownloadSuccess then
  begin
    Exec(TempPath + '\windowsdesktop-runtime-{#RuntimeVersion}-win-x64.exe', '', '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode);
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
  
  ExtractCurlFiles();
  
  if not CopyCurlFilesToTemp() then
  begin
    MsgBox('無法複製 curl 文件到 {tmp} 資料夾。', mbError, MB_OK);
    Result := False;
    Exit;
  end;

  if IsRuntimeInstalled() then
  begin
    MsgBox('已偵測到 .NET 8 WindowsDesktop Runtime 已安裝。', mbInformation, MB_OK);
  end
  else
  begin
    DownloadAndInstallRuntime();
  end;
end;
