class ApiResponse<T> {
  final String message;
  final T? data;
  final dynamic error; // can be anything
  final bool success;

  ApiResponse({
    required this.message,
    required this.success,
    this.data,
    this.error,
  });
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? jsonData)? dataParser,
  ) {
    final rawData = json['data'];

    T? parsedData;

    if (rawData is List && dataParser != null) {
      // cast list properly
      parsedData = rawData.map((item) => dataParser(item)).toList() as T;
    } else if (dataParser != null) {
      parsedData = dataParser(rawData);
    } else if (rawData is T) {
      parsedData = rawData;
    }

    return ApiResponse<T>(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      data: parsedData,
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson({Object? Function(T value)? dataEncoder}) {
    final encodedData = data == null
        ? null
        : (dataEncoder != null ? dataEncoder(data as T) : data);

    return {
      'message': message,
      'success': success,
      'data': encodedData,
      'error': error,
    };
  }
}
