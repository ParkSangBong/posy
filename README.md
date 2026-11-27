# posy

꽃 선물 초보를 위한 꽃다발 미리보기 서비스

> 🚧 개발 중입니다. Phase 1(레포 스캐폴딩)을 마치고 미리보기 방식을 정했어요([ADR-0002](docs/adr/0002-photo-composite-ai-photoize.md)). 다음은 Phase 2(데이터 모델·DB)예요.

## 어떤 서비스인가요?

꽃 선물을 거의 해본 적 없는 사람은 어떤 꽃을 어떻게 조합하면 어떤 모습이 되는지, 얼마쯤 드는지 감을 잡기 어려워요. 글로 된 설명만으로는 상상이 잘 안 되고요.

posy에서는 이걸 고르면

- 꽃 종류와 색
- 꽃별 송이 수
- 꽃다발 모양 (라운드 / 원사이드 / 내추럴 / 한 송이)
- 크기 (S / M / L)

이걸 볼 수 있어요.

- 실제 사진 같은 꽃다발 미리보기
- 대략적인 가격 범위 (나중 단계에서 추가)
- 꽃말 (한국 꽃말 / 서양 꽃말)

결과는 이미지로 저장하거나 링크로 공유해서 꽃집에 보여줄 수 있어요. 로그인은 필요 없어요.

> 실제 꽃다발은 꽃집과 시즌에 따라 모양·색·가격이 달라질 수 있어요.

## 스크린샷

(Phase 7 이후 추가 예정)

## 아키텍처

```mermaid
flowchart LR
  user([사용자 브라우저]) --> web[apps/web<br/>Next.js]
  web -->|선택값| api[crates/api<br/>Axum]
  api --> core[crates/bouquet-core<br/>검증·레이아웃]
  api --> render[crates/render<br/>장면 → 밑그림 PNG]
  api --> db[(PostgreSQL<br/>결과·작업 대기열)]
  worker[crates/worker<br/>개인 데스크톱] -->|작업 가져가기·결과 올리기| api
  worker --> comfy[ComfyUI<br/>Qwen-Image-Edit]
  api -->|밑그림 → 사진| web
```

- 백엔드가 **장면 데이터**(꽃별 위치·회전·크기·레이어 순서·포장지)를 계산하고, 꽃 재료 이미지를 장면대로 붙여 **밑그림**을 바로 만들어요.
- 개인 데스크톱의 **AI 워커**가 밑그림을 실제 사진처럼 바꿔요(약 1분). 꽃 종류·색·송이 수는 유지하고, 배치는 더 자연스럽게 다듬을 수 있어요.
- 같은 입력과 같은 seed면 밑그림은 항상 같아요. AI 결과는 한 번 만들면 저장해서 다시 써요.
- 이렇게 정한 이유는 [ADR-0002](docs/adr/0002-photo-composite-ai-photoize.md)에 있어요.

현재 구현된 부분은 `bouquet-core`(빈 크레이트)와 `apps/web`(기본 골격)이에요.

## 로드맵

| Phase | 내용 |
|---|---|
| 0~1 | 계획, 레포 스캐폴딩 ✅ |
| 2 | 데이터 모델·DB (꽃, 색, 꽃 재료, 공유, AI 작업 대기열) |
| 3 | `bouquet-core`: 유효성 검사, 레이아웃(장면 계산) |
| 4 | `render`: 장면 → 밑그림 PNG, 꽃 재료 만들기 |
| 5 | `api`: 미리보기 생성, 작업 상태, 공유 링크 |
| 6 | AI 워커: 데스크톱 ComfyUI 연동 |
| 7 | 웹: 선택 화면, 미리보기, 저장·공유 |
| 8 | 배포·운영 |
| 나중 | 가격 범위, AI 결과 송이 수 자동 검사 |

## 기술 스택

| 영역 | 기술 |
|---|---|
| 도메인 로직 | Rust (edition 2024) |
| API | Rust, Axum, sqlx, PostgreSQL |
| 웹 | Next.js (App Router), TypeScript, Tailwind CSS |
| AI 사진화 | Qwen-Image-Edit-2511, ComfyUI (개인 데스크톱 GPU) |
| 테스트 | cargo test, Vitest, Testing Library |
| 도구 | Cargo workspace, pnpm workspace, just, GitHub Actions |

기술을 고른 이유는 [docs/adr](docs/adr)에 기록해요.

## 실행 방법

### 준비물

| 도구 | 버전 | 비고 |
|---|---|---|
| Rust | 1.100.0 | [rustup](https://rustup.rs)만 설치하면 `rust-toolchain.toml`에 따라 자동으로 맞춰져요 |
| Node | 24 | `.nvmrc` 참고 (`nvm use`) |
| pnpm | 12.23.0 | `npm install -g pnpm@12.23.0` |
| just | 최신 | `cargo install just --locked` |

### 명령

```bash
pnpm install              # 웹 의존성 설치
just check                # 전체 검사 (Rust fmt·clippy·test + 웹 lint·test·build)
pnpm --filter web dev     # 웹 개발 서버 (http://localhost:3000)
```

## 레포 구조

```
crates/bouquet-core   순수 Rust 도메인 로직 (I/O 없음)
apps/web              Next.js 웹 앱
docs/adr              기술 결정 기록 (ADR)
docs/devlog           Phase별 회고와 학습 노트
```

## 개발 기록과 트러블슈팅

Phase별로 무엇을 배웠고 어디서 막혔는지 [docs/devlog](docs/devlog)에 남기고 있어요.

## 라이선스

[MIT](LICENSE)
