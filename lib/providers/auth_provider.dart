import 'package:flutter/material.dart';
import 'package:talabatfresh/core/constants/cache_keys.dart';
import 'package:talabatfresh/core/enums/account_type.dart';
import 'package:talabatfresh/core/enums/auth_status.dart';
import 'package:talabatfresh/data/local/cache_helper.dart';
import 'package:talabatfresh/data/remote/services/auth_api_service.dart';
import 'package:talabatfresh/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthApiService _authApiService = AuthApiService();

  AuthStatus authStatus = AuthStatus.initial;
  UserModel? currentUser;
  String? errorMessage;

  bool get isLoading => authStatus == AuthStatus.loading;
  bool get isAuthenticated => authStatus == AuthStatus.authenticated;
  bool get isVendorPending => authStatus == AuthStatus.vendorPending;

  AccountType get accountType => currentUser?.accountType ?? AccountType.unknown;

  Future<void> initAuth() async {
    final token = CacheHelper.getData(key:CacheKeys.token);

    if (token == null || token.toString().isEmpty) {
      authStatus = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      authStatus = AuthStatus.loading;
      notifyListeners();

      final user = await _authApiService.me();

      if (user == null) {
        await clearSession();
        return;
      }

      currentUser = user;
      await _cacheUser(user);

      _setStatusByUser(user);
      notifyListeners();
    } catch (e) {
      await clearSession();
    }
  }

  Future<bool> login({
    required String login,
    required String password,
    AccountType expectedType = AccountType.customer,
  }) async {
    try {
      authStatus = AuthStatus.loading;
      errorMessage = null;
      notifyListeners();

      final response = await _authApiService.login(
        login: login,
        password: password,
      );

      if (!response.status || response.user == null || response.token == null) {
        authStatus = AuthStatus.error;
        errorMessage = response.message;
        notifyListeners();
        return false;
      }

      final user = response.user!;

      if (expectedType != AccountType.unknown && user.accountType != expectedType) {
        authStatus = AuthStatus.error;
        errorMessage = expectedType == AccountType.vendor
            ? 'هذا الحساب ليس حساب ورشة.'
            : 'هذا الحساب ليس حساب مستخدم.';
        notifyListeners();
        return false;
      }

      await CacheHelper.saveData(
        key: CacheKeys.token,
        value: response.token,
      );

      currentUser = user;
      await _cacheUser(user);

      _setStatusByUser(user);
      notifyListeners();

      return authStatus == AuthStatus.authenticated ||
          authStatus == AuthStatus.vendorPending;
    } catch (e) {
      authStatus = AuthStatus.error;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerCustomer({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      authStatus = AuthStatus.loading;
      errorMessage = null;
      notifyListeners();

      final response = await _authApiService.registerCustomer(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (!response.status || response.user == null || response.token == null) {
        authStatus = AuthStatus.error;
        errorMessage = response.message;
        notifyListeners();
        return false;
      }

      await CacheHelper.saveData(
        key: CacheKeys.token,
        value: response.token,
      );

      currentUser = response.user!;
      await _cacheUser(currentUser!);

      _setStatusByUser(currentUser!);
      notifyListeners();

      return true;
    } catch (e) {
      authStatus = AuthStatus.error;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerVendor({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String businessName,
    String? businessType,
    String? description,
    String? supportEmail,
    String? supportPhone,
  }) async {
    try {
      authStatus = AuthStatus.loading;
      errorMessage = null;
      notifyListeners();

      final response = await _authApiService.registerVendor(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
        businessName: businessName,
        businessType: businessType,
        description: description,
        supportEmail: supportEmail,
        supportPhone: supportPhone,
      );

      if (!response.status || response.user == null || response.token == null) {
        authStatus = AuthStatus.error;
        errorMessage = response.message;
        notifyListeners();
        return false;
      }

      await CacheHelper.saveData(
        key: CacheKeys.token,
        value: response.token,
      );

      currentUser = response.user!;
      await _cacheUser(currentUser!);

      _setStatusByUser(currentUser!);
      notifyListeners();

      return true;
    } catch (e) {
      authStatus = AuthStatus.error;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authApiService.logout();
    } catch (_) {}

    await clearSession();
  }

  Future<void> clearSession() async {
    await CacheHelper.removeData(key: CacheKeys.token);
    await CacheHelper.removeData(key: CacheKeys.userId);
    await CacheHelper.removeData(key: CacheKeys.userName);
    await CacheHelper.removeData(key: CacheKeys.userEmail);
    await CacheHelper.removeData(key: CacheKeys.userType);
    await CacheHelper.removeData(key: CacheKeys.userStatus);

    currentUser = null;
    authStatus = AuthStatus.unauthenticated;
    errorMessage = null;

    notifyListeners();
  }

  void _setStatusByUser(UserModel user) {
    if (user.isVendor) {
      final vendorStatus = user.vendorProfile?.verificationStatus;

      if (vendorStatus == 'pending' || user.status == 'pending_verification') {
        authStatus = AuthStatus.vendorPending;
        return;
      }

      if (vendorStatus == 'rejected') {
        authStatus = AuthStatus.vendorRejected;
        return;
      }
    }

    if (user.status == 'active') {
      authStatus = AuthStatus.authenticated;
    } else {
      authStatus = AuthStatus.error;
      errorMessage = 'الحساب غير نشط.';
    }
  }

  Future<void> _cacheUser(UserModel user) async {
    await CacheHelper.saveData(key: CacheKeys.userId, value: user.id);
    await CacheHelper.saveData(key: CacheKeys.userName, value: user.name);
    await CacheHelper.saveData(key: CacheKeys.userEmail, value: user.email);
    await CacheHelper.saveData(key: CacheKeys.userType, value: user.accountType.value);
    await CacheHelper.saveData(key: CacheKeys.userStatus, value: user.status);
  }
}