import 'package:equatable/equatable.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();

  @override
  List<Object> get props => [];
}

class ConnectivityStartMonitoring extends ConnectivityEvent {}

class ConnectivityStatusChanged extends ConnectivityEvent {
  final ConnectivityResult connectivityResult;
  final bool hasInternetAccess;

  const ConnectivityStatusChanged({
    required this.connectivityResult,
    required this.hasInternetAccess,
  });

  @override
  List<Object> get props => [connectivityResult, hasInternetAccess];
}

class InternetStatusChanged extends ConnectivityEvent {
  final bool hasInternetAccess;

  const InternetStatusChanged({
    required this.hasInternetAccess,
  });

  @override
  List<Object> get props => [hasInternetAccess];
}