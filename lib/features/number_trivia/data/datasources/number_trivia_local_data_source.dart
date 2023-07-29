import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';

abstract class NumberTriviaLocalDataSource {
  /// Gets the cached [NumberTriviaModel] which was gotten the last time
  /// the user had an internet connection
  ///
  /// Throws a [CacheException] for all errors.
  Future<NumberTriviaModel>? getCachedNumberTrivia();

  /// 
  ///
  /// Throws a [CacheException] for all errors.
  Future<void>? cacheNumberTrivia(NumberTriviaModel numberTriviaModel);
}
