# Phase 1 — 레포 스캐폴딩

- 기간: 2026-11-25 ~ 2026-11-26
- 브랜치: `phase-1/scaffold`
- 목표: 빈 폴더를 "`just check` 한 번이면 Rust와 웹 검사가 모두 도는 모노레포"로 만들고, PR에서 CI가 같은 검사를 돌리게 한다.

## 커밋 기록

| # | 커밋 | 한 줄 요약 |
|---|---|---|
| 0 | `chore: 저장소 초기화` (main) | PR의 기준이 될 첫 커밋 |
| 1 | `chore: editorconfig와 gitignore 추가` | 에디터 설정 통일, 비밀값·빌드 결과물 제외 |
| 2 | `chore: Rust 툴체인 버전 고정` | `rust-toolchain.toml`로 1.100.0 고정 |
| 3 | `chore(core): Cargo workspace와 bouquet-core 크레이트 생성` | 빈 라이브러리 크레이트 |
| 4 | `chore: pnpm workspace와 Node 버전 고정` | `.nvmrc`, `packageManager`, `pnpm-workspace.yaml` |
| 5 | `chore(web): Next.js 앱 골격 생성` | create-next-app 결과를 모노레포에 맞게 정리 |
| 6 | `test(web): Vitest 설정과 홈 화면 스모크 테스트 추가` | 첫 Red → Green |
| 7 | `chore: just check 명령 추가` | 커밋 전 검사를 명령 하나로 |
| 8 | `ci: Rust·웹 검사 워크플로 추가` | PR·main push마다 GitHub에서 `just` 검사 |
| 9 | `docs: CLAUDE.md 작업 규칙 추가` | 합의한 진행 방식을 레포에 기록 |
| 10 | `docs: README 초안 작성` | 서비스 소개·아키텍처·실행 방법, web 기본 README 삭제 |
| 11 | `chore: MIT 라이선스 추가` | 저작권자는 "posy contributors" |
| 12 | `docs(adr): 0001 모노레포와 Rust·Next.js 분리 결정 기록` | 첫 ADR |
| 13 | `docs(devlog): Phase 0·1 회고와 학습 노트 작성` | 이 문서 |

> 커밋 11 전에 모든 커밋의 이메일을 noreply로 다시 쓰고 main을 force push했다. 그래서 위 커밋들의 해시는 처음 만들 때와 다르다.

## 학습 노트

### Rust 도구 체인: Node와 비교하면

| Rust | Node 쪽 비슷한 것 | 역할 |
|---|---|---|
| rustup | nvm | 버전 관리자 |
| `rust-toolchain.toml` | `.nvmrc` | 레포에서 쓸 버전 지정. 단, rustup은 `nvm use` 없이 **자동으로** 전환한다 |
| cargo | npm / pnpm | 빌드 + 패키지 관리 + 테스트 실행 |
| rustc | node (tsc) | 실제 컴파일러 |
| crates.io | npm 레지스트리 | 패키지 저장소 |
| clippy | ESLint | 린터 |
| rustfmt | Prettier | 포매터 |

- rustup은 "stable 채널"과 "1.100.0 고정"을 **다른 툴체인**으로 관리한다. 버전이 같아도 따로 설치된다.
- 툴체인 자동 설치는 지원 중단 예정이라, CI에서는 `rustup toolchain install`로 명시적으로 설치한다.

### crate와 workspace

- **crate(크레이트)**: Rust의 컴파일 단위. npm의 "패키지"와 비슷하다. `src/lib.rs`로 시작하면 라이브러리, `src/main.rs`로 시작하면 실행 파일.
- **workspace**: 크레이트 여러 개를 묶는 단위. pnpm workspace와 같은 개념.
  - `members = ["crates/*"]`: `crates/` 아래 폴더가 모두 멤버. 새 크레이트를 만들어도 따로 등록할 필요가 없다.
  - `[workspace.package]` + `edition.workspace = true`: 루트에 적은 값을 멤버가 물려받는다.
  - 빌드 결과물 `target/`은 루트에 하나만 생기고 모든 크레이트가 캐시를 공유한다.
- **edition**: Rust 문법 규칙의 버전(2015, 2018, 2021, 2024). 3년마다 나오고, 호환성을 깨는 변경을 묶는다. 크레이트마다 다른 edition을 써도 서로 의존할 수 있다.
- **`resolver = "3"`**: 의존성 버전을 고르는 규칙. 3은 각 크레이트의 최소 지원 Rust 버전(`rust-version`)을 고려한다.
- **`Cargo.lock`**: `pnpm-lock.yaml`과 같은 역할. 실행 파일(나중의 `api`)이 있는 프로젝트는 커밋한다.
- **`publish = false`**: crates.io에 실수로 배포되는 것을 막는다. npm의 `"private": true`와 같다.
- `cargo new`는 예제 함수 `add()`와 테스트를 만들어 준다. 쓰지 않을 코드라 파일을 직접 만들었다.

