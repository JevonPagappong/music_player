import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'song_import_preparer.dart';

final songImportPreparerProvider = Provider<SongImportPreparer>((ref) {
  return SongImportPreparer();
});