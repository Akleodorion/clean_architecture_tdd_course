import 'package:clean_architecture_tdd_course/core/error/exceptions.dart';
import 'package:clean_architecture_tdd_course/core/error/failures.dart';
import 'package:clean_architecture_tdd_course/core/platform/network_info.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:mockito/mockito.dart';

import 'number_trivia_repository_impl_test.mocks.dart';

@GenerateMocks([
  NetworkInfo,
  NumberTriviaLocalDataSource,
  NumberTriviaRemoteDataSource,
  NumberTriviaRepositoryImpl
])
// @GenerateMocks([NumberTriviaLocalDataSource])
// @GenerateMocks([NumberTriviaRemoteDataSource])
// @GenerateMocks([NumberTriviaRepositoryImpl])
void main() {
  late MockNumberTriviaLocalDataSource mockLocalDataSource;
  late MockNumberTriviaRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  // Mockito ne construit pas les named parameter, donc on ne fait pas de mock pour le repo.
  late NumberTriviaRepositoryImpl repository;

  setUp(() {
    mockLocalDataSource = MockNumberTriviaLocalDataSource();
    mockRemoteDataSource = MockNumberTriviaRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
        networkInfo: mockNetworkInfo,
        localDataSource: mockLocalDataSource,
        remoteDataSource: mockRemoteDataSource);
  });

  void _isOnline() {
    when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
  }

  void _isOffline() {
    when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
  }

  group(
    "getConcreteNumberTrivia",
    () {
      final tNumber = 1;
      final tNumberTriviaModel =
          NumberTriviaModel(text: 'test text', number: tNumber);
      final NumberTrivia tNumberTrivia = tNumberTriviaModel;
      test(
        "Should check if the device is online",
        () async {
          // arrange
          _isOnline();

          // act
          repository.getConcreteNumberTrivia(tNumber);
          // assert

          verify(mockNetworkInfo.isConnected).called(1);
        },
      );

      group(
        "device is online",
        () {
          setUp(() {
            _isOnline();
          });

          test(
            "Should return remote data when the call to remoteDataSource is successful",
            () async {
              // arrange
              when(mockRemoteDataSource.getConcreteNumberTrivia(any))
                  .thenAnswer((_) async => tNumberTrivia);

              //act
              final result = await repository.getConcreteNumberTrivia(tNumber);
              //assert
              verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
              expect(result, equals(Right(tNumberTriviaModel)));
            },
          );

          test(
            "Should cache the data locally",
            () async {
              // arrange
              when(mockRemoteDataSource.getConcreteNumberTrivia(any))
                  .thenAnswer((_) async => tNumberTriviaModel);

              //act
              await repository.getConcreteNumberTrivia(tNumber);
              //assert
              verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
              verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
            },
          );

          test(
            "Should return server Failure when the call to remoteDataSource is unsuccessful",
            () async {
              // arrange
              when(mockRemoteDataSource.getConcreteNumberTrivia(any))
                  .thenThrow(ServerException());

              //act
              final result = await repository.getConcreteNumberTrivia(tNumber);
              //assert
              verifyZeroInteractions(mockLocalDataSource);
              expect(result, Left(ServerFailure()));
            },
          );
        },
      );

      group(
        "device is offline",
        () {
          setUp(() {
            _isOffline();
          });

          test(
            "should return last locally cached data when the cashed data is present",
            () async {
              //assert
              when(mockLocalDataSource.getLastNumberTrivia())
                  .thenAnswer((_) async => tNumberTriviaModel);
              //act
              final result = await repository.getConcreteNumberTrivia(tNumber);
              //arrange
              verifyZeroInteractions(mockRemoteDataSource);
              verify(mockLocalDataSource.getLastNumberTrivia()).called(1);
              expect(result, Right(tNumberTrivia));
            },
          );

          test(
            "should return chached failure when there is no data present",
            () async {
              //assert
              when(mockLocalDataSource.getLastNumberTrivia())
                  .thenThrow(CacheException());
              //act
              final result = await repository.getConcreteNumberTrivia(tNumber);
              //arrange
              verifyZeroInteractions(mockRemoteDataSource);
              verify(mockLocalDataSource.getLastNumberTrivia()).called(1);
              expect(result, Left(CacheFailure()));
            },
          );
        },
      );
    },
  );

  group(
    "getRandomNumberTrivia",
    () {
      test(
        "Should check is the devise is Online",
        () async {
          //assert
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
          //act
          await repository.getRandomNumberTrivia();
          //arrange
          verify(mockNetworkInfo.isConnected).called(1);
        },
      );

      group(
        "device is Online",
        () {
          setUp(() {
            _isOnline();
          });

          final tNumberTrivia = NumberTrivia(text: 'test text', number: 1);
          final tNumberTriviaModel =
              NumberTriviaModel(text: 'test text', number: 1);

          test(
            "should return a RandomNumberTriviaModel when the call to the api is successful",
            () async {
              //assert
              when(mockRemoteDataSource.getRandomNumberTrivia())
                  .thenAnswer((_) async => tNumberTrivia);
              //act
              final result = await repository.getRandomNumberTrivia();
              //arrange

              verify(mockRemoteDataSource.getRandomNumberTrivia()).called(1);
              expect(result, Right(tNumberTrivia));
            },
          );

          test(
            "should cache the last randomNumberTrivia retrieved",
            () async {
              //assert
              when(mockRemoteDataSource.getRandomNumberTrivia())
                  .thenAnswer((realInvocation) async => tNumberTrivia);
              //act
              await repository.getRandomNumberTrivia();
              //arrange
              verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
                  .called(1);
            },
          );

          test(
            "should return a ServerException when the call to the api is unsuccessful",
            () async {
              //assert
              when(mockRemoteDataSource.getRandomNumberTrivia())
                  .thenThrow(ServerException());
              //act
              final result = await repository.getRandomNumberTrivia();
              //arrange

              verify(mockRemoteDataSource.getRandomNumberTrivia()).called(1);
              expect(result, Left(ServerFailure()));
            },
          );
        },
      );

      group(
        "device is Offline",
        () {
          setUp(() {
            _isOffline();
          });

          final tNumberTriviaModel =
              NumberTriviaModel(text: 'test text', number: 1);
          test(
            "should return the last cached number trivia when data is present ",
            () async {
              //assert
              when(mockLocalDataSource.getLastNumberTrivia())
                  .thenAnswer((_) async => tNumberTriviaModel);
              //act
              final result = await repository.getRandomNumberTrivia();
              //arrange
              verify(mockLocalDataSource.getLastNumberTrivia()).called(1);
              expect(result, Right(tNumberTriviaModel));
            },
          );

          test(
            "should return a CacheFailure if when there is no data present ",
            () async {
              //assert
              when(mockLocalDataSource.getLastNumberTrivia())
                  .thenThrow(CacheException());
              //act
              final result = await repository.getRandomNumberTrivia();
              //arrange
              verify(mockLocalDataSource.getLastNumberTrivia()).called(1);
              expect(result, Left(CacheFailure()));
            },
          );
        },
      );
    },
  );
}
