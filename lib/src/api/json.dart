List<Map<String, dynamic>> jsonItems(Object? value) =>
    (value as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

int jsonInt(Object? value) =>
    value is int ? value : int.tryParse('${value ?? ''}') ?? 0;

String nestedTitle(Object? value) =>
    (value as Map<String, dynamic>?)?['title'] as String? ?? '-';
