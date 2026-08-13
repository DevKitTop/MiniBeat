# Architecture Decisions

## Decision status

This document records confirmed technical preferences and current leading choices. It is intentionally separate from product requirements.

## Confirmed

- Mobile only: Android + iOS, tablets included.
- Android-first development, then iOS validation.
- Local database exists for all users.
- Local and Cloud libraries remain separate.
- Permanent downloads and temporary streaming cache are distinct.
- Background playback is mandatory.
- Architecture changes require explicit user approval.
- Significant architectural changes require ADR documentation.
- Dependencies should be minimal and justified.
- Code generation should be minimal and justified.
- Product logic should remain platform-independent wherever practical.

## Leading architectural direction

```text
Presentation
   |
ViewModels / State
   |
Repositories
   |
Services / Data Sources
   |
+-------------------+--------------------+
| Local             | Cloud              |
| media/files       | API + storage      |
| local database    | private storage    |
+-------------------+--------------------+
            |
        Audio layer
            |
   just_audio candidate
            |
      audio_service
```

This is a conceptual architecture, not a final folder structure.

## State management

The user delegated the choice. The selection must optimize for:

- speed;
- testability;
- low boilerplate;
- maintainability;
- predictable dependency injection;
- suitability for streams and background audio state.

Riverpod is a leading candidate to evaluate, but it is not locked by this document.

## Navigation

A declarative router is preferred if it adds little complexity and remains stable. `go_router` is the leading candidate, but it is not locked until current compatibility is verified.

## Why this is not a large Clean Architecture template

The app should not start with unnecessary domain/use-case layers. Layers should be introduced when they reduce real complexity.

## ADR rule

Any decision that changes one of the following requires an ADR and user approval:

- audio engine;
- storage/backend provider;
- database technology;
- state management;
- navigation strategy;
- local media indexing strategy;
- sync identity/conflict model;
- security model;
- cross-platform architecture.
