import 'package:clean_architecture_tdd_course/core/error/failures.dart';
import 'package:clean_architecture_tdd_course/core/usecases/usecase.dart';
import 'package:clean_architecture_tdd_course/core/util/input_converter.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateMocks([GetConcreteNumberTrivia])
@GenerateMocks([GetRandomNumberTrivia])
@GenerateMocks([InputConverterImpl])
void main() {
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverterImpl mockInputConverter;
  late NumberTriviaBloc bloc;

  setUp(() {
    mockInputConverter = MockInputConverterImpl();
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    bloc = NumberTriviaBloc(
        getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
        getRandomNumberTrivia: mockGetRandomNumberTrivia,
        inputConverter: mockInputConverter);
  });

  test(
    "should initialize the test with an empty state",
    () async {
      //arrange
      expect(bloc.initialState, Empty());
    },
  );

  group(
    "getTriviaForConcreteNumber",
    () {
      final tNumberString = '1';
      final tNumberParsed = 1;
      final tNumberTrivia =
          NumberTrivia(text: 'test text', number: tNumberParsed);

      void setUpMockInputConverterSucess() =>
          when(mockInputConverter.stringToUnsignedInteger(any))
              .thenReturn(Right(tNumberParsed));

      test(
        "should call the inputconverter to validate and convert the string to an unisgned integer",
        () async* {
          //assert
          when(mockInputConverter.stringToUnsignedInteger(any))
              .thenReturn(Right(tNumberParsed));
          //act
          bloc.add(GetTriviaForConcreteNumber(tNumberString));
          await untilCalled(mockInputConverter.stringToUnsignedInteger(any));
          //arrange
          verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
        },
      );

      test(
        "should emit an [Error] when the input is invalid",
        () async* {
          //assert
          setUpMockInputConverterSucess();
          //act
          bloc.add(GetTriviaForConcreteNumber(tNumberString));
          //arrange
          final expected = [
            Empty(),
            Error(message: 'INVALID_INPUT_FAILURE_MESSAGE'),
          ];
          expectLater(bloc.state, emitsInOrder(expected));
        },
      );

      test(
        "should get the data for the concrete use case",
        () async* {
          // arrange
          setUpMockInputConverterSucess();
          when(mockGetConcreteNumberTrivia.call(any))
              .thenAnswer((_) async => Right(tNumberTrivia));
          //act
          bloc.add(GetTriviaForConcreteNumber(tNumberString));
          await untilCalled(mockGetConcreteNumberTrivia(any));
          //assert
          verify(mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));
        },
      );
      test(
        "should emit [loading, loaded] when data is gotten successfully",
        () async* {
          //arrange
          setUpMockInputConverterSucess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((realInvocation) async => Right(tNumberTrivia));
          //asseert Later
          final expect = [Empty(), Loading(), Loaded(trivia: tNumberTrivia)];
          expectLater(bloc, emitsInOrder(expect));
          //act
          bloc.add(GetTriviaForConcreteNumber(tNumberString));
        },
      );

      test(
        "should emit [loading, Error] when data is gotten successfully",
        () async* {
          //arrange
          setUpMockInputConverterSucess();
          when(mockGetConcreteNumberTrivia.call(any))
              .thenThrow(ServerFailure());
          //asseert Later
          final expect = [
            Empty(),
            Loading(),
            Error(message: SERVER_FAILURE_MESSAGE),
          ];
          expectLater(bloc.state, emitsInOrder(expect));
          //act
          bloc.add(GetTriviaForConcreteNumber(tNumberString));
        },
      );

      test(
        "should emit [loading, Error] when data is gotten successfully",
        () async* {
          //arrange
          setUpMockInputConverterSucess();
          when(mockGetConcreteNumberTrivia.call(any)).thenThrow(CacheFailure());
          //asseert Later
          final expect = [
            Empty(),
            Loading(),
            Error(message: CACHE_FAILURE_MESSAGE),
          ];
          expectLater(bloc.state, emitsInOrder(expect));
          //act
          bloc.add(GetTriviaForConcreteNumber(tNumberString));
        },
      );
    },
  );

  group('GetTriviaForRandomNumber', () {
    final tNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);

    test('should get data from the random usecase', () async* {
      //arrange
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));
      //act
      bloc.add(GetTriviaForRandomNumber());
      await untilCalled(mockGetRandomNumberTrivia(any));

      //assert
      verify(mockGetRandomNumberTrivia(NoParams()));
    });
    test('should emits [Loading, Loaded] when data is gotten successfully',
        () async* {
      //arrange
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));

      //assert later
      final expeted = [Empty(), Loading(), Loaded(trivia: tNumberTrivia)];
      expectLater(bloc, emitsInOrder(expeted));
      //act
      bloc.add(GetTriviaForRandomNumber());
    });
    test('should emits [Loading, Error] when getting data fails', () async* {
      //arrange
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Left(ServerFailure()));

      //assert later
      final expeted = [
        Empty(),
        Loading(),
        Error(message: SERVER_FAILURE_MESSAGE)
      ];
      expectLater(bloc, emitsInOrder(expeted));
      //act
      bloc.add(GetTriviaForRandomNumber());
    });

    test(
        'should emits [Loading, Error] with a proper message for the error when getting data fails',
        () async* {
      //arrange
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Left(CacheFailure()));

      //assert later
      final expeted = [
        Empty(),
        Loading(),
        Error(message: CACHE_FAILURE_MESSAGE)
      ];
      expectLater(bloc, emitsInOrder(expeted));
      //act
      bloc.add(GetTriviaForRandomNumber());
    });
  });
}
