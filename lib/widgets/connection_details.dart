import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_checker/blocs/connectivity/connectivity_state.dart';

class ConnectionDetails extends StatefulWidget {
  final ConnectivityState state;
  final bool isLoading;

  const ConnectionDetails({
    Key? key,
    required this.state,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<ConnectionDetails> createState() => _ConnectionDetailsState();
}

class _ConnectionDetailsState extends State<ConnectionDetails> {
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  @override
  void didUpdateWidget(ConnectionDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading != widget.isLoading && widget.isLoading) {
      _startLoading();
    }
  }

  void _startLoading() {
    setState(() => _initialLoading = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _initialLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _initialLoading || widget.isLoading
        ? _buildLoadingDetails()
        : _buildDetails();
  }

  Widget _buildDetails() {
    return _buildContainer(
      Column(
        children: [
          _buildDetailItem(
            'Connection Type',
            _getConnectionTypeString(widget.state.connectionStatus, widget.state.isConnecting),
            _getConnectionIcon(widget.state.connectionStatus),
            _getConnectionColor(widget.state.connectionStatus, widget.state.isConnecting),
            widget.state.isConnecting,
          ),
          const Divider(),
          _buildDetailItem(
            'Internet Access',
            widget.state.isConnecting
                ? 'Checking...'
                : (widget.state.hasInternetAccess ? 'Available' : 'Not Available'),
            widget.state.isConnecting
                ? Icons.hourglass_empty
                : (widget.state.hasInternetAccess ? Icons.check_circle : Icons.cancel),
            widget.state.isConnecting
                ? Colors.amber
                : (widget.state.hasInternetAccess ? Colors.green : Colors.red),
            widget.state.isConnecting,
          ),
          const Divider(),
          _buildDetailItem(
            'Status',
            _getStatusString(widget.state),
            _getStatusIcon(widget.state),
            _getStatusColor(widget.state),
            widget.state.isConnecting,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingDetails() {
    return _buildContainer(
      Column(
        children: [
          _buildLoadingItem('Connection Type'),
          const Divider(),
          _buildLoadingItem('Internet Access'),
          const Divider(),
          _buildLoadingItem('Status'),
        ],
      ),
    );
  }

  Widget _buildContainer(Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDetailItem(String title, String value, IconData icon, Color iconColor, bool showSpinner) {
    return DetailItem(
      title: title,
      value: value,
      icon: icon,
      iconColor: iconColor,
      showSpinner: showSpinner,
    );
  }

  Widget _buildLoadingItem(String title) {
    return Row(
      children: [
        const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const Text('Loading...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  String _getConnectionTypeString(ConnectionStatus status, bool isConnecting) {
    if (isConnecting) {
      return status == ConnectionStatus.wifi
          ? 'Checking Wi-Fi...'
          : status == ConnectionStatus.mobile
          ? 'Checking Mobile Data...'
          : 'Checking Connection...';
    }
    return status == ConnectionStatus.wifi
        ? 'Wi-Fi'
        : status == ConnectionStatus.mobile
        ? 'Mobile Data'
        : 'No Connection';
  }

  IconData _getConnectionIcon(ConnectionStatus status) {
    return status == ConnectionStatus.wifi
        ? Icons.wifi
        : status == ConnectionStatus.mobile
        ? Icons.signal_cellular_alt
        : Icons.signal_cellular_off;
  }

  Color _getConnectionColor(ConnectionStatus status, bool isConnecting) {
    if (isConnecting) return Colors.amber;
    return status == ConnectionStatus.wifi
        ? Colors.green
        : status == ConnectionStatus.mobile
        ? Colors.blue
        : Colors.red;
  }

  String _getStatusString(ConnectivityState state) {
    if (state.isConnecting) return 'Checking connectivity...';
    if (state.connectionStatus == ConnectionStatus.none) return 'Disconnected';
    return state.hasInternetAccess ? 'Online' : 'No internet connection';
  }

  IconData _getStatusIcon(ConnectivityState state) {
    if (state.isConnecting) return Icons.hourglass_empty;
    if (state.connectionStatus == ConnectionStatus.none) return Icons.cloud_off;
    return state.hasInternetAccess ? Icons.cloud_done : Icons.cloud_queue;
  }

  Color _getStatusColor(ConnectivityState state) {
    if (state.isConnecting) return Colors.amber;
    if (state.connectionStatus == ConnectionStatus.none) return Colors.red;
    return state.hasInternetAccess ? Colors.green : Colors.orange;
  }
}

class DetailItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final bool showSpinner;

  const DetailItem({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.showSpinner = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: showSpinner ? iconColor.withOpacity(0.3) : iconColor, size: 28),
            if (showSpinner)
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis, maxLines: 1),
            ],
          ),
        ),
      ],
    );
  }
}