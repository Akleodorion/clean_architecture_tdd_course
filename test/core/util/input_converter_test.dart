import 'package:clean_architecture_tdd_course/core/util/input_converter.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InputConverterImpl inputConverter;

  setUp(() {
    inputConverter = InputConverterImpl();
  });

  group('stringToUnsignedInteger', () {
    test(
      "should return an Integer when the string represent an unsigned Integer",
      () async {
        //assert
        final str = '1';
        //act
        final result = inputConverter.stringToUnsignedInteger(str);
        //arrange
        expect(result, Right(1));
      },
    );

    test(
      "should return an InvalidInputFailure if the string does not represent an usigned Integer",
      () async {
        //assert
        final str = '1xc';
        //act
        final result = inputConverter.stringToUnsignedInteger(str);
        //arrange
        expect(result, Left(InvalidInputFailure()));
      },
    );

    test(
      "should return a failure if the number is negative",
      () async {
        //assert
        final str = '-1';
        //act
        final result = inputConverter.stringToUnsignedInteger(str);
        //arrange
        expect(result, Left(InvalidInputFailure()));
      },
    );
  });
}
