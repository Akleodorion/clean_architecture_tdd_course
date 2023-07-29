import '../../domain/entities/number_trivia.dart';

abstract class NumberTriviaRemoteDataSource {

  /// Call the http://numbersapi.com/${number}
  ///
  /// Throws a [ServerException] for all errors.
  Future<NumberTrivia>? getConcreteNumberTrivia(int number);

  /// Call the http://numbersapi.com/random
  ///
  /// Throws a [ServerException] for all errors.
  Future<NumberTrivia>? getRandomNumberTrivia();
}
