abstract interface class ConnectionCheker {
  Future<bool> get isConnected;
}

class ConnectionCheckerImpl implements ConnectionCheker {
  @override
  Future<bool> get isConnected async => true;
}
