import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_checker/blocs/connectivity/connectivity_state.dart';

// Constant for the loading duration to ensure consistency
const Duration kLoadingDuration = Duration(seconds: 2);

class ConnectionStatusCard extends StatefulWidget {
  final ConnectivityState state;
  final bool isLoading;

  const ConnectionStatusCard({
    Key? key,
    required this.state,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<ConnectionStatusCard> createState() => _ConnectionStatusCardState();
}

class _ConnectionStatusCardState extends State<ConnectionStatusCard> {
  bool _showSpinner = false;
  bool _showDelayedConnection = false;
  ConnectionStatus? _actualConnectionStatus;
  Timer? _connectionTimer;
  bool _initialLoading = true;
  bool _hasInternetAccess = false;

  @override
  void initState() {
    super.initState();
    _startInitialLoading();
  }

  void _startInitialLoading() {
    // Show loading state for the standardized duration
    Future.delayed(kLoadingDuration, () {
      if (mounted) {
        setState(() {
          _initialLoading = false;
        });
        _updateConnectionState();
      }
    });
  }

  @override
  void didUpdateWidget(covariant ConnectionStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_initialLoading && oldWidget.state != widget.state) {
      _updateConnectionState();
    }

    // Show loading again when isLoading is set to true
    if (oldWidget.isLoading != widget.isLoading && widget.isLoading) {
      setState(() {
        _initialLoading = true;
      });

      Future.delayed(kLoadingDuration, () {
        if (mounted) {
          setState(() {
            _initialLoading = false;
          });
          _updateConnectionState();
        }
      });
    }
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkInternetAccess() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 3));
      setState(() {
        _hasInternetAccess = response.statusCode == 200;
      });
    } catch (_) {
      setState(() {
        _hasInternetAccess = false;
      });
    }
  }

  void _updateConnectionState() async {
    if (_initialLoading) return;

    if (widget.state.isConnecting) {
      setState(() {
        _showSpinner = true;
        _showDelayedConnection = false;
      });
      return;
    }

    _connectionTimer?.cancel();

    if (widget.state.connectionStatus == ConnectionStatus.wifi ||
        widget.state.connectionStatus == ConnectionStatus.mobile) {
      _actualConnectionStatus = widget.state.connectionStatus;

      setState(() {
        _showSpinner = true;
        _showDelayedConnection = false;
      });

      await _checkInternetAccess();

      _connectionTimer = Timer(kLoadingDuration, () {
        if (mounted) {
          setState(() {
            _showSpinner = false;
            _showDelayedConnection = true;
          });
        }
      });
    } else {
      _actualConnectionStatus = widget.state.connectionStatus;
      setState(() {
        _showSpinner = false;
        _showDelayedConnection = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initialLoading || widget.isLoading) {
      return _buildLoadingCard();
    }

    IconData icon;
    String statusText;
    Color color;

    if (widget.state.isConnecting || (_actualConnectionStatus != null && !_showDelayedConnection)) {
      icon = Icons.hourglass_empty;
      statusText = 'Connecting...';
      color = Colors.amber;
    } else {
      switch (_actualConnectionStatus ?? widget.state.connectionStatus) {
        case ConnectionStatus.wifi:
          icon = Icons.wifi;
          statusText = _hasInternetAccess ? 'Connected to Wi-Fi' : 'Wi-Fi';
          color = _hasInternetAccess ? Colors.green : Colors.orange;
          break;
        case ConnectionStatus.mobile:
          icon = Icons.signal_cellular_alt;
          statusText = _hasInternetAccess ? 'Connected to Mobile Data' : 'Mobile Data';
          color = _hasInternetAccess ? Colors.blue : Colors.orange;
          break;
        case ConnectionStatus.none:
          icon = Icons.signal_cellular_off;
          statusText = 'No Connection';
          color = Colors.red;
          break;
        case ConnectionStatus.initial:
          icon = Icons.hourglass_empty;
          statusText = 'Checking Connection...';
          color = Colors.grey;
      }
    }

    return _buildConnectionCard(icon, statusText, color, _showSpinner);
  }

  Widget _buildLoadingCard() {
    return _buildStatusCard(
      content: Column(
        children: [
          const SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          // No Internet Access indicator during loading
          if (!_hasInternetAccess && !_initialLoading)
            const Column(
              children: [
                Icon(
                  Icons.error,
                  size: 40,
                  color: Colors.red,
                ),
                SizedBox(height: 8),
                Text(
                  'No Internet Access',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildConnectionCard(IconData icon, String statusText, Color color, bool showSpinner) {
    return _buildStatusCard(
      content: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                size: 80,
                color: showSpinner ? color.withOpacity(0.3) : color,
              ),
              if (showSpinner)
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    color: color,
                    strokeWidth: 4,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({required Widget content}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: content,
      ),
    );
  }
}

class InternetStatusCard extends StatefulWidget {
  final bool hasInternet;
  final bool isLoading;

  const InternetStatusCard({
    Key? key,
    required this.hasInternet,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<InternetStatusCard> createState() => _InternetStatusCardState();
}

class _InternetStatusCardState extends State<InternetStatusCard> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Show loading state for the standardized duration
    Future.delayed(kLoadingDuration, () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void didUpdateWidget(InternetStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Show loading again when isLoading is set to true
    if (oldWidget.isLoading != widget.isLoading && widget.isLoading) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(kLoadingDuration, () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: _isLoading || widget.isLoading
            ? const Column(
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Loading Internet Status...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16),
          ],
        )
            : Column(
          children: [
            Icon(
              widget.hasInternet ? Icons.check_circle : Icons.error,
              size: 60,
              color: widget.hasInternet ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              widget.hasInternet ? 'Internet Access Available' : 'No Internet Access',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.hasInternet ? Colors.green : Colors.red,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}