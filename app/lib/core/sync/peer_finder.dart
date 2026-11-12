import 'dart:async';
import 'dart:convert';

import 'package:nsd/nsd.dart' as nsd;

/// Another shop phone seen on the Wi-Fi.
class FoundPeer {
  const FoundPeer({required this.deviceId, required this.host, required this.port});
  final String deviceId;
  final String host;
  final int port;
}

/// Finds the other phone on the shop Wi-Fi. Optional: the last known address
/// (from pairing or the last sync) also works.
abstract class PeerFinder {
  Future<void> start({required String myDeviceId, required int port});
  Stream<FoundPeer> get found;
  Future<void> stop();
}

/// Android's own network service discovery (mDNS), which also takes the
/// Wi-Fi multicast lock it needs.
class NsdPeerFinder implements PeerFinder {
  static const serviceType = '_peshop._tcp';

  nsd.Registration? _registration;
  nsd.Discovery? _discovery;
  final _found = StreamController<FoundPeer>.broadcast();

  @override
  Stream<FoundPeer> get found => _found.stream;

  @override
  Future<void> start({required String myDeviceId, required int port}) async {
    _registration = await nsd.register(nsd.Service(
      name: 'shop-${myDeviceId.substring(0, 8)}',
      type: serviceType,
      port: port,
      txt: {'id': utf8.encode(myDeviceId)},
    ));
    _discovery = await nsd.startDiscovery(serviceType, ipLookupType: nsd.IpLookupType.v4);
    _discovery!.addServiceListener((service, status) {
      if (status != nsd.ServiceStatus.found) return;
      final idBytes = service.txt?['id'];
      final host = service.addresses?.isNotEmpty == true ? service.addresses!.first.address : service.host;
      if (idBytes == null || host == null || service.port == null) return;
      final id = utf8.decode(idBytes);
      if (id == myDeviceId) return;
      _found.add(FoundPeer(deviceId: id, host: host, port: service.port!));
    });
  }

  @override
  Future<void> stop() async {
    if (_discovery != null) await nsd.stopDiscovery(_discovery!);
    if (_registration != null) await nsd.unregister(_registration!);
    _discovery = null;
    _registration = null;
  }
}
