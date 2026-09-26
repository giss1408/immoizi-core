import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../theme.dart';
import '../i18n/tr.dart';

class VideoCard extends StatelessWidget {
  const VideoCard({required this.videoUrl, required this.title, super.key});

  final String videoUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) =>
                  VideoPlayerPage(videoUrl: videoUrl, title: title)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: IvoryColors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.play_circle_fill,
                    color: IvoryColors.green, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr('Vidéo de présentation'),
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: TextStyle(fontSize: 12, color: IvoryColors.muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: IvoryColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage(
      {required this.videoUrl, required this.title, super.key});

  final String videoUrl;
  final String title;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? controller;
  bool initialized = false;
  String? error;

  @override
  void initState() {
    super.initState();
    final uri = Uri.tryParse(widget.videoUrl.trim());
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      error = tr('URL vidéo invalide.');
      return;
    }

    final player = VideoPlayerController.networkUrl(uri);
    controller = player;
    player.initialize().then((_) {
      if (!mounted) return;
      setState(() => initialized = true);
      player.play();
    }).catchError((_) {
      if (!mounted) return;
      final reason = player.value.errorDescription;
      setState(() {
        error = reason == null || reason.trim().isEmpty
            ? tr(
                'Impossible de lire la vidéo. Vérifiez votre connexion et le format du fichier.')
            : tr('Impossible de lire la vidéo. Cause détectée : {reason}',
                {'reason': reason});
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = controller;
    final ready = initialized && player != null;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title),
      ),
      body: Center(
        child: error != null
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.orangeAccent, size: 42),
                    const SizedBox(height: 12),
                    Text(
                      error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              )
            : ready
                ? AspectRatio(
                    aspectRatio: player.value.aspectRatio,
                    child: VideoPlayer(player),
                  )
                : const CircularProgressIndicator(color: Colors.white),
      ),
      floatingActionButton: ready
          ? FloatingActionButton(
              backgroundColor: IvoryColors.green,
              onPressed: () => setState(() {
                player.value.isPlaying ? player.pause() : player.play();
              }),
              child:
                  Icon(player.value.isPlaying ? Icons.pause : Icons.play_arrow),
            )
          : null,
    );
  }
}
