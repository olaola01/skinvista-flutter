import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:skinvista/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:skinvista/bloc/leaderboard/leaderboard_event.dart';
import 'package:skinvista/bloc/leaderboard/leaderboard_state.dart';
import 'package:skinvista/repositories/game_score_repository.dart';
import 'package:skinvista/screens/home.dart';
import 'package:skinvista/screens/skincare_pop.dart';

import '../core/locator.dart';
import '../core/widgets/text_widget.dart';

class LeaderboardPage extends StatelessWidget {
  final bool fromGame;

  const LeaderboardPage({super.key, this.fromGame = false});

  @override
  Widget build(BuildContext context) {
    return LeaderboardView(fromGame: fromGame);
  }
}

class LeaderboardView extends StatelessWidget {
  final bool fromGame;

  const LeaderboardView({super.key, required this.fromGame});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LeaderboardBloc(repository: getIt<GameScoreRepository>())
        ..add(FetchLeaderboard()),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF40C4FF),
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(width: 8),
              TextWidget(
                text: 'Leaderboard',
                textAlign: TextAlign.center, color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24,
              ),
            ],
          ),
          elevation: 0,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF40C4FF), Color(0xFFCE93D8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: BlocConsumer<LeaderboardBloc, LeaderboardState>(
            listener: (context, state) {
              if (state is LeaderboardFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${state.error}')),
                );
              }
            },
            builder: (context, state) {
              print('Leaderboard State: $state');
              if (state is LeaderboardInitial) {
                print('Dispatching FetchLeaderboard event');
                context.read<LeaderboardBloc>().add(FetchLeaderboard());
                return const Center(child: CircularProgressIndicator());
              } else if (state is LeaderboardLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is LeaderboardLoaded) {
                print('Leaderboard Loaded with ${state.scores.length} scores');
                return Column(
                  children: [
                    Expanded(
                      child: state.scores.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.emoji_events_outlined,
                              color: Colors.white70,
                              size: 60,
                            ),
                            const SizedBox(height: 16),
                            const TextWidget(
                              text: 'No scores available yet. Play the game to add your score!',
                              textAlign: TextAlign.center, color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SkincarePop()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6F61),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: const TextWidget(
                                text: 'Play Now',
                                textAlign: TextAlign.center, color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                          : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.scores.length,
                        itemBuilder: (context, index) {
                          final score = state.scores[index];
                          return Card(
                            color: Colors.white.withOpacity(0.9),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF40C4FF),
                                child: index == 0
                                    ? const Icon(
                                  Icons.emoji_events,
                                  color: Colors.white,
                                  size: 20,
                                )
                                    : Text(
                                  '${index + 1}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                score.userEmail,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Score: ${score.score} • ${DateFormat('d MMM yyyy').format(score.createdAt)}',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (state.scores.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SkincarePop()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6F61),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: const Text('Play Again', style: TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(height: 16),
                            if(fromGame)
                              ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/dashboard');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6F61),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: const Text('Return to Home', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              } else if (state is LeaderboardFailure) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white70,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${state.error}',
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<LeaderboardBloc>().add(FetchLeaderboard());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6F61),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text('Retry', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              }
              return const Center(child: Text('Something went wrong', style: TextStyle(color: Colors.white)));
            },
          ),
        ),
      ),
    );
  }
}