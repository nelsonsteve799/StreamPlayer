import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/modals/SongModal.dart';
import 'package:music_player/modals/SeekBar.dart';
import 'package:rxdart/rxdart.dart' as rxdart;

/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////-USING-/////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({super.key});

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  Song songs = Song.songs[0];
  final player = AudioPlayer(); // Create a player

  void GetAudio() async {
    final duration = await player.setAsset(Song.songs[0].url);
  }

  @override
  void initState() {
    super.initState();
    GetAudio();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Stream<SeekBarData> get _seekBarDataStream =>
      rxdart.Rx.combineLatest2<Duration, Duration?, SeekBarData>(
          player.positionStream, player.durationStream, (
        Duration position,
        Duration? duration,
      ) {
        return SeekBarData(
          position,
          duration ?? Duration.zero,
        );
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   leading: const Icon(Icons.grid_view_rounded),
      // ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
              Color.fromARGB(255, 47, 48, 49),
              Color.fromARGB(255, 8, 3, 3),
            ])),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.1,
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Blinding Lights",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text("The Weeknd"),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                    image: DecorationImage(
                      image: AssetImage(Song.songs[0].coverUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.2,
                color: Colors.transparent,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.065,
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Icon(
                              Icons.playlist_remove_sharp,
                              color: Colors.white,
                            ),
                            Icon(
                              Icons.playlist_play_rounded,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: StreamBuilder<SeekBarData>(
                            stream: _seekBarDataStream,
                            builder: (context, snapshot) {
                              final positionData = snapshot.data;
                              return SeekBar(
                                position:
                                    positionData?.position ?? Duration.zero,
                                duration:
                                    positionData?.duration ?? Duration.zero,
                                onChangeEnd: player.seek,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.15,
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(
                            Icons.play_arrow,
                            color: Colors.transparent,
                          ),
                          const Icon(
                            Icons.skip_previous_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                          StreamBuilder<PlayerState>(
                            stream: player.playerStateStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final playerState = snapshot.data;
                                final processingState =
                                    playerState!.processingState;

                                if (processingState ==
                                        ProcessingState.loading ||
                                    processingState ==
                                        ProcessingState.buffering) {
                                  return Container(
                                    width: 64.0,
                                    height: 64.0,
                                    margin: const EdgeInsets.all(10.0),
                                    child: const CircularProgressIndicator(),
                                  );
                                } else if (!player.playing) {
                                  return IconButton(
                                    onPressed: player.play,
                                    iconSize: 75,
                                    icon: const Icon(
                                      Icons.play_circle,
                                      color: Colors.white,
                                    ),
                                  );
                                } else if (processingState !=
                                    ProcessingState.completed) {
                                  return IconButton(
                                    icon: const Icon(
                                      Icons.pause_circle,
                                      color: Colors.white,
                                    ),
                                    iconSize: 75.0,
                                    onPressed: player.pause,
                                  );
                                } else {
                                  return IconButton(
                                    icon: const Icon(
                                      Icons.replay_circle_filled_outlined,
                                      color: Colors.white,
                                    ),
                                    iconSize: 75.0,
                                    onPressed: () => player.seek(
                                      Duration.zero,
                                      index: player.effectiveIndices!.first,
                                    ),
                                  );
                                }
                              } else {
                                return const CircularProgressIndicator();
                              }
                            },
                          ),
                          const Icon(
                            Icons.skip_next_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                          const Icon(
                            Icons.play_arrow,
                            color: Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                    // Container(
                    //   width: double.infinity,
                    //   height: MediaQuery.of(context).size.height * 0.01,
                    //   color: Colors.amber,
                    // )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
