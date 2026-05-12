import 'song.dart';

class Playlist {
  const Playlist({
    required this.playlistId,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.localOnly,
  });

  final String playlistId;
  final String name;
  final PlaylistType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SyncStatus syncStatus;
}

enum PlaylistType { manual, recentlyAdded, mostPlayed, favorites }

class PlaylistSong {
  const PlaylistSong({
    required this.playlistId,
    required this.songId,
    required this.position,
    required this.addedAt,
  });

  final String playlistId;
  final String songId;
  final int position;
  final DateTime addedAt;
}