import 'dart:convert';

import 'package:clean_architecture_tdd_course/core/error/exceptions.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_local_data_source_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late NumberTriviaLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(
        sharedPreferences: mockSharedPreferences);
  });

  group(
    "getLastNumberTrivia",
    () {
      final tNumberTriviaModel = NumberTriviaModel.fromJson(
          json.decode(fixture('trivia_cached.json')));
      test(
        "should return the last cached NumberTrivia if there is data in the cache",
        () async {
          //assert
          when(mockSharedPreferences.getString(any))
              .thenReturn(fixture('trivia_cached.json'));
          //act
          final result = await dataSource.getLastNumberTrivia();
          //arrange

          verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
          expect(result, tNumberTriviaModel);
        },
      );

      test('should throw a CacheException when there is not a cached value',
          () async {
        //arrange
        when(mockSharedPreferences.getString(any)).thenReturn(null);
        //act
        final call = dataSource.getLastNumberTrivia;
        //assert
        expect(() => call(), throwsA(TypeMatcher<CacheException>()));
      });
    },
  );

  group(
    "cacheNumberTrivia",
    () {
      final tNumberTriviaModel =
          NumberTriviaModel(text: 'test text', number: 1);

      test(
        "should call the sharedPreferences to cache the data ",
        () async {
          when(mockSharedPreferences.setString(any, any))
              .thenAnswer((realInvocation) async => true);
          //act
          dataSource.cacheNumberTrivia(tNumberTriviaModel);
          //arrange
          final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
          verify(mockSharedPreferences.setString(
              CACHED_NUMBER_TRIVIA, expectedJsonString));
        },
      );
    },
  );
}
