/// Explicit, user-initiated cloud transfer contract (BR-006).
///
/// DEFERRED (interface only): the Supabase TUS resumable implementation lands
/// with the transfer feature. Uploads and downloads are always explicit user
/// actions; nothing transfers automatically.
abstract interface class TransferService {
  Future<void> upload({
    required String filePath,
    required String cloudObjectId,
  });

  Future<void> download({
    required String cloudObjectId,
    required String filePath,
  });
}
