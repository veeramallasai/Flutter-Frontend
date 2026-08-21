import '../../core/network/api_client.dart';
import '../models/support_ticket_model.dart';

class SupportRepository {
  SupportRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Stream<List<SupportTicketModel>> watchMyTickets() async* {
    yield await getMyTickets();
  }

  Future<List<SupportTicketModel>> getMyTickets() async {
    final dynamic data = (await _apiClient.get('/api/v1/support-tickets')).data;
    final List<SupportTicketModel> values = _maps(data)
        .map(SupportTicketModel.fromMap)
        .toList(growable: true)
      ..sort((SupportTicketModel a, SupportTicketModel b) =>
          (b.updatedAt ?? b.createdAt ?? DateTime(1970))
              .compareTo(a.updatedAt ?? a.createdAt ?? DateTime(1970)));
    return List<SupportTicketModel>.unmodifiable(values);
  }

  Future<String> createTicket({
    required String subject,
    required String message,
    String category = 'general',
    String priority = 'normal',
  }) async {
    final dynamic data = (await _apiClient.post(
      '/api/v1/support-tickets',
      body: <String, dynamic>{
        'subject': subject.trim(),
        'message': message.trim(),
        'category': category.trim().toLowerCase(),
        'priority': priority.trim().toLowerCase(),
      },
    )).data;
    return data is Map ? (data['id']?.toString() ?? '') : '';
  }

  Future<void> closeTicket(String ticketId) async {
    final String id = ticketId.trim();
    if (id.isEmpty) return;
    await _apiClient.patch('/api/v1/support-tickets/$id/close');
  }
}

List<Map<String, dynamic>> _maps(dynamic data) => data is Iterable
    ? data.whereType<Map>().map((Map value) => Map<String, dynamic>.from(value)).toList()
    : <Map<String, dynamic>>[];
