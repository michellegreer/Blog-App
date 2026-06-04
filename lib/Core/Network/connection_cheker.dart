import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract interface class ConnectionCheker {
  Future<bool> get isConnected;
}

// Used on mobile — pings external URLs to verify connectivity
class ConnectionCheckerImpl implements ConnectionCheker {
  InternetConnection internetConnection;
  ConnectionCheckerImpl({required this.internetConnection});
  @override
  Future<bool> get isConnected async =>
      await internetConnection.hasInternetAccess;
}

// Used on web — browser apps are always online; avoids CORS pings
class WebConnectionCheckerImpl implements ConnectionCheker {
  @override
  Future<bool> get isConnected async => true;
}
