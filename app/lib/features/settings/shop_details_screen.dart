import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/providers.dart';
import '../../shared/strings.dart';
import '../../shared/widgets.dart';

/// Shop name, GSTIN, address, state code, phone and the terms printed on bills.
/// Bills already saved keep the details they were made with.
class ShopDetailsScreen extends ConsumerStatefulWidget {
  const ShopDetailsScreen({super.key});

  @override
  ConsumerState<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends ConsumerState<ShopDetailsScreen> {
  late final TextEditingController _name;
  late final TextEditingController _gstin;
  late final TextEditingController _address;
  late final TextEditingController _state;
  late final TextEditingController _phone;
  late final TextEditingController _terms;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final shop = ref.read(sessionProvider).requireValue.shop;
    _name = TextEditingController(text: shop.name);
    _gstin = TextEditingController(text: shop.gstin ?? '');
    _address = TextEditingController(text: shop.address ?? '');
    _state = TextEditingController(text: shop.stateCode ?? '');
    _phone = TextEditingController(text: shop.phone ?? '');
    _terms = TextEditingController(text: shop.terms ?? '');
  }

  @override
  void dispose() {
    for (final c in [_name, _gstin, _address, _state, _phone, _terms]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await ref.read(setupRepositoryProvider).updateShop(
            name: _name.text,
            gstin: _gstin.text,
            address: _address.text,
            stateCode: _state.text,
            phone: _phone.text,
            terms: _terms.text,
            userId: ref.read(actingUserIdProvider),
          );
      // Everything that reads the shop (bills, PDF) must see the new details.
      ref.invalidate(sessionProvider);
      await ref.read(sessionProvider.future);
      if (!mounted) return;
      toast(context, S.shopSaved);
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        toastError(context, e);
      }
    }
  }

  Widget _field(Key key, TextEditingController c, String label,
          {int lines = 1, TextInputType? type, int? maxLength}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          key: key,
          controller: c,
          minLines: lines,
          maxLines: lines,
          maxLength: maxLength,
          keyboardType: type,
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), counterText: ''),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.shopDetails),
        actions: [
          TextButton(
            key: const Key('saveShop'),
            onPressed: _saving ? null : _save,
            child: Text(S.save),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field(const Key('shopName'), _name, S.shopName),
          _field(const Key('shopGstin'), _gstin, S.gstin, maxLength: 15),
          _field(const Key('shopAddress'), _address, S.shopAddress, lines: 2),
          _field(const Key('shopState'), _state, S.stateCode,
              type: TextInputType.number, maxLength: 2),
          _field(const Key('shopPhone'), _phone, S.phone, type: TextInputType.phone),
          _field(const Key('shopTerms'), _terms, S.shopTerms, lines: 3),
        ],
      ),
    );
  }
}
