import 'dart:convert';

import 'package:clean_architecture_tdd_course/core/error/exceptions.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_remote_data_source_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockHttpClient;
  late NumberTriviaRemoteDataSourceImpl dataSource;
  setUp(() {
    mockHttpClient = MockClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  final tNumber = 1;
  final tNumberTriviaModel =
      NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

  final tConcreteUrl = Uri.parse('http://numbersapi.com/${tNumber}');
  final tRandomUrl = Uri.parse('http://numbersapi.com/random');

  _serverOkReponse(Uri url) {
    when(mockHttpClient.get(tConcreteUrl, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  _serverBadResponse() {
    when(mockHttpClient.get(tConcreteUrl, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('An error as occured', 404));
  }

  _randomServerOkResponse() {
    when(mockHttpClient.get(tRandomUrl, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  _randomServerBadResponse() {
    when(mockHttpClient.get(tRandomUrl, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 400));
  }

  group(
    "getConcreteNumberTrivia",
    () {
      test(
        "should perform a GET request on a url with number being the endpoint and with an application/json header",
        () async {
          //assert
          _serverOkReponse(tConcreteUrl);
          //act
          dataSource.getConcreteNumberTrivia(tNumber);
          //arrange
          verify(mockHttpClient.get(tConcreteUrl,
              headers: {'Content-Type': 'application/json'})).called(1);
        },
      );

      test(
        "should return a valid NumberTriviaModel",
        () async {
          //assert
          _serverOkReponse(tConcreteUrl);
          //act
          final result = await dataSource.getConcreteNumberTrivia(tNumber);
          //arrange
          expect(result, tNumberTriviaModel);
        },
      );

      test(
        "should return a serverException when the response code is 404",
        () async {
          //assert
          _serverBadResponse();
          //act

          final call = dataSource.getConcreteNumberTrivia;
          //arrange
          expect(() => call(tNumber), throwsA(TypeMatcher<ServerException>()));
        },
      );
    },
  );

  group(
    "getRandomNumberTrivia",
    () {
      test(
        "should perform a GET request on a url with random being the endpoint and with an application/json header ",
        () async {
          //assert
          _randomServerOkResponse();
          //act
          dataSource.getRandomNumberTrivia();
          //arrange
          verify(mockHttpClient
              .get(tRandomUrl, headers: {'Content-Type': 'application/json'}));
        },
      );

      test(
        "should return a NumberTrivia when the call is successful",
        () async {
          //assert
          _randomServerOkResponse();
          //act
          final result = await dataSource.getRandomNumberTrivia();
          //arrange
          expect(result, tNumberTriviaModel);
        },
      );

      test(
        "should return a Server Exception if the status code is not 200",
        () async {
          //assert
          _randomServerBadResponse();
          //act
          final call = dataSource.getRandomNumberTrivia;
          //arrange

          expect(() {
            return call();
          }, throwsA(TypeMatcher<ServerException>()));
        },
      );
    },
  );
}
