# Codex Agent Handover: R4.45 Frontend Safety Guide

Status: handover guidance, not release approval.

## Scope and authority

This repository is a Flutter client. Backend responses, persisted state, and owner-approved contracts are authoritative. Flutter may request, display, animate, and synchronize server truth; it must not decide eligibility, balances, rewards, Land ownership, H3 identity, claims, payouts, or activation.

## Current verified facts

- Default branch: `main`; reviewed HEAD: `7de8e4bd2fba5f7d5e1bc3ba90b151bd3137ba96`
- `pubspec.yaml` declares Flutter SDK `^3.8.1`, `h3_flutter`, and `flutter_riverpod`
- Android wrapper properties target Gradle `8.12-all`; wrapper provenance remains incomplete until scripts and `gradle-wrapper.jar` are present and hash-checked
- `api_repository.dart` currently uses `http://10.247.33.41:8000`; the Fly URL is commented out
- `land_map_screen.dart` uses H3 and invalidates Riverpod Land providers after purchase/sale flows
- Firebase configuration is present; API endpoint, package identity, OAuth/deep links, Firebase identity, and signing must be one release gate
- Fair Hustler authority was not proven by the current frontend/backend source search and must be reverified from the approved backend contract

## Safe-change rules

Before editing or building, record repository, branch, HEAD, base SHA, status, staged paths, untracked count, protected worktrees, and the exact authorized file list. Never reset, clean, stash, overwrite, or reuse protected/dirty worktrees. Never stage with `git add .` or `git add -A`.

Keep the isolated nine-file frontend change set separate from dependencies, generated files, endpoint changes, signing, Android identity, and backend edits.

Verify Gradle wrapper scripts, JAR provenance, distribution, checksums, Java/Android SDK, and dependencies before building. Do not build/install an APK until API endpoint, application ID, Firebase/OAuth/deep-link identity, signing path, and artifact provenance are verified. Never generate, expose, rotate, or reset signing material.

Check H3 independently on Windows and Android. The frontend must not create authoritative H3 identity. After mutations, verify request, backend response, provider reload, widget rebuild, and visible state; a screenshot or invalidation alone is not runtime proof.

Fair Hustler eligibility, rewards, balances, Land lifecycle, claims, and ownership remain backend-owned. Do not infer authority from districts, local timers, cached balances, metadata, wallet addresses, or H3 geometry.

## Gates

Report `SOURCE_SCOPE`, `STATIC_CHECKS`, `WRAPPER_PROVENANCE`, `API_CONFIG`, `ANDROID_IDENTITY`, `H3_TARGETS`, `RIVERPOD_UI`, `BACKEND_AUTHORITY`, `BUILD`, `RUNTIME`, and `GIT` separately. Use `NOT_PROVEN` when not executed.

```text
SAFE_TO_STAGE=NO
SAFE_TO_COMMIT=NO
SAFE_TO_PUSH=NO
SAFE_TO_MERGE=NO
DEPLOY_AUTHORIZED=NO
APK_BUILD_AUTHORIZED=NO
```

A draft PR is review-only. Never merge, deploy, install, execute payouts, mutate production data, or alter signing material as part of this handover.

```text
SOURCE_CORRECTION=
FOCUSED_TESTS=
BUILD=
RUNTIME_PROOF=
UNRELATED_DIRTY_WORKTREES_PRESERVED=
STAGED_FILES=
SAFE_TO_COMMIT=
SAFE_TO_PUSH=
SAFE_TO_MERGE=
DEPLOY_AUTHORIZED=
NEXT_SINGLE_ACTION=
```
