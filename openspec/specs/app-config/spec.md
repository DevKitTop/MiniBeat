# App Configuration Specification

## Purpose

Defines environment loading via flutter_dotenv, the no-secrets rule, the config model, and centralized product-policy constants for rep_mini. Configuration only: no upload/download or auth logic. New capability (baseline spec).

## Requirements

### Requirement: CFG-001 Environment files

The project MUST ship `.env.example` with placeholder keys, MUST gitignore `.env`, and `main()` MUST load environment variables via flutter_dotenv before app start.

#### Scenario: Example ships, real env ignored

- GIVEN the repository
- WHEN files are inspected
- THEN `.env.example` exists with placeholders and `.env` is gitignored

#### Scenario: Env loads at startup

- GIVEN a `.env` containing the required keys
- WHEN the app starts
- THEN the loaded config exposes those keys

### Requirement: CFG-002 No secrets in code

Client code MUST NOT contain credentials, tokens, or the Supabase service-role key; `.env.example` MUST contain placeholder values only.

#### Scenario: No secret material committed

- GIVEN the `lib/` sources and `.env.example`
- WHEN scanned for secret material
- THEN no secrets or service-role keys are present

### Requirement: CFG-003 Config model

The app MUST expose an `AppConfig` model providing the Supabase URL and anon key; missing required keys MUST produce a descriptive error rather than silent defaults.

#### Scenario: Missing key fails fast

- GIVEN config built without a required key
- WHEN the config is loaded
- THEN a descriptive configuration error is raised

### Requirement: CFG-004 Policy constants

Product policies MUST be centralized in a single file: a 30 MB upload-size limit, a format allowlist of MP3, M4A/AAC, FLAC, and WAV, and a duplicate-detection policy using SHA-256 as the authoritative signal layered over a size+duration pre-filter.

#### Scenario: Policy constants are correct

- GIVEN the policy file
- WHEN the constants are read
- THEN the max upload size equals 30 MB and the allowlist contains exactly MP3, M4A/AAC, FLAC, and WAV

#### Scenario: Unsupported format rejected

- GIVEN the allowlist policy
- WHEN a format such as OGG or OPUS is checked
- THEN it is not supported

### Requirement: CFG-005 Single source of truth

Feature code MUST reference the policy constants instead of duplicating literal values.

#### Scenario: No duplicate literals

- GIVEN the codebase
- WHEN scanned for the 30 MB value and format strings
- THEN occurrences outside the policy file are absent
