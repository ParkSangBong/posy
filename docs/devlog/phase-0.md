# Phase 0 — 환경 점검과 킥오프

- 기간: 2026-11-14 ~ 2026-11-25
- 목표: 개발 도구를 설치하고, 프로젝트 전반의 열린 결정을 정리한다.

## 무엇을 했나

### 설치한 도구

| 도구 | 버전 | 설치 방법 |
|---|---|---|
| Rust (rustc, cargo, rustfmt, clippy) | 1.100.0 | rustup 공식 설치 스크립트 |
| Node | 24.22.3 | nvm (`nvm install 24`) |
| pnpm | 12.23.0 | `npm install -g pnpm` (corepack 아님, 아래 트러블슈팅 참고) |
| just | 1.59.0 | `cargo install just --locked` |
| gh | 2.105.0 | GitHub 릴리스 zip + 체크섬 검증 → `~/.local/bin` |

### 주요 결정

- 플랫폼: **모바일 우선 웹**. 가끔 쓰는 서비스이고 핵심 기능이 링크 공유라서 앱 설치를 요구하지 않는다. PWA는 Phase 5 끝에 다시 검토.
- 모노레포: Cargo workspace(`crates/*`) + pnpm workspace(`apps/*`)를 한 레포에.
- Rust edition 2024, 태스크 러너 just, Rust→TS 타입 공유는 ts-rs.
- 로컬 DB는 Docker Compose로 Postgres 17.
- 공유 링크는 입력 + seed + **결과 스냅샷(장면·가격)** + engine_version을 저장. 엔진이나 가격 데이터가 바뀌어도 예전 링크가 그대로 보이게 하려고.
- 진행 방식: 함수마다 테스트 코드를 먼저 승인받고 구현. 커밋도 함수(+테스트) 단위로 잘게, 메시지는 커밋마다 승인. PR은 merge commit으로 머지(squash 금지).

## 막혔던 것 (트러블슈팅)

### 1. rustup 설치가 취소됨
- 증상: 설치 후에도 `rustc: command not found`.
- 원인: 설치 프롬프트에서 `3`(Cancel installation)이 입력된 채로 끝났다.
- 해결: 다시 실행해서 Enter(기본 설치).

### 2. corepack으로 설치한 pnpm 12가 실행되지 않음
- 증상: `pnpm -v` → `Cannot find module '.../pnpm/12.23.0/bin/pnpm.cjs'`
- 헛짚은 원인 1: Node 20이 오래돼서? → Node 24로 올려도 같은 에러.
- 헛짚은 원인 2: corepack이 오래돼서? → corepack을 최신(0.36.0)으로 올려도 같은 에러.
- 진짜 원인: pnpm 12 패키지의 `bin/` 폴더에는 `pnpm.mjs`만 있다. corepack은 여전히 `bin/pnpm.cjs`를 찾는다. 즉 **corepack이 pnpm 12의 새 구조를 지원하지 않는다.**
- 해결: `corepack disable pnpm` 후 `npm install -g pnpm@latest`.
- 교훈: 추측으로 고치기 전에 **실제 파일을 열어 보자.** 캐시 폴더의 `package.json`과 `bin/`을 확인하자마자 원인이 보였다.
- 참고: Node 25부터는 corepack이 Node에 기본 포함되지 않는다.

### 3. Homebrew가 인텔 맥을 지원하지 않음
- 증상: `brew install just gh`가 LLVM, Rust, Go 등 19개를 **소스에서 컴파일**하겠다고 함.
- 원인: Homebrew가 2026년 9월부터 macOS 인텔(x86_64) 지원을 중단해서 미리 빌드된 패키지(bottle)가 없다.
- 해결: `n`으로 취소. just는 `cargo install`(약 2분), gh는 GitHub 공식 릴리스의 미리 빌드된 바이너리를 받아 SHA-256 체크섬을 확인한 뒤 설치.
- 교훈: brew 출력에 "build from source" 목록이 길게 나오면 일단 멈추자.

### 4. npm 11의 설치 스크립트 차단 경고
- 증상: `npm install -g pnpm` 때 `install-scripts ... not yet covered by allowScripts` 경고.
- 원인: npm 11부터 보안을 위해 패키지 설치 스크립트를 기본으로 실행하지 않는다.
- 영향: pnpm은 정상 동작해서 그대로 둠.

## 면접에서 이야기할 포인트

- 도구 체인 문제를 "버전을 올려 보기"로 두 번 헛짚은 뒤, 실제 파일 구조를 확인해서 근본 원인(corepack의 pnpm 12 미지원)을 찾은 과정.
- 지원 종료(EOL)된 플랫폼(Node 20, 인텔 맥의 Homebrew)을 마주했을 때 우회한 방법과, 바이너리를 받을 때 체크섬을 검증한 이유.
- 공유 링크에 결과 스냅샷을 저장하기로 한 결정: "같은 seed면 같은 결과"만으로는 엔진이 바뀌는 경우를 막을 수 없다.
