import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('SongRecord')
class Songs extends Table {
  TextColumn get songId => text()();
  TextColumn get filePath => text()();
  TextColumn get originalFileName => text()();
  TextColumn get title => text()();
  TextColumn get artist => text()();
  TextColumn get album => text()();
  IntColumn get durationMs => integer()();
  TextColumn get format => text()();
  IntColumn get fileSizeBytes => integer()();
  TextColumn get artworkPath => text().nullable()();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastPlayedAt => dateTime().nullable()();
  DateTimeColumn get importedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('localOnly'))();

  @override
  Set<Column> get primaryKey => {songId};
}

@DataClassName('PlaylistRecord')
class Playlists extends Table {
  TextColumn get playlistId => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('localOnly'))();

  @override
  Set<Column> get primaryKey => {playlistId};
}

@DataClassName('PlaylistSongRecord')
class PlaylistSongs extends Table {
  TextColumn get playlistId => text()();
  TextColumn get songId => text()();
  IntColumn get position => integer()();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {playlistId, songId};
}

@DataClassName('LyricsRecord')
class LyricsEntries extends Table {
  TextColumn get lyricsId => text()();
  TextColumn get songId => text()();
  TextColumn get sourceType => text()();
  TextColumn get plainText => text().nullable()();
  TextColumn get lrcPath => text().nullable()();
  TextColumn get timingData => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('localOnly'))();

  @override
  Set<Column> get primaryKey => {lyricsId};
}

@DriftDatabase(
  tables: [
    Songs,
    Playlists,
    PlaylistSongs,
    LyricsEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'offline_music'));

  @override
  int get schemaVersion => 1;
}