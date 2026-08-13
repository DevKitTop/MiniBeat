# AGENTS.md - Project Operating Rules

## Product context

This repository is a private personal-audio application for Android and iOS. It is NOT a music catalog, streaming service with licensed content, social network, or public file-sharing platform.

The application has two separate content spaces:

- Local: audio owned by the user and accessible on the device.
- Cloud: private audio owned by the authenticated user.

Do not merge these spaces into one storage model or one primary navigation concept unless product documentation is explicitly changed.

## Source of truth

Before implementing or changing behavior, consult:

- `PRODUCT_SPEC.md`
- `requirements/business-rules.md`
- `requirements/non-functional-requirements.md`
- `flows/core-user-flows.md`
- `decisions/open-decisions.md`

## Critical rules

1. Do not invent product behavior when a requirement is ambiguous.
2. Do not silently resolve an open architectural/product decision.
3. Keep Local usable without authentication and Internet.
4. Keep Cloud content private and owner-scoped.
5. Never add public sharing of Cloud files in the MVP.
6. Playlists reference songs; playlists do not move/delete source files.
7. Local and Cloud playlists are separate unless an explicit sync action is implemented.
8. Upload and download are explicit user actions.
9. Audio playback must continue to work independently from UI animations.
10. Prefer graceful, quiet error handling for recoverable failures.
11. Do not introduce dependencies only because they are common; justify each dependency against a current requirement.
12. Keep the architecture small. Do not introduce a domain layer or enterprise abstractions unless current complexity justifies them.
13. Do not copy a boilerplate repository wholesale. Use external repositories only as references and extract ideas intentionally.
14. Security must be enforced by backend/storage authorization, not only by client-side checks.
15. Do not place secrets, tokens or private storage URLs in source code or logs.

## Development behavior for the coding agent

- Before a substantial implementation, summarize the requirement and identify impacted documentation.
- Prefer small, reversible changes.
- Run relevant Dart/Flutter static analysis after meaningful code changes.
- Add unit/widget/integration tests for behavior that affects business rules, playback state, transfers or persistence.
- When a behavior is not defined, add or update a decision document rather than guessing.
- Preserve the documented MVP scope. Do not implement future social/premium features unless explicitly requested.
