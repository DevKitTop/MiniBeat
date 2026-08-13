# Core User Flows

## Flow 01 - First launch without account

1. User opens the app.
2. App presents core navigation.
3. App explains optional Cloud benefits.
4. App requests Local media access as needed.
5. User chooses full device, SD, or specific folder scan.
6. App scans accessible media.
7. App indexes compatible audio.
8. User enters Local library.
9. User can play audio without Internet or account.

## Flow 02 - Register after using Local

1. User has existing Local library.
2. User chooses Cloud.
3. App offers Google authentication.
4. User signs in.
5. App creates/loads private Cloud space.
6. If Cloud is empty, app offers upload options.
7. User chooses individual content or broader upload.
8. App validates files before transfer.
9. App resolves conflicts when necessary.
10. Upload progress/results are presented.

## Flow 03 - Cloud streaming

1. User enters Cloud.
2. User selects an audio item.
3. App checks authentication/access.
4. App starts remote playback.
5. App buffers enough data for responsive start.
6. Temporary/local cache may be used.
7. Playback continues in background when supported.
8. User can pause/seek/skip.

## Flow 04 - Download Cloud audio

1. User selects a Cloud item or set of items.
2. User selects Download.
3. App checks local permissions/storage.
4. App downloads the original supported audio content.
5. App validates completion.
6. App indexes the local copy.
7. App marks the item as available in Local as well.
8. Failed downloads can be retried.

## Flow 05 - Upload Local audio

1. User selects Local item(s).
2. User chooses Upload.
3. App validates format/size/accessibility.
4. App checks Cloud for likely conflicts/duplicates.
5. If a conflict exists, show resolution UI.
6. User chooses action.
7. App uploads accepted files.
8. App updates Cloud metadata/index.

## Flow 06 - Search Local and Cloud

1. User opens Search.
2. Search initially targets configured scope (Local/Cloud/Both).
3. User types query.
4. Results update in real time.
5. User can open filters.
6. Results show origin indicators.
7. A result available in both spaces may show both indicators.

## Flow 07 - Playlist Local

1. User selects Local audio.
2. User adds item to an existing or new playlist.
3. Playlist stores a reference to the local item and order.
4. Playlist does not move the file.
5. User can reorder/remove references.
6. Removing a reference does not delete the source file.

## Flow 08 - Playlist Cloud

Same logical behavior as Local, but references resolve to Cloud items and persistence follows Cloud ownership.

## Flow 09 - Missing local file

1. App detects that an indexed Local file is missing/unreadable.
2. App marks the item unavailable.
3. Playback actions on the item fail gracefully without crashing.
4. Playlist references are invalidated/hidden when appropriate.
5. The source file is not deleted by the app merely because it is temporarily unavailable.

## Flow 10 - Loss of network during Cloud playback

1. Cloud audio is playing.
2. Network disappears.
3. App displays a subtle offline state.
4. Playback pauses when buffer is exhausted or playback can no longer continue.
5. App retries using bounded backoff/policy.
6. On connectivity recovery, app re-establishes playback.
7. User should not need to manually rebuild the queue.
