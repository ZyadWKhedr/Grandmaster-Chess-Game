import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class NetworkService {
  Future<bool> hasInternetConnection();
}

class NetworkServiceImpl implements NetworkService {
  const NetworkServiceImpl();

  @override
  Future<bool> hasInternetConnection() async {
    if (kIsWeb) return true;

    try {
      final lookup = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
}

final networkServiceProvider = Provider<NetworkService>((ref) {
  return const NetworkServiceImpl();
});

