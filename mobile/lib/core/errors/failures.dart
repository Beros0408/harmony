import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([this.message = '']);
  final String message;

  @override
  List<Object> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Erreur réseau']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Erreur serveur']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erreur de cache']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Erreur d\'authentification']);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Erreur inattendue']);
}
