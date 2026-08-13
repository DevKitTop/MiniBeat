# Cloud and Storage Decision Notes

## Requirements

Cloud storage must provide:

- private per-user audio storage;
- metadata database;
- folder hierarchy;
- playlists;
- favorites;
- cloud history;
- downloads;
- streaming;
- resumable/retriable transfers where practical;
- strict user isolation.

## Current leading candidate: Supabase

Supabase is currently the leading candidate because its Storage supports private buckets, access control through RLS, authenticated downloads, and time-limited signed URLs. Private buckets are the default access model. citeturn405078search0turn405078search1

Its storage API also supports uploads/updates and signed URLs, which align with the private streaming/download model needed here. citeturn405078search14turn405078search17

## Proposed conceptual model

```text
Auth User
   |
   +-- Database rows
   |     +-- audio metadata
   |     +-- folders
   |     +-- playlists
   |     +-- favorites
   |     +-- history
   |
   +-- Private Storage
         +-- audio objects
         +-- artwork/derived assets
```

## Security rule

No permanent public audio URLs.

Cloud playback should use authenticated access and/or time-limited signed URLs as appropriate to the selected streaming architecture. Supabase private buckets are specifically designed for this access model. citeturn405078search0turn405078search8

## Still to investigate

- Cost at expected audio storage sizes.
- Upload/download limits and recommended chunking.
- Resumable uploads for the chosen Flutter client.
- Whether direct client upload is sufficient for MVP or a server-mediated workflow is needed.
- Signed URL lifetime appropriate for streaming.
- Storage object naming strategy.
- RLS policy model.
- Database schema and indexes.
- Backup/export strategy.

## Storage hierarchy candidate

```text
user/{userId}/
  audio/
    ...user-defined folder hierarchy...
  artwork/
    ...derived assets...
```

This is a conceptual proposal, not a locked implementation path.
