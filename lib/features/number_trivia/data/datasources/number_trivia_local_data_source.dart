import 'dart:convert';

import 'package:clean_architecture_tdd_course/core/error/exceptions.dart';

import '../models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class NumberTriviaLocalDataSource {
  /// Gets the cached [NumberTriviaModel] which was gotten the last time
  /// the user had an internet connection
  ///
  /// Throws a [CacheException] for all errors.
  Future<NumberTriviaModel>? getLastNumberTrivia();

  ///
  ///
  /// Throws a [CacheException] for all errors.
  Future<void>? cacheNumberTrivia(NumberTriviaModel numberTriviaModel);
}

const CACHED_NUMBER_TRIVIA = 'CACHED_NUMBER_TRIVIA';

class NumberTriviaLocalDataSourceImpl implements NumberTriviaLocalDataSource {
  NumberTriviaLocalDataSourceImpl({required this.sharedPreferences});

  final SharedPreferences sharedPreferences;
  @override
  Future<NumberTriviaModel>? getLastNumberTrivia() {
    final jsonString = sharedPreferences.getString(CACHED_NUMBER_TRIVIA);
    if (jsonString != null) {
      return Future.value(NumberTriviaModel.fromJson(json.decode(jsonString)));
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void>? cacheNumberTrivia(NumberTriviaModel numberTriviaModel) {
    return sharedPreferences.setString(
      CACHED_NUMBER_TRIVIA,
      json.encode(
        numberTriviaModel.toJson(),
      ),
    );
  }
}
