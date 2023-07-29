import 'dart:convert';

import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  final tNumberTriviaModel = NumberTriviaModel(text: 'test text', number: 1);

  test(
    "Should be a subclass of NumberTrivia",
    () async {
      // assert
      expect(tNumberTriviaModel, isA<NumberTrivia>());
    },
  );

  group('fromJson', () {
    test(
      "Should return a valid model when the Json number is an integer.",
      () async {
        //arrange
        final Map<String, dynamic> jsonMap =
            json.decode(fixture('trivia.json'));
        //act
        final result = NumberTriviaModel.fromJson(jsonMap);
        //assert
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      "Should return a valid model when the Json number is a double",
      () async {
        //arrange
        final Map<String, dynamic> jsonMap =
            json.decode(fixture('trivia_double.json'));
        //act
        final result = NumberTriviaModel.fromJson(jsonMap);
        //assert
        expect(result, equals(tNumberTriviaModel));
      },
    );

    group(
      "toJson",
      () {
        test(
          "Should return a json file ",
          () async {
            // act
            final result = tNumberTriviaModel.toJson();
            // assert
            final expectedResult = {
              "text": "test text",
              "number": 1,
            };
            expect(result, expectedResult);
          },
        );
      },
    );
  });
}
