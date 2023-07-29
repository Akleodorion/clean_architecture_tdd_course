import 'package:clean_architecture_tdd_course/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_concrete_number_trivia_test.mocks.dart';

@GenerateMocks([NumberTriviaRepository])
void main() {
  late MockNumberTriviaRepository mockNumberTriviaRepository;
  late GetConcreteNumberTrivia usecase;
  late int tNumber;
  late NumberTrivia tNumberTrivia;

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    usecase = GetConcreteNumberTrivia(mockNumberTriviaRepository);
    tNumberTrivia = NumberTrivia(number: 1, text: 'test');
    tNumber = 1;
  });

  test(
    'should get trivia for the number from the repository',
    () async {
      // arange
      when(mockNumberTriviaRepository.getConcreteNumberTrivia(tNumber))
          .thenAnswer((_) async => await Right(tNumberTrivia));
      // act
      final result = await usecase(Params(number: tNumber));
      // assert
      verify(mockNumberTriviaRepository.getConcreteNumberTrivia(tNumber));
      expect(result, Right(tNumberTrivia));
      verifyNoMoreInteractions(mockNumberTriviaRepository);
    },
  );
}
