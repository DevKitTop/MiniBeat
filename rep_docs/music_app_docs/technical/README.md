# Technical Documentation

This folder is the technical companion to the existing product documentation.

## Separation of responsibilities

The existing product documentation answers:

> What should the application do?

This folder answers:

> What technical constraints and decisions should the implementation follow?

Do not duplicate the product specification here.

## Documents

- `technical-requirements.md` — technical requirements derived from the questionnaire.
- `audio-and-platform.md` — audio engine and native/platform integration notes.
- `cloud-and-storage.md` — cloud/backend/storage requirements and current candidates.
- `local-persistence-and-sync.md` — local database, cache, downloads and synchronization.
- `architecture-decisions.md` — confirmed architecture direction and leading candidates.
- `open-technical-decisions.md` — unresolved decisions that must be researched before locking implementation.

## Rule for future agents

When a technical decision is marked open, do not invent a permanent decision. Research it, propose options and request approval when it changes architecture.
