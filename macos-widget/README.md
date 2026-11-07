# 핑크모도로 메뉴바 위젯 (macOS)

맥 화면 상단 메뉴바(시계 옆)에 상주하면서, 클릭하면 핑크모도로 전체 화면(체크리스트·세션 로그 포함)이 드롭다운으로 열리는 네이티브 앱입니다. 웹앱을 그대로 감싸는 방식이라 기능 차이가 없고, 알림은 macOS 표준 알림 센터로 직접 뜨도록 연결되어 있습니다.

빌드하려면 Apple의 Swift 툴체인이 필요합니다 — 이건 피할 수 없지만, **Xcode 앱(IDE) 자체는 꼭 필요하지 않습니다.** 아래 두 가지 방법 중 하나를 고르면 됩니다.

- **A. 터미널만으로 (Xcode 앱 설치 없이)** — 가볍고 빠름. 커맨드라인 도구(Command Line Tools)만 설치하면 됨.
- **B. Xcode 사용** — GUI로 디버깅하거나 아이콘을 직접 눈으로 보면서 편집하고 싶을 때.

---

## A. 터미널만으로 실행하기 (Xcode 앱 없이)

### 0. 준비물 (처음 한 번만)

- [ ] 터미널에서 `xcode-select --install` 실행 → **Command Line Tools**만 설치 (몇백 MB, Xcode 앱 전체(10GB+)는 필요 없음)
- [ ] 이미 Xcode가 깔려 있다면 이 단계는 건너뛰어도 됩니다

### 1. 빌드 + 실행

```
cd macos-widget
swift run
```

- [ ] 터미널에 빌드 로그가 나오고 나면 메뉴바에 타이머 아이콘이 뜨는지 확인
- [ ] 알림 권한 팝업이 뜨면 **허용**

`swift run`은 개발 중 테스트용입니다. 평소에 켜둘 앱으로 쓰려면(알림이 안정적으로 뜨게 하려면) 아래처럼 `.app`으로 묶는 걸 권장합니다.

### 2. `.app`으로 묶기 (평소 쓸 때)

```
cd macos-widget
./build-app.sh
```

- [ ] `.build/PinkmodoroWidget.app`이 생성되면 `open .build/PinkmodoroWidget.app`으로 실행하거나, Finder에서 더블클릭
- [ ] 이 스크립트는 `swift build -c release`로 빌드하고, `Info.plist`를 만들어 `.app` 번들로 묶고, 로컬 실행을 위해 ad-hoc 코드사이닝까지 자동으로 해줍니다
- [ ] 다른 곳(Applications 폴더, 로그인 항목)에 옮겨서 평소에 써도 됩니다

> **왜 `.app`으로 묶어야 하나요?** `swift run`으로 바로 띄운 프로세스는 제대로 된 번들 식별자(bundle identifier)가 없어서, macOS의 알림 시스템(`UNUserNotificationCenter`)이 권한 요청이나 알림 전달을 제대로 못 하는 경우가 있습니다. `.app` 번들로 묶고 나면 이 문제가 없습니다.

### 참고

- 아이콘은 `Assets/AppIcon-1024.png`를 자동으로 여러 크기로 변환해서 번들에 넣어줍니다 (`sips`/`iconutil` 사용, macOS 기본 내장 도구).
- Dock에는 안 뜨고 메뉴바에만 떠야 하는데, 이건 코드에서 `NSApp.setActivationPolicy(.accessory)`로 처리하고 있어서 Xcode의 Info 설정 없이도 동작합니다.

---

## B. Xcode로 실행하기

### 1. Xcode 프로젝트 만들기 (5분)

- [ ] Xcode 실행 → **File → New → Project**
- [ ] **macOS → App** 선택 → Next
- [ ] Product Name: `PinkmodoroWidget` (원하는 이름으로 변경 가능)
- [ ] Interface: **SwiftUI**, Language: **Swift** 확인 후 Next → 저장 위치 지정 → Create
- [ ] 프로젝트 설정(파란 아이콘) → **General** 탭 → **Minimum Deployments**를 **macOS 13.0** 이상으로 변경 (`MenuBarExtra`가 macOS 13부터 지원됨)

### 2. 코드 붙여넣기 (5분)

- [ ] Xcode 왼쪽 파일 목록에서 자동 생성된 `ContentView.swift` 삭제 (Move to Trash)
- [ ] 기본 앱 파일(`PinkmodoroWidgetApp.swift` 또는 프로젝트명과 같은 이름의 파일)도 삭제
- [ ] `macos-widget/Sources/PinkmodoroWidget/`의 5개 `.swift` 파일을 Xcode 프로젝트로 드래그 앤 드롭 (Copy items if needed 체크)
  - `PinkmodoroWidgetApp.swift`
  - `TimerBridge.swift`
  - `PinkmodoroWebView.swift`
  - `PinkmodoroPopoverView.swift`
  - `MenuBarLabelView.swift`

### 3. 앱 아이콘 넣기 (선택, 2분)

- [ ] `Assets.xcassets` → `AppIcon` 클릭
- [ ] `Assets/AppIcon-1024.png` 파일을 1024×1024 칸에 드래그

### 4. 메뉴바 전용으로 설정하기 — Dock 아이콘 숨기기 (2분)

코드에서 이미 `NSApp.setActivationPolicy(.accessory)`로 처리하고 있어서 이 단계는 보통 생략해도 됩니다. 혹시 Dock에 아이콘이 뜬다면:

- [ ] 프로젝트 설정 → **Info** 탭 (Xcode 15 이상은 target 클릭 → Info 탭)
- [ ] 아무 항목에 마우스 오른쪽 클릭 → **Add Row**
- [ ] Key: `Application is agent (UIElement)` 선택 → Value: **YES**로 설정

### 5. 네트워크 권한 확인 (App Sandbox 켜져 있는 경우, 1분)

- [ ] target 선택 → **Signing & Capabilities** 탭
- [ ] `App Sandbox`가 있다면 그 안의 **Outgoing Connections (Client)** 체크박스가 켜져 있는지 확인
  (WKWebView가 인터넷에서 핑크모도로 페이지를 불러오려면 필요합니다)

### 6. 실행 (Cmd+R)

- [ ] 상단 재생 버튼 또는 **Cmd+R**
- [ ] 첫 실행 시 알림 권한 팝업이 뜨면 **허용**
- [ ] 메뉴바에 타이머 아이콘이 나타나면 클릭 → 핑크모도로 화면이 드롭다운으로 열립니다
- [ ] 앱 안의 설정에서 알림 토글을 켜두면, 집중 세션이 끝날 때 macOS 알림 센터로 배너가 뜹니다

---

## 참고

- **로그인 시 자동 실행**: 시스템 설정 → 일반 → 로그인 항목 → `+` 버튼으로 빌드된 `.app`을 추가하면 맥을 켤 때마다 자동 실행됩니다.
- **다른 저장소 URL 사용**: `PinkmodoroPopoverView.swift`의 `siteURL`을 포크한 GitHub Pages 주소로 바꾸면 됩니다.
- **메뉴바 라벨**: 타이머가 돌아가는 동안 `24:59 · 집중`처럼 남은 시간이 그대로 메뉴바 텍스트로 표시됩니다. 이건 웹페이지의 `document.title`을 실시간으로 읽어오는 것이라 별도 동기화 코드가 필요 없습니다.
- **알림이 안 뜬다면**: 시스템 설정 → 알림 → 빌드한 앱 이름을 찾아 알림 허용이 켜져 있는지 확인하세요.
