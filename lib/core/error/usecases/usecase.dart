import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../failures.dart';

// Création d'une classe abstraite générique pour permettre de forcer l'utilisation d'une méthode call à nos UseCase.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object?> get props => throw UnimplementedError();
}
