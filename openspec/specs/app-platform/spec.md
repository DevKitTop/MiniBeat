# App Platform Specification

## Purpose

Defines Android and iOS platform configuration for background audio, notifications, deep links, and Google OAuth, plus repository operating rules and the lint baseline for rep_mini. Configuration only: no platform logic beyond wiring that compiles. New capability (baseline spec).

## Requirements

### Requirement: PLT-001 Android background audio

The Android manifest MUST declare a foreground-service type of `mediaPlayback` and the `POST_NOTIFICATIONS` permission to support background audio on Android 13+ (Android 14-17 background-audio hardening).

#### Scenario: Manifest declares FGS and notification permission

- GIVEN the AndroidManifest.xml
- WHEN it is inspected
- THEN a foreground-service with type `mediaPlayback` and the `POST_NOTIFICATIONS` permission are declared

### Requirement: PLT-002 iOS background audio

The iOS Info.plist MUST declare `UIBackgroundModes` containing `audio`.

#### Scenario: Background audio mode present

- GIVEN the iOS Info.plist
- WHEN it is inspected
- THEN `UIBackgroundModes` includes `audio`

### Requirement: PLT-003 Deep links

The scaffold MUST include placeholder deep-link configuration: an Android app-link intent filter and the iOS associated-domains capability.

#### Scenario: Deep-link placeholders present

- GIVEN the platform configurations
- WHEN they are inspected
- THEN the Android app-link intent filter and iOS associated domains exist

### Requirement: PLT-004 Google OAuth wiring

Platform configurations MUST reserve Google OAuth wiring — Android client/SHA-1 placeholders and an iOS reversed client-ID placeholder — with no real credentials committed.

#### Scenario: OAuth placeholders only

- GIVEN the platform configurations
- WHEN they are scanned for credentials
- THEN only placeholder values exist and no real client secrets are present

### Requirement: PLT-005 Repository operating rules

The repository root MUST contain AGENTS.md documenting the security rules: no secrets in code or logs, Local/Cloud separation, and the ADR rule for architecture changes.

#### Scenario: AGENTS.md exists at root

- GIVEN the repository root
- WHEN it is inspected
- THEN AGENTS.md exists and documents security and architecture-change rules

### Requirement: PLT-006 Lint baseline

The project MUST ship `analysis_options.yaml` with the chosen lint set, and `flutter analyze` MUST pass cleanly.

#### Scenario: Analyze passes

- GIVEN the configured project
- WHEN `flutter analyze` runs
- THEN it exits without errors
