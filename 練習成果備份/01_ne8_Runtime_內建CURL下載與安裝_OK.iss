; �w�q�@�Ǳ`�q
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
; �N wget.exe ���]�i�w���ɤ�
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
  MsgBox('���b�ˬd���U����G' + InstallKey, mbInformation, MB_OK);

  if RegQueryDWordValue(HKLM, RuntimeKey, RuntimeVersionKey, Value) then
  begin
    DebugMsg := '��� DWORD �ȡG' + IntToStr(Value);
    if Value = 1 then
    begin
      Result := True;
      DebugMsg := DebugMsg + ' (�Ȥǰt)';
    end
    else
    begin
      DebugMsg := DebugMsg + ' (�Ȥ��ǰt)';
    end;
  end
  else
  begin
    DebugMsg := '����� DWORD �ȡC';
  end;

  MsgBox(DebugMsg, mbInformation, MB_OK);

  if Result then
  begin
    MsgBox('.NET 8 WindowsDesktop Runtime �w�w�ˡC', mbInformation, MB_OK);
  end
  else
  begin
    MsgBox('.NET 8 WindowsDesktop Runtime ���w�ˡC', mbInformation, MB_OK);
  end;
end;

procedure DownloadAndInstallRuntime();
var
  ResultCode: Integer;
  URL, OutputFile, TempPath: String;
  DownloadSuccess: Boolean;
begin
  MsgBox('�Y�N�}�l�U�� .NET 8 WindowsDesktop Runtime�C', mbInformation, MB_OK);
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
      MsgBox('.NET 8 WindowsDesktop Runtime �U�����\�C', mbInformation, MB_OK);
    end
    else
    begin
      MsgBox('.NET 8 WindowsDesktop Runtime �U�����ѡC���~�X�G' + IntToStr(ResultCode), mbError, MB_OK);
    end;
  end
  else
  begin
    DownloadSuccess := True;
    MsgBox('.NET 8 WindowsDesktop Runtime ���w�s�b�A�L�ݤU���C', mbInformation, MB_OK);
  end;

  if DownloadSuccess then
  begin
    Exec(OutputFile, '', '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode);
    if ResultCode = 0 then
    begin
      MsgBox('.NET 8 WindowsDesktop Runtime �w�˦��\�C', mbInformation, MB_OK);
    end
    else
    begin
      MsgBox('.NET 8 WindowsDesktop Runtime �w�˥��ѡC���~�X�G' + IntToStr(ResultCode), mbError, MB_OK);
    end;
  end;
end;

function InitializeSetup(): Boolean;
begin
  Result := True;
  if IsRuntimeInstalled() then
  begin
    MsgBox('�w������ .NET 8 WindowsDesktop Runtime �w�w�ˡC', mbInformation, MB_OK);
  end
  else
  begin
    DownloadAndInstallRuntime();
  end;
end;
