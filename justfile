# posy 작업 명령 모음. `just <이름>`으로 실행한다. https://just.systems

# 명령 목록 보기 (그냥 `just`만 입력했을 때)
default:
    @just --list

# 커밋 전 필수 검사: CI와 같은 검사를 로컬에서 한 번에 돌린다
check: rust-check web-check

# Rust: 포맷 확인, clippy(경고도 실패 처리), 테스트
rust-check:
    cargo fmt --all --check
    cargo clippy --workspace --all-targets -- -D warnings
    cargo test --workspace

# 웹: lint, 테스트, 빌드
web-check:
    pnpm --filter web lint
    pnpm --filter web test
    pnpm --filter web build

# Rust 코드 자동 포맷 (rust-check의 fmt 검사가 실패했을 때)
fmt:
    cargo fmt --all
