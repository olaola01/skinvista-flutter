import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skinvista/bloc/consultation/create_consultation_bloc.dart';

import '../bloc/consultation/fetch_consultations_bloc.dart';
import '../bloc/diagnosis/delete_diagnosis_bloc.dart';
import '../bloc/diagnosis/fetch_diagnoses_bloc.dart';
import '../bloc/diagnosis/save_diagnosis_bloc.dart';
import '../bloc/game_score/save_game_score_bloc.dart';
import '../bloc/leaderboard/leaderboard_bloc.dart';
import '../bloc/user/withdraw_bloc.dart';
import '../repositories/auth_repository.dart';
import '../repositories/consultation_repository.dart';
import '../repositories/diagnosis_repository.dart';
import '../repositories/game_score_repository.dart';
import '../repositories/prediction_repository.dart';
import 'api_client/api_client.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // Register SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  getIt.registerLazySingleton<ApiClient>(
        () => ApiClient(baseUrl: 'https://veronicaadeusi.com/skinvista/api'),
  );
  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepository(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<PredictionRepository>(
        () => PredictionRepository(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<DiagnosisRepository>(
        () => DiagnosisRepository(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ConsultationRepository>(
        () => ConsultationRepository(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<GameScoreRepository>(
        () => GameScoreRepository(apiClient: getIt<ApiClient>()),
  );
  getIt.registerFactory<WithdrawBloc>(
        () => WithdrawBloc(apiClient: getIt<ApiClient>()),
  );

  // Register BLoCs
  getIt.registerFactory<SaveDiagnosisBloc>(
        () => SaveDiagnosisBloc(repository: getIt<DiagnosisRepository>()),
  );
  getIt.registerFactory<CreateConsultationBloc>(
        () => CreateConsultationBloc(repository: getIt<ConsultationRepository>()),
  );
  getIt.registerFactory<DeleteDiagnosisBloc>( // Add this registration
        () => DeleteDiagnosisBloc(repository: getIt<DiagnosisRepository>()),
  );
  getIt.registerFactory<FetchDiagnosesBloc>( // Add this registration
        () => FetchDiagnosesBloc(repository: getIt<DiagnosisRepository>()),
  );
  getIt.registerFactory<SaveGameScoreBloc>(
        () => SaveGameScoreBloc(repository: getIt<GameScoreRepository>()),
  );
  getIt.registerFactory<LeaderboardBloc>(
        () => LeaderboardBloc(repository: getIt<GameScoreRepository>()),
  );
  getIt.registerFactory<FetchConsultationsBloc>(
        () => FetchConsultationsBloc(repository: getIt<ConsultationRepository>()),
  );
}