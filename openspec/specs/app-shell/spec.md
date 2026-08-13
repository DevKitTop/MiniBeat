# App Shell Specification

## Purpose

Defines the compileable app entry point, Material 3 theme, three-branch navigation shell, Riverpod provider scope, and MVVM/Repository-lite folder skeleton for rep_mini. Scaffold only: no playback UI, no real auth flow, no feature implementations. New capability (baseline spec).

## Requirements

### Requirement: ASH-001 App entry

The app MUST provide a `main()` entry that loads configuration, wires a Riverpod `ProviderScope`, and starts a single `MaterialApp.router` instance backed by one go_router router.

#### Scenario: App boots to Local

- GIVEN the app is launched
- WHEN `main()` runs
- THEN `ProviderScope` wraps the routed app and the initial location resolves to `/local`

### Requirement: ASH-002 Material 3 theme

The app theme MUST follow Material Design 3 and use a Google font family; Roboto SHALL be the default and Google Sans SHALL NOT be bundled without a license (licensing caveat documented in the theme source).

#### Scenario: Theme follows Material 3

- GIVEN a widget test pumps the app
- WHEN the theme is inspected
- THEN ThemeData follows Material 3 and the configured Google font family resolves

### Requirement: ASH-003 Navigation shell

The app MUST use a `StatefulShellRoute.indexedStack` with three branches — `/local`, `/cloud`, `/settings` — each rendering its own placeholder screen and preserving its own navigation state.

#### Scenario: Branch switching preserves state

- GIVEN the app is on `/local`
- WHEN the user switches to `/settings` and back to `/local`
- THEN each branch retains its stack state

### Requirement: ASH-004 Auth gating

The Cloud branch MUST redirect unauthenticated users to a sign-in placeholder route; Local and Settings MUST remain accessible without authentication (BR-003, BR-004).

#### Scenario: Cloud redirects when signed out

- GIVEN the auth provider reports no session
- WHEN the user navigates to `/cloud`
- THEN the router redirects to the sign-in placeholder route

#### Scenario: Local accessible signed out

- GIVEN the auth provider reports no session
- WHEN the user navigates to `/local` or `/settings`
- THEN the route renders without redirect

### Requirement: ASH-005 Riverpod scope

Riverpod providers MUST use the manual Notifier/Provider API only — no codegen and no legacy imports. The scaffold SHALL provide an `AuthSession` provider that defaults to unauthenticated.

#### Scenario: Provider override gates Cloud

- GIVEN a test overrides the auth provider with an authenticated session
- WHEN the router redirect evaluates `/cloud`
- THEN Cloud navigation is permitted

### Requirement: ASH-006 Folder skeleton

`lib/` MUST contain `presentation/features/{local-library,cloud-library,settings}`, `view-models/`, `repositories/`, `services/`, `audio/`, and `data/`; a domain layer SHALL NOT exist.

#### Scenario: Skeleton exists without domain layer

- GIVEN the scaffold is built
- WHEN the `lib/` folder tree is inspected
- THEN all required folders exist and no `domain/` folder exists
