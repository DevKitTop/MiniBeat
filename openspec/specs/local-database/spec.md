# Local Database Specification

## Purpose

Defines the Drift schema for the ten conceptual records, baseline migration, in-memory test database, and codegen scope for rep_mini. Schema only: repositories, sync, and playback-state logic are out of scope. New capability (baseline spec).

## Requirements

### Requirement: LDB-001 Ten records

The Drift database MUST define tables for AudioRecord, FolderRecord, PlaylistRecord, PlaylistItemRecord, FavoriteRecord, HistoryRecord, DownloadRecord, CacheRecord, AppSettingsRecord, and PlaybackStateRecord.

#### Scenario: All tables created

- GIVEN a fresh database instance
- WHEN the baseline migration completes
- THEN all ten tables exist and accept inserts

### Requirement: LDB-002 Versioned baseline migration

The database MUST declare an explicit schema version and a baseline migration; opening a fresh database MUST reach the current version without error.

#### Scenario: Fresh install migrates

- GIVEN an empty database file
- WHEN the database is opened
- THEN the schema version equals the declared baseline and opening succeeds

### Requirement: LDB-003 In-memory test database

The scaffold MUST support constructing the database in memory without platform channels so tests run under plain `flutter test`.

#### Scenario: Record round-trips in memory

- GIVEN an in-memory database
- WHEN an AudioRecord is inserted and read back
- THEN the record round-trips with identical field values

### Requirement: LDB-004 Codegen scope

Generated code MUST be limited to the database schema tables; build_runner SHALL NOT generate code for app models, view-models, or providers.

#### Scenario: Schema-only codegen

- GIVEN the project after `build_runner build`
- WHEN generated sources are inspected
- THEN generation is confined to database schema files

### Requirement: LDB-005 Cache vs download separation

CacheRecord (temporary, automatically reclaimable) and DownloadRecord (permanent, user-controlled) MUST be distinct tables; automatic cache cleanup SHALL NOT target DownloadRecord.

#### Scenario: Distinct record types

- GIVEN the schema
- WHEN CacheRecord and DownloadRecord are inspected
- THEN they are separate tables with distinct semantics

### Requirement: LDB-006 Identity fields

AudioRecord MUST include size, duration, and a SHA-256 content-hash field to support layered duplicate detection (size+duration pre-filter, hash authoritative).

#### Scenario: Identity fields populated

- GIVEN an AudioRecord row
- WHEN its fields are read
- THEN size, duration, and content-hash fields are populated

### Requirement: LDB-007 History read query

The app MUST provide a read query at the repository layer that returns recent play-history entries for a given content space (the `space` column), ordered by `playedAt` descending, capped at 20 entries. The 20-entry cap (BR-011) MUST be enforced in the app/repository layer via the product policy, not in the table definition.

#### Scenario: Most recent first, never exceeding the cap

- GIVEN a database with more than 20 history entries for one space
- WHEN the history query runs for that space
- THEN the result contains at most 20 entries
- AND entries are ordered by `playedAt` descending (most recent first)

#### Scenario: Filters by content space

- GIVEN history entries for both `local` and `cloud` spaces
- WHEN the history query runs with space `local`
- THEN only `local` entries are returned
- AND no `cloud` entries appear in the result

#### Scenario: No history for a space

- GIVEN no history entries exist for space `cloud`
- WHEN the history query runs with space `cloud`
- THEN the result is empty

### Requirement: LDB-008 Downloads read query

The app MUST provide a read query at the repository layer that returns explicit user downloads from the `downloads` table, filterable by transfer status (e.g., completed per BR-006), and ordered by creation/update time as defined for this change.

> Open question: the proposal does not define which timestamp (`createdAt` vs `updatedAt`) orders LDB-008 results nor the direction; the design phase must resolve this in a decision doc instead of guessing.

#### Scenario: Returns status-filtered downloads

- GIVEN download records with statuses including `completed` and `failed`
- WHEN the downloads query runs filtered to completed
- THEN only completed download records are returned

#### Scenario: Ordered by time as defined

- GIVEN completed downloads with distinct `createdAt`/`updatedAt` timestamps
- WHEN the downloads query runs
- THEN the result is ordered per the time ordering defined for this change

#### Scenario: No completed downloads

- GIVEN no download records with status `completed`
- WHEN the downloads query runs
- THEN the result is empty
