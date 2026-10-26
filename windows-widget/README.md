# 핑크모도로 트레이 위젯 (Windows)

작업표시줄 트레이(시계 옆)에 상주하면서, 아이콘을 클릭하면 핑크모도로 전체 화면이 창으로 열리는 앱입니다. 창을 닫아도 종료되지 않고 트레이로 숨겨지고, 트레이 메뉴에서 "열기/숨기기"로 토글하거나 "종료"로 완전히 끌 수 있습니다. 세션 종료 알림은 Windows 알림(풍선 도움말)으로 직접 뜨도록 연결되어 있습니다.

이 폴더는 Visual Studio에서 빌드해야 실행 파일(.exe)이 됩니다. 아래 순서대로 하면 15분 안에 끝나요.

---

## 0. 준비물 (처음 한 번만)

- [ ] [Visual Studio Community](https://visualstudio.microsoft.com/) 설치 (무료)
- [ ] 설치 중 워크로드 선택 화면에서 **".NET 데스크톱 개발"** 체크 (WPF 빌드에 필요)
- [ ] Windows 11이면 보통 기본 포함되어 있지만, 안 될 경우를 대비해 [WebView2 Runtime](https://developer.microsoft.com/microsoft-edge/webview2/) 설치해두기

## 1. 프로젝트 열기

- [ ] GitHub에서 이 저장소를 ZIP으로 받거나 `git clone`
- [ ] `windows-widget` 폴더 안의 **`PinkmodoroWidget.csproj`** 파일을 더블클릭 (Visual Studio가 자동으로 열림)
- [ ] 처음 열면 Visual Studio가 NuGet 패키지(Microsoft.Web.WebView2)를 자동으로 복원함 — 잠깐 기다리기

## 2. 빌드 & 실행

- [ ] 상단 초록색 재생 버튼(▶ PinkmodoroWidget) 클릭 또는 **F5**
- [ ] 창이 뜨고 핑크모도로 화면이 로드되면 성공
- [ ] 작업표시줄 오른쪽 트레이 아이콘(숨겨진 아이콘 화살표 눌러서 확인)에 토마토 아이콘이 보이는지 확인

## 3. 동작 확인

- [ ] 창의 **X(닫기)** 버튼을 눌러도 앱이 종료되지 않고 트레이로 숨겨지는지 확인
- [ ] 트레이 아이콘 더블클릭 → 창이 다시 열리는지 확인
- [ ] 트레이 아이콘 우클릭 → "열기/숨기기", "종료" 메뉴가 뜨는지 확인
- [ ] 앱 안에서 알림 토글을 켜고, 타이머를 짧게(1분) 돌려서 끝날 때 Windows 알림이 뜨는지 확인

---

## 배포용 실행 파일 만들기 (선택)

Visual Studio 없이 더블클릭으로 바로 실행되는 단일 .exe가 필요하면:

```
dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true
```

`windows-widget` 폴더에서 이 명령을 실행하면 `bin\Release\net8.0-windows\win-x64\publish\` 안에 `PinkmodoroWidget.exe`가 생깁니다.

## 참고

- **로그인 시 자동 실행**: `Win+R` → `shell:startup` 입력 → 열리는 폴더에 `PinkmodoroWidget.exe`의 바로가기를 넣으면 Windows 부팅 시 자동 실행됩니다.
- **다른 저장소 URL 사용**: `MainWindow.xaml.cs`의 `SiteUrl` 상수를 포크한 GitHub Pages 주소로 바꾸면 됩니다.
- **WebView2 런타임 오류가 뜨면**: [WebView2 Runtime](https://developer.microsoft.com/microsoft-edge/webview2/)을 설치하세요. Windows 11은 대부분 기본 포함되어 있습니다.
- **알림이 안 뜬다면**: 시스템 설정 → 알림 → PinkmodoroWidget에서 알림이 허용되어 있는지 확인하세요.
