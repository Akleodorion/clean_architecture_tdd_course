import 'package:clean_architecture_tdd_course/core/error/exceptions.dart';
import 'package:clean_architecture_tdd_course/core/error/failures.dart';
import 'package:clean_architecture_tdd_course/core/platform/network_info.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:dartz/dartz.dart';

class NumberTriviaRepositoryImpl implements NumberTriviaRepository {
  const NumberTriviaRepositoryImpl({
    required this.networkInfo,
    required this.localDataSource,
    required this.remoteDataSource,
  });

  final NetworkInfo networkInfo;
  final NumberTriviaLocalDataSource localDataSource;
  final NumberTriviaRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, NumberTrivia>>? getConcreteNumberTrivia(
      int number) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteTrivia =
            await remoteDataSource.getConcreteNumberTrivia(number);
        await localDataSource.cacheNumberTrivia(NumberTriviaModel(
            text: remoteTrivia!.text, number: remoteTrivia.number));
        return Right(remoteTrivia);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localTrivia = await localDataSource.getLastNumberTrivia();
        return Right(localTrivia!);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, NumberTrivia>>? getRandomNumberTrivia() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteRandomTrivia =
            await remoteDataSource.getRandomNumberTrivia();
        localDataSource.cacheNumberTrivia(NumberTriviaModel(
            text: remoteRandomTrivia!.text, number: remoteRandomTrivia.number));
        return Right(remoteRandomTrivia);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localNumberTrivia = await localDataSource.getLastNumberTrivia();
        return Right(localNumberTrivia!);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}
