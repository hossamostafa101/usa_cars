class ApiResponseModel<T> {
  final bool status;
  final String message;
  final T? data;
  final dynamic errors;

  const ApiResponseModel({
    required this.status,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponseModel.fromJson(
      Map<String, dynamic> json, {
        T Function(dynamic data)? parser,
      }) {
    return ApiResponseModel<T>(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: parser != null ? parser(json['data']) : json['data'] as T?,
      errors: json['errors'],
    );
  }
}