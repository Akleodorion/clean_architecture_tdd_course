import 'package:dartz/dartz.dart';

import '../error/failures.dart';

abstract class InputConverter {
  Either<Failure, int>? stringToUnsignedInteger(String str);
}

class InputConverterImpl extends InputConverter {
  @override
  Either<Failure, int>? stringToUnsignedInteger(String str) {
    final number = int.tryParse(str);
    if (number == null || number < 0) {
      return Left(InvalidInputFailure());
    } else {
      return Right(number);
    }
  }
}

class InvalidInputFailure extends Failure {}
