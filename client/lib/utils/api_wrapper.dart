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

    final T? parsedData;
    if (dataParser != null) {
      parsedData = dataParser(rawData);
    } else if (rawData is T) {
      parsedData = rawData;
    } else {
      parsedData = null; // or throw if you want strict behavior
    }

    return ApiResponse<T>(
      message: json['message'] as String? ?? '',
      success: json['success'] as bool? ?? false,
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