### 주석의 종류

```rust
// 일반 주석: 코드 읽는 사람용
/// 문서 주석: 바로 아래 항목(함수, 구조체 등)의 설명. `cargo doc` 문서에 나온다
//! 내부 문서 주석: 이 주석을 감싸는 것(파일 맨 위라면 크레이트/모듈 자체)의 설명
```

### 테스트

- Rust의 `cargo test`는 두 종류를 돌린다.
  - **unit test**: `#[test]`가 붙은 함수 (Phase 3부터 작성)
  - **doc test**: 문서 주석 안의 코드 예제. "문서의 예제가 실제로 동작하는지"까지 검사된다.
- 웹: Vitest + Testing Library
  - `getByRole("heading", { level: 1, name: "posy" })`: 사용자와 스크린리더가 인식하는 **역할**로 요소를 찾는다. 마크업 구조가 바뀌어도 덜 깨진다.
  - `getBy...`는 못 찾으면 즉시 에러를 던진다. `queryBy...`는 `null`을 돌려준다(요소가 "없음"을 검사할 때 사용).
  - jsdom: Node에서 브라우저 DOM을 흉내 내는 환경. 테스트 시간의 약 70%가 이 환경 준비에 쓰인다.
- **Red → Green**: 테스트를 먼저 실패시켜 봐야 그 테스트가 정말 뭔가를 검사한다는 게 증명된다. 오타 때문에 항상 통과하는 테스트를 막는다.

### 검사 명령

- `cargo fmt --all --check`: 포맷이 맞는지 확인만 한다(파일을 바꾸지 않음). 출력이 없으면 통과.
- `cargo clippy --workspace --all-targets -- -D warnings`
  - `--all-targets`: 테스트 코드까지 검사
  - `-D warnings`(deny warnings): 경고 하나만 있어도 실패. 경고를 쌓아 두지 않기 위해.
- Rust는 첫 빌드는 느리고, 이후에는 바뀐 부분만 다시 컴파일한다(증분 컴파일).

### pnpm workspace

- `pnpm <스크립트>`는 **현재 폴더의 package.json**만 본다. 루트에서 하위 패키지를 실행하려면 `pnpm --filter web test`. (Cargo에서는 `cargo test -p bouquet-core`)
- `packageManager: "pnpm@12.23.0"`: pnpm 11부터는 pnpm 자신의 버전도 lockfile(`packageManagerDependencies`)에 기록한다.
- `allowBuilds`: pnpm 11부터 패키지 설치 스크립트 실행 여부를 명시적으로 정해야 한다(공급망 공격 대비).
- create-next-app은 대상 폴더를 독립 프로젝트로 취급해서 lockfile·workspace 설정을 따로 만든다. 모노레포에서는 루트로 합쳐야 한다.

### Next.js / Vite

- Next.js 16은 ESLint 설정이 `eslint.config.mjs`(flat config)이고, `next lint` 대신 `eslint`를 직접 실행한다.
- Vite 8에는 tsconfig `paths` 해석이 내장돼 있다(`resolve.tsconfigPaths: true`). 예전에 쓰던 `vite-tsconfig-paths` 플러그인은 하위 의존성이 관리 중단 상태라 쓰지 않았다.
- `apps/web/AGENTS.md`는 `next dev`가 자동으로 다시 만드는 파일이라 커밋해 둔다.

### GitHub Actions (CI)

- **CI**(지속적 통합): push·PR마다 검사를 자동으로 돌린다. **CD**(지속적 배포)는 검사 후 자동 배포까지 하는 것. 이번에는 CI만 만들었다. 웹 배포는 Vercel이 GitHub와 직접 연결해서 하고, API 배포에 Actions를 쓸지는 Phase 7에서 정한다.
- `uses:`는 남이 만든 액션(재사용 가능한 단계)을 가져다 쓰는 것, `run:`은 셸 명령을 직접 실행하는 것.
- `@v7`처럼 메이저 버전 태그로 고정하면 버그 수정은 자동으로 받고, 호환성이 깨지는 다음 메이저로는 넘어가지 않는다.
- CI도 `just rust-check` / `just web-check`를 호출한다. 검사 명령이 justfile 한곳에만 있으니 로컬과 CI가 어긋날 수 없다.
- `permissions: contents: read`: 워크플로 토큰 권한을 최소화. `concurrency`: 같은 브랜치의 이전 실행 취소.
- `pnpm install --frozen-lockfile`: lockfile과 package.json이 맞지 않으면 실패한다.

