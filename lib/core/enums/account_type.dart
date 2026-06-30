enum AccountType {
  customer,
  vendor,
  admin,
  unknown;

  static AccountType fromString(String? value) {
    switch (value) {
      case 'customer':
      case 'user':
        return AccountType.customer;
      case 'vendor':
        return AccountType.vendor;
      case 'admin':
        return AccountType.admin;
      default:
        return AccountType.unknown;
    }
  }

  String get value {
    switch (this) {
      case AccountType.customer:
        return 'customer';
      case AccountType.vendor:
        return 'vendor';
      case AccountType.admin:
        return 'admin';
      case AccountType.unknown:
        return 'unknown';
    }
  }
}