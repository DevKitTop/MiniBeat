import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_session_provider.dart';
import '../cloud-library/cloud_library_screen.dart';
import '../cloud-library/sign_in_screen.dart';
import '../local-library/local_library_screen.dart';

/// Content space selected inside the Music screen (D9).
enum MusicSpace { local, cloud }

/// Music screen (ASH-004): hosts the Local/Cloud content-space toggle.
///
/// The selected space is ephemeral widget state (D9) — the segment selection
/// is scoped to this screen and preserved across branch switches by
/// `StatefulShellRoute.indexedStack`. The Cloud space is gated IN-SCREEN:
/// unauthenticated users see [SignInScreen], authenticated users see
/// [CloudLibraryScreen] (BR-003/004). There is no router-level redirect.
class MusicScreen extends ConsumerStatefulWidget {
  const MusicScreen({super.key});

  @override
  ConsumerState<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends ConsumerState<MusicScreen> {
  MusicSpace _space = MusicSpace.local;

  @override
  Widget build(BuildContext context) {
    final authed = ref.watch(authSessionProvider).isAuthenticated;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SegmentedButton<MusicSpace>(
            segments: const [
              ButtonSegment(value: MusicSpace.local, label: Text('Local')),
              ButtonSegment(value: MusicSpace.cloud, label: Text('Cloud')),
            ],
            selected: {_space},
            onSelectionChanged: (selection) =>
                setState(() => _space = selection.first),
          ),
        ),
        Expanded(
          child: switch (_space) {
            MusicSpace.local => const LocalLibraryScreen(),
            MusicSpace.cloud =>
              authed ? const CloudLibraryScreen() : const SignInScreen(),
          },
        ),
      ],
    );
  }
}
