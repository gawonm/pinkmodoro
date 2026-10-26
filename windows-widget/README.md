# 핑크모도로 트레이 위젯 (Windows)

작업표시줄 트레이(시계 옆)에 상주하면서, 아이콘을 클릭하면 핑크모도로 전체 화면이 창으로 열리는 앱입니다. 창을 닫아도 종료되지 않고 트레이로 숨겨지고, 트레이 메뉴에서 "열기/숨기기"로 토글하거나 "종료"로 완전히 끌 수 있습니다. 세션 종료 알림은 Windows 알림(풍선 도움말)으로 직접 뜨도록 연결되어 있습니다.

트레이 아이콘은 페이지 안의 진행률 파이(브라우저 탭 파비콘과 같은 디자인)와 실시간으로 동기화됩니다 — 남은 시간 비율만큼 원이 채워지고, 집중/짧은 휴식/긴 휴식 단계에 따라 색이 바뀌고, 일시정지 중엔 흐려집니다. 마우스를 올리면 Windows 기본 툴팁으로 `24:59 · 집중` 같은 텍스트가 뜨고, 떼면 사라집니다(네이티브 트레이 툴팁 기능이라 별도 코드 없이 안정적으로 동작해요).

이 폴더는 빌드해야 실행 파일(.exe)이 됩니다. Visual Studio 없이 **VS Code + .NET SDK**로도 똑같이 빌드/실행/디버깅할 수 있어요 — 아래 순서대로 하면 15분 안에 끝나요.

---

## 0. 준비물 (처음 한 번만)

- [ ] [.NET 8 SDK](https://dotnet.microsoft.com/download) 설치 (Visual Studio 없이 컴파일하는 핵심 도구)
- [ ] [VS Code](https://code.visualstudio.com/) 설치
- [ ] VS Code 확장 탭에서 **C# Dev Kit** 설치 (IntelliSense + 디버거 제공, Microsoft 공식 확장)
- [ ] Windows 11이면 보통 기본 포함되어 있지만, 안 될 경우를 대비해 [WebView2 Runtime](https://developer.microsoft.com/microsoft-edge/webview2/) 설치해두기

## 1. 프로젝트 열기

- [ ] GitHub에서 이 저장소를 ZIP으로 받거나 `git clone`
- [ ] VS Code에서 **File → Open Folder** → `windows-widget` 폴더 선택
- [ ] 처음 열면 하단에 "Required assets to build and debug are missing" 알림이 뜰 수 있음 → **Yes** 클릭 (`.vscode` 설정은 이미 포함되어 있어서 안 떠도 정상)
- [ ] VS Code 터미널(**Ctrl+`**)에서 아래 명령으로 NuGet 패키지 받기:
  ```
  dotnet restore
  ```

## 2. 빌드 & 실행

- [ ] **F5** 누르기 (왼쪽 Run and Debug 탭에서 "핑크모도로 위젯 실행" 선택 후 재생 버튼도 가능)
- [ ] 또는 터미널에서 직접:
  ```
  dotnet run
  ```
- [ ] 창이 뜨고 핑크모도로 화면이 로드되면 성공
- [ ] 작업표시줄 오른쪽 트레이 아이콘(숨겨진 아이콘 화살표 눌러서 확인)에 토마토 아이콘이 보이는지 확인

## 3. 동작 확인

- [ ] 창의 **X(닫기)** 버튼을 눌러도 앱이 종료되지 않고 트레이로 숨겨지는지 확인
- [ ] 트레이 아이콘 더블클릭 → 창이 다시 열리는지 확인
- [ ] 트레이 아이콘 우클릭 → "열기/숨기기", "종료" 메뉴가 뜨는지 확인
- [ ] 앱 안에서 알림 토글을 켜고, 타이머를 짧게(1분) 돌려서 끝날 때 Windows 알림이 뜨는지 확인

---

## 배포용 실행 파일 만들기 (선택)

더블클릭으로 바로 실행되는 단일 .exe가 필요하면 터미널에서:

```
dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true
```

`windows-widget` 폴더에서 이 명령을 실행하면 `bin\Release\net8.0-windows\win-x64\publish\` 안에 `PinkmodoroWidget.exe`가 생깁니다.

## 참고

- **로그인 시 자동 실행**: `Win+R` → `shell:startup` 입력 → 열리는 폴더에 `PinkmodoroWidget.exe`의 바로가기를 넣으면 Windows 부팅 시 자동 실행됩니다.
- **다른 저장소 URL 사용**: `MainWindow.xaml.cs`의 `SiteUrl` 상수를 포크한 GitHub Pages 주소로 바꾸면 됩니다.
- **WebView2 런타임 오류가 뜨면**: [WebView2 Runtime](https://developer.microsoft.com/microsoft-edge/webview2/)을 설치하세요. Windows 11은 대부분 기본 포함되어 있습니다.
- **알림이 안 뜬다면**: 시스템 설정 → 알림 → PinkmodoroWidget에서 알림이 허용되어 있는지 확인하세요.
