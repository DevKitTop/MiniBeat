# Local Persistence, Cache and Synchronization

## Local database

A local database is required for both authenticated and anonymous users.

It stores metadata and state, not the source audio files themselves.

Conceptual records:

```text
AudioRecord
FolderRecord
PlaylistRecord
PlaylistItemRecord
FavoriteRecord
HistoryRecord
DownloadRecord
CacheRecord
AppSettingsRecord
PlaybackStateRecord
```

The exact database technology remains open until current Flutter ecosystem options are compared for:

- query performance;
- migrations;
- reliability;
- isolates/background access;
- code generation overhead;
- package maturity.

## Cache

Streaming cache and permanent downloads must be distinct concepts.

```text
Remote stream
   |
   +-- temporary cache --> automatically reclaimable
   |
   +-- permanent download --> user-controlled local copy
```

Automatic cache cleanup must never delete an explicit user download.

## Synchronization model

Synchronization is user-initiated and reviewable.

The system should compare song-level identities using more than filename alone. Candidate identity inputs:

1. content hash;
2. normalized metadata;
3. duration;
4. size;
5. name/path for display and conflict explanation.

The hash is the strongest candidate for actual content equality. Name is primarily a user-facing conflict signal.

## Conflict states

At minimum the synchronization engine must be able to distinguish:

```text
LOCAL_ONLY
CLOUD_ONLY
BOTH_SAME
BOTH_DIFFERENT
```

The UI may present only Local/Cloud filters while using the additional internal state to explain conflicts.

## Conflict resolution

Potential conflict actions:

- keep Local;
- keep Cloud;
- keep both;
- replace;
- cancel.

The user must approve destructive changes.

## Sync percentage

The exact formula is intentionally open.

Recommended initial interpretation: percentage of comparable song records that are equivalent by the chosen identity rules.

Do not describe this percentage as a full library synchronization score until folders, playlists, favorites and metadata are also included.

## File lifecycle

Local missing file:

```text
Indexed record
   -> file missing
   -> reconcile
   -> mark invalid/remove from active library
   -> notify user when meaningful
```

Cloud missing/deleted object:

```text
Cloud record
   -> object unavailable
   -> surface recoverable error
   -> allow retry/re-download where applicable
```
