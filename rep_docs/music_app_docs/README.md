# Personal Audio Cloud - Documentation Pack

This folder contains the product specification that should exist before the first Flutter implementation.

## Files

- `PRODUCT_SPEC.md` - central product and functional specification.
- `AGENTS.md` - operating rules for OpenCode and future coding agents.
- `requirements/business-rules.md` - explicit business rules and invariants.
- `requirements/non-functional-requirements.md` - performance, privacy, reliability and platform constraints.
- `flows/core-user-flows.md` - primary user journeys and system behavior.
- `decisions/open-decisions.md` - decisions intentionally left open for technical/product research.

## Recommended repository placement

Copy these documents into the Flutter repository as:

```text
docs/
├── PRODUCT_SPEC.md
├── AGENTS.md
├── requirements/
│   ├── business-rules.md
│   └── non-functional-requirements.md
├── flows/
│   └── core-user-flows.md
└── decisions/
    └── open-decisions.md
```

`AGENTS.md` should be present at the repository root so the coding agent sees the operating rules early.

## Status

This is the functional baseline derived from the product conversation. It is not the technical architecture yet.

Next technical decisions should be documented before implementation of the relevant subsystem, especially storage provider, audio engine, file-size policy, format allowlist, cache strategy and duplicate detection.
