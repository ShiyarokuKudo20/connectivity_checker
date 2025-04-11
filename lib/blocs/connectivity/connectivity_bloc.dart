import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'connectivity_event.dart';
import 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _internetConnectionChecker = InternetConnectionChecker();

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  StreamSubscription<InternetConnectionStatus>? _internetSubscription;

  ConnectivityBloc() : super(ConnectivityState.initial()) {
    on<ConnectivityStartMonitoring>(_onStartMonitoring);
    on<ConnectivityStatusChanged>(_onStatusChanged);
    on<InternetStatusChanged>(_onInternetStatusChanged);

    add(ConnectivityStartMonitoring());
  }

  Future<void> _onStartMonitoring(
      ConnectivityStartMonitoring event,
      Emitter<ConnectivityState> emit,
      ) async {
    _connectivitySubscription?.cancel();
    _internetSubscription?.cancel();

    // Set initial state to connecting
    emit(ConnectivityState.initial());

    // Initial connectivity check
    final connectivityResult = await _connectivity.checkConnectivity();
    final status = _mapConnectivityResultToStatus(connectivityResult);

    // Update state with connection type but keep isConnecting true until internet check completes
    emit(state.copyWith(
      connectionStatus: status,
      isConnecting: true,
    ));

    // Start listening to connectivity changes immediately
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
          (ConnectivityResult result) {
        // For any connectivity change, immediately update UI with new connection type
        // and set isConnecting to true until we verify internet access
        add(ConnectivityStatusChanged(
          connectivityResult: result,
          hasInternetAccess: state.hasInternetAccess, // Keep current internet state until verified
        ));

        // Then check internet access
        _checkInternetAccess();
      },
    );

    // Start listening to internet status changes
    _internetSubscription = _internetConnectionChecker.onStatusChange.listen(
          (InternetConnectionStatus status) {
        add(InternetStatusChanged(
          hasInternetAccess: status == InternetConnectionStatus.connected,
        ));
      },
    );

    // Check internet access for initial state
    await _checkInternetAccess();
  }

  Future<void> _checkInternetAccess() async {
    // This will be called whenever we need to verify internet access
    final hasInternet = await _internetConnectionChecker.hasConnection;

    add(InternetStatusChanged(hasInternetAccess: hasInternet));
  }

  void _onStatusChanged(
      ConnectivityStatusChanged event,
      Emitter<ConnectivityState> emit,
      ) {
    // Update connection type immediately and set isConnecting true
    // This ensures the UI shows we're checking the new connection
    emit(state.copyWith(
      connectionStatus: _mapConnectivityResultToStatus(event.connectivityResult),
      isConnecting: true, // Set to true while we determine internet access
    ));
  }

  void _onInternetStatusChanged(
      InternetStatusChanged event,
      Emitter<ConnectivityState> emit,
      ) {
    // Complete the connection check by updating internet status
    // and setting isConnecting to false
    emit(state.copyWith(
      hasInternetAccess: event.hasInternetAccess,
      isConnecting: false, // Connection check complete
    ));
  }

  ConnectionStatus _mapConnectivityResultToStatus(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return ConnectionStatus.wifi;
      case ConnectivityResult.mobile:
        return ConnectionStatus.mobile;
      case ConnectivityResult.none:
      default:
        return ConnectionStatus.none;
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    _internetSubscription?.cancel();
    return super.close();
  }
}