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
