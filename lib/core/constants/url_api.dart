class UrlApi {

  static const String baseDomain = 'https://ordoraa.com/usacars';
  static const String baseUrl = '$baseDomain/api';

  static String assetUrl(String? path) {
    if (path == null || path.isEmpty) return '';

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    if (path.startsWith('/')) {
      return '$baseDomain$path';
    }

    return '$baseDomain/$path';
  }
  // Auth
  static const String registerCustomer = '$baseUrl/auth/register/customer';
  static const String registerVendor = '$baseUrl/auth/register/vendor';
  static const String login = '$baseUrl/auth/login';
  static const String logout = '$baseUrl/auth/logout';
  static const String me = '$baseUrl/auth/me';
  static const String refresh = '$baseUrl/auth/refresh';

  // Profile
  static const String profile = '$baseUrl/profile';
  static const String updateProfile = '$baseUrl/profile/update';
  static const String changePassword = '$baseUrl/profile/change-password';

  // Vehicle Catalog
  static const String vehicleMakes = '$baseUrl/vehicle-catalog/makes';
  static const String vehicleModels = '$baseUrl/vehicle-catalog/models';

  static String modelsByMake(int makeId) {
    return '$baseUrl/vehicle-catalog/makes/$makeId/models';
  }

  // Vehicles
  static const String vehicles = '$baseUrl/vehicles';

  static String vehicleDetails(int vehicleId) {
    return '$baseUrl/vehicles/$vehicleId';
  }

  static String setPrimaryVehicle(int vehicleId) {
    return '$baseUrl/vehicles/$vehicleId/primary';
  }

  // Addresses
  static const String addresses = '$baseUrl/addresses';

  static String addressDetails(int addressId) {
    return '$baseUrl/addresses/$addressId';
  }

  static String setDefaultAddress(int addressId) {
    return '$baseUrl/addresses/$addressId/default';
  }

  // Services
  static const String serviceCategories = '$baseUrl/service-catalog/categories';
  static const String services = '$baseUrl/service-catalog/services';

  static String serviceDetails(int serviceId) {
    return '$baseUrl/service-catalog/services/$serviceId';
  }

  // Repair
  static const String repairRequests = '$baseUrl/repair-requests';

  static String repairRequestDetails(int requestId) {
    return '$baseUrl/repair-requests/$requestId';
  }

  static String cancelRepairRequest(int requestId) {
    return '$baseUrl/repair-requests/$requestId/cancel';
  }

  // Roadside
  static const String roadsideRequests = '$baseUrl/roadside-requests';
  static const String roadsideServiceTypes =
      '$baseUrl/roadside-requests/service-types';

  static String roadsideRequestDetails(int requestId) {
    return '$baseUrl/roadside-requests/$requestId';
  }

  static String cancelRoadsideRequest(int requestId) {
    return '$baseUrl/roadside-requests/$requestId/cancel';
  }

  static String latestRoadsideLocation(int requestId) {
    return '$baseUrl/roadside-requests/$requestId/location/latest';
  }

  static String roadsideLocationHistory(int requestId) {
    return '$baseUrl/roadside-requests/$requestId/location/history';
  }

  // Customer Home
  static const String customerHome = '$baseUrl/customer/home';









  // Marketplace
  static const String marketplaceCategories = '$baseUrl/marketplace/categories';
  static const String marketplaceProducts = '$baseUrl/marketplace/products';

  static String marketplaceProductDetails(int productId) {
    return '$baseUrl/marketplace/products/$productId';
  }

  // Marketplace Advanced Filters
  static const String marketplaceFilterOptions =
      '$baseUrl/marketplace/filter-options';

  static const String marketplaceProductsFilter =
      '$baseUrl/marketplace/products/filter';

  static const String marketplaceBrands =
      '$baseUrl/marketplace/brands';

  static String marketplaceBrandProducts(String brand) {
    return '$baseUrl/marketplace/brands/$brand/products';
  }

// Cart
  static const String cart = '$baseUrl/cart';
  static const String cartItems = '$baseUrl/cart/items';

  static String cartItemDetails(int itemId) {
    return '$baseUrl/cart/items/$itemId';
  }

// Orders
  static const String checkout = '$baseUrl/orders/checkout';
  static const String orders = '$baseUrl/orders';

  static String orderDetails(int orderId) {
    return '$baseUrl/orders/$orderId';
  }

  static String cancelOrder(int orderId) {
    return '$baseUrl/orders/$orderId/cancel';
  }

// Payments
  static const String pay = '$baseUrl/payments/pay';

  static String markPaymentPaid(int paymentId) {
    return '$baseUrl/payments/$paymentId/mark-paid';
  }





// Roadside
  static const String roadsideHome = '$baseUrl/roadside/home';
  static const String roadsideServices = '$baseUrl/roadside/services';
  // static const String roadsideRequests = '$baseUrl/roadside/requests';

  /*static String roadsideRequestDetails(int requestId) {
    return '$baseUrl/roadside/requests/$requestId';
  }*/

  static const String roadsideVendors = '$baseUrl/roadside/vendors';



// Repair
  static const String repairHome = '$baseUrl/repair/home';
  static const String repairWorkshops = '$baseUrl/repair/workshops';

  /*static const String repairRequests = '$baseUrl/repair-requests';

  static String repairRequestDetails(int requestId) {
    return '$baseUrl/repair-requests/$requestId';
  }

  static String cancelRepairRequest(int requestId) {
    return '$baseUrl/repair-requests/$requestId/cancel';
  }*/
}