class PlaybackQueueItem {
  const PlaybackQueueItem({
    required this.queueItemId,
    required this.songId,
    required this.position,
    required this.sourceType,
    this.sourceId,
  });

  final String queueItemId;
  final String songId;
  final int position;
  final QueueSourceType sourceType;
  final String? sourceId;
}

enum QueueSourceType { song, playlist, autoPlaylist, search }