import '../../core/network/api_client.dart';
import '../models/offer_model.dart';

class OfferRepository {
  OfferRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  List<OfferModel> get localOffers => const <OfferModel>[
    OfferModel(
      id: 'fresh10',
      title: 'Fresh 10% Off',
      description: 'Save on your first farm-fresh basket',
      code: 'FRESH10',
      discountValue: 10,
      minimumOrder: 299,
      maximumDiscount: 100,
    ),
    OfferModel(
      id: 'farm50',
      title: '₹50 Farm Savings',
      description: 'Flat savings on orders above ₹499',
      code: 'FARM50',
      discountType: 'fixed',
      discountValue: 50,
      minimumOrder: 499,
    ),
  ];

  Stream<List<OfferModel>> watchOffers() async* {
    yield localOffers;
    final List<OfferModel> values = await getOffers();
    if (!_sameIds(values, localOffers)) yield values;
  }

  Future<List<OfferModel>> getOffers() async {
    try {
      final dynamic data = (await _apiClient.get('/api/v1/offers')).data;
      final List<OfferModel> values = _maps(data)
          .map(OfferModel.fromMap)
          .where((OfferModel offer) => offer.isAvailable)
          .toList(growable: false);
      return values.isEmpty
          ? localOffers
          : List<OfferModel>.unmodifiable(values);
    } catch (_) {
      return localOffers;
    }
  }
}

List<Map<String, dynamic>> _maps(dynamic data) =>
    data is Iterable
        ? data
            .whereType<Map>()
            .map((Map value) => Map<String, dynamic>.from(value))
            .toList()
        : <Map<String, dynamic>>[];

bool _sameIds(List<OfferModel> a, List<OfferModel> b) =>
    a.length == b.length &&
    a.map((OfferModel item) => item.id).join('|') ==
        b.map((OfferModel item) => item.id).join('|');
