// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_checker/blocs/connectivity/connectivity_bloc.dart';
import 'package:connectivity_checker/blocs/connectivity/connectivity_state.dart';
import 'package:connectivity_checker/widgets/connection_status_card.dart';
import 'package:connectivity_checker/widgets/connection_details.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Network Connectivity',
          style: TextStyle(
            color: Colors.white70, // Set the font color to white70
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF214E34),
      ),
      body: BlocBuilder<ConnectivityBloc, ConnectivityState>(
        builder: (context, state) {
          if (state.isConnecting && state.connectionStatus == ConnectionStatus.initial) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'Checking connectivity...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return EnhancedConnectivityDisplay(state: state);
        },
      ),
    );
  }
}

class _LiveIndicator extends StatefulWidget {
  const _LiveIndicator();

  @override
  State<_LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<_LiveIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(_opacityAnimation.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

class EnhancedConnectivityDisplay extends StatelessWidget {
  final ConnectivityState state;

  const EnhancedConnectivityDisplay({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Main status card
            ConnectionStatusCard(state: state),
            const SizedBox(height: 30),

            // Internet status
            InternetStatusCard(hasInternet: state.hasInternetAccess),
            const SizedBox(height: 30),

            // Detailed information
            const Text(
              'Connection Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ConnectionDetails(state: state),

            // Show connecting indicator when we're checking but already have a previous state
            if (state.isConnecting)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text('Checking connection...'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}