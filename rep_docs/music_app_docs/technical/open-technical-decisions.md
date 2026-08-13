# Open Technical Decisions

These decisions must be researched or verified before implementation locks them.

## High priority

- [ ] Final audio engine package/version compatibility.
- [ ] Audio session/interruption package and platform configuration.
- [ ] Local media indexing/package strategy for Android + iOS.
- [ ] Exact local database technology.
- [ ] Final Cloud provider: Supabase remains the leading candidate.
- [ ] Storage cost and limits for expected MVP usage.
- [ ] Private streaming mechanism and signed URL lifetime.
- [ ] Resumable/background upload and download implementation.
- [ ] File identity/hash strategy.
- [ ] Sync percentage formula.
- [ ] Conflict-resolution UI and action semantics.
- [ ] State-management solution.
- [ ] Navigation solution.

## Medium priority

- [ ] Exact supported audio codecs/formats for MVP.
- [ ] Exact maximum file size.
- [ ] Cache size/reclamation policy.
- [ ] Playback-position persistence policy.
- [ ] Metadata extraction library.
- [ ] Artwork extraction and caching strategy.
- [ ] Whether direct cloud client access is sufficient or server functions are required.
- [ ] Android Auto / CarPlay implementation path.

## Explicitly postponed

- [ ] Social features.
- [ ] Public sharing.
- [ ] Premium tiers.
- [ ] Additional auth providers.
- [ ] Equalizer/audio effects.
- [ ] Advanced metadata editing.
