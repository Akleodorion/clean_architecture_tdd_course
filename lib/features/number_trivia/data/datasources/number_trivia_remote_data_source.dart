import 'dart:convert';

import 'package:clean_architecture_tdd_course/core/error/exceptions.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';

import '../../domain/entities/number_trivia.dart';
import 'package:http/http.dart' as http;

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

class NumberTriviaRemoteDataSourceImpl implements NumberTriviaRemoteDataSource {
  final http.Client client;

  NumberTriviaRemoteDataSourceImpl({required this.client});
  @override
  Future<NumberTrivia>? getConcreteNumberTrivia(int number) =>
      _getNumberTriviaFromUrl('http://numbersapi.com/${number}');

  @override
  Future<NumberTrivia>? getRandomNumberTrivia() =>
      _getNumberTriviaFromUrl('http://numbersapi.com/random');

  Future<NumberTrivia>? _getNumberTriviaFromUrl(String url) async {
    final response = await client
        .get(Uri.parse(url), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      final numberTrivia =
          NumberTriviaModel.fromJson(json.decode(response.body));
      return numberTrivia;
    } else {
      throw ServerException();
    }
  }
}