### git

- `.gitignore`의 `.env.*` + `!.env.example`: `!`는 "앞의 규칙에서 예외". 비밀값은 막고 예시 파일만 허용한다.
- `.editorconfig`의 `[*.md] trim_trailing_whitespace = false`: 마크다운에서는 줄 끝 공백 두 칸이 줄바꿈 의미를 가질 수 있다.

### git 커밋 이메일과 개인정보

- git 커밋에는 작성자 이름과 **이메일**이 기록되고, public 레포에서는 누구나 볼 수 있다.
- GitHub는 계정마다 noreply 주소(`ID+아이디@users.noreply.github.com`)를 준다. 이 주소로 커밋해도 내 계정의 커밋으로 연결된다.
- GitHub 설정 → Emails
  - "Keep my email addresses private": 웹에서 하는 머지·편집에 noreply 주소 사용
  - "Block command line pushes that expose my email": 개인 이메일이 담긴 커밋 push를 막음
- 레포별 설정: `git config user.email <주소>` (전역 설정은 `--global`)
- 이미 만든 커밋 고치기: `git rebase --root --committer-date-is-author-date --exec 'git commit --amend --no-edit --author="..."'`
- 커밋 해시는 내용·작성자·날짜·메시지·**부모 해시**로 계산된다. 첫 커밋 하나만 고쳐도 뒤의 해시가 전부 바뀐다. 그래서 이미 push한 커밋을 고치려면 force push가 필요하다.
- `git push --force-with-lease`: 내가 마지막으로 본 원격 상태 그대로일 때만 덮어쓴다. `--force`보다 안전하다.
- force push로 기록을 바꿔도 이미 캐시·복제된 사본은 지울 수 없다. **처음부터 noreply로 설정하는 게 최선.**

## 막혔던 것

- create-next-app이 `apps/web`에 lockfile과 `pnpm-workspace.yaml`을 따로 만들었다 → 삭제하고 `allowBuilds` 설정은 루트로 옮김.
- 앱의 터미널 패널에 명령을 대신 입력하려 했지만, `~/.zshrc`의 시작 출력(neofetch) 때문에 셸 준비가 늦어 실패했다 → 직접 실행하는 방식으로 진행.

## 회고

잘한 것
- 쓰지 않을 크레이트(api, render)나 docker-compose를 미리 만들지 않았다. 빈 껍데기가 없어서 레포가 지금 상태를 정직하게 보여준다.
- 웹 골격을 Phase 1에 만들어서 pnpm 12, Vite 8 같은 도구 체인 문제를 기능 개발 전에 발견했다.
- 검사 명령을 justfile 한곳에 모으고 CI도 그걸 호출하게 해서 "로컬에서는 통과했는데 CI에서는 실패" 가능성을 줄였다.

아쉬운 것
- 레포를 만들기 전에 git 커밋 이메일을 확인하지 않아서, 이미 push한 커밋을 force push로 고쳐야 했다. 새 레포를 시작할 때 체크리스트에 넣자.
- 학습 노트를 처음엔 Phase 끝에 몰아 쓰려고 했다. 커밋마다 덧붙이는 방식으로 바꾸니 기억이 생생할 때 기록할 수 있었다.

## 면접에서 이야기할 포인트

- **모노레포 구성**: Cargo workspace와 pnpm workspace를 한 레포에 두고, `just check` 하나로 로컬과 CI 검사를 통일한 이유 (ADR-0001).
- **버전 고정 전략**: `rust-toolchain.toml`, `.nvmrc`, `packageManager`로 툴체인을 고정한 이유. stable 채널을 쓰면 코드 변경 없이도 clippy 규칙이 바뀌어 CI가 깨질 수 있다.
- **create-next-app을 모노레포에 넣을 때** 생긴 lockfile·workspace 설정 중복을 정리한 경험.
- **의존성 선택 기준**: 공식 가이드의 `vite-tsconfig-paths` 대신 Vite 8 내장 옵션을 쓴 이유(하위 의존성이 관리 중단 상태).
- **Red → Green**: 테스트를 먼저 실패시켜서 테스트가 실제로 무언가를 검사한다는 걸 확인하는 습관.
- **커밋 이메일 노출을 발견하고 수정한 과정**: noreply 주소, rebase로 작성자 변경, 해시가 줄줄이 바뀌는 이유, `--force-with-lease`.
