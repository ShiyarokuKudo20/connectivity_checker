import 'package:equatable/equatable.dart';

enum ConnectionStatus {
  initial,
  wifi,
  mobile,
  none,
}

class ConnectivityState extends Equatable {
  final ConnectionStatus connectionStatus;
  final bool hasInternetAccess;
  final bool isConnecting;

  const ConnectivityState({
    required this.connectionStatus,
    required this.hasInternetAccess,
    required this.isConnecting,
  });

  factory ConnectivityState.initial() {
    return const ConnectivityState(
      connectionStatus: ConnectionStatus.initial,
      hasInternetAccess: false,
      isConnecting: true,
    );
  }

  ConnectivityState copyWith({
    ConnectionStatus? connectionStatus,
    bool? hasInternetAccess,
    bool? isConnecting,
  }) {
    return ConnectivityState(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      hasInternetAccess: hasInternetAccess ?? this.hasInternetAccess,
      isConnecting: isConnecting ?? this.isConnecting,
    );
  }

  @override
  List<Object> get props => [connectionStatus, hasInternetAccess, isConnecting];
}