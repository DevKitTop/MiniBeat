# AGENTS.md — rep_mini repository operating rules

## Product context

rep_mini is a private personal-audio application for Android and iOS. It is NOT a
music catalog, streaming service with licensed content, social network, or public
file-sharing platform. It has two separate content spaces:

- **Local**: audio owned by the user and accessible on the device.
- **Cloud**: private audio owned by the authenticated user.

These spaces MUST NOT be merged into one storage model or one primary navigation
concept unless product documentation is explicitly changed.

**Product truth lives in `rep_docs/music_app_docs/`.** Before implementing or
changing product behavior, consult `rep_docs/music_app_docs/AGENTS.md`,
`PRODUCT_SPEC.md`, `requirements/business-rules.md`, `requirements/non-functional-requirements.md`,
`flows/core-user-flows.md`, and `technical/open-technical-decisions.md`. This file
only sets repository-level operating rules; product rules are NOT duplicated here.

## Security rules

1. Never commit secrets: no credentials, tokens, Supabase service-role keys, OAuth
   client secrets, or private storage URLs in source code, logs, or docs.
2. `.env` is gitignored. Real values live only in the local `.env`; `.env.example`
   ships placeholder values only (CFG-001/CFG-002).
3. Security must be enforced by backend/storage authorization, not only by
   client-side checks.
4. Do not introduce dependencies only because they are common; justify each
   dependency against a current requirement.

## Architecture rules

1. Keep the architecture small. No domain layer or enterprise abstractions unless
   current complexity justifies them.
2. Local and Cloud content spaces stay separate unless an explicit sync action is
   implemented.
3. Architecture changes (audio engine, storage provider, state management,
   navigation, local database) require an ADR recorded in the change design, per
   the rule in `rep_docs/music_app_docs/technical/architecture-decisions.md`.
4. Prefer small, reversible changes. Upload and download are explicit user actions.
5. Audio playback must continue to work independently from UI animations.

## SDD workflow conventions

1. Changes follow the OpenSpec workflow: specs in `openspec/specs/`, active change
   artifacts in `openspec/changes/{change-name}/` (proposal, specs, design, tasks).
   Read the tasks list before implementing; the design constrains the approach.
2. Strict TDD is active: write a failing test first (RED), implement the minimum to
   pass (GREEN), triangulate, refactor. Test runner: `flutter test`. Full test
   suite runs at verification.
3. Run `flutter analyze` after meaningful code changes; keep it clean.
4. Commit by work unit with Conventional Commits (e.g. `feat:`, `fix:`, `build:`,
   `chore:`), keeping tests and docs with the code they belong to. Do not add
   AI-attribution lines to commits.
5. Do not invent product behavior when a requirement is ambiguous; update a
   decision document instead of guessing.
