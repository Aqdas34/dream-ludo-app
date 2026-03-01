// ── app_remote_datasource.dart ───────────────────────────────────

import 'package:dream_ludo/core/constants/api_constants.dart';
import 'package:dream_ludo/core/constants/app_constants.dart';
import 'package:dream_ludo/core/network/dio_client.dart';
import 'package:dream_ludo/features/splash/data/models/app_model.dart';

abstract class AppRemoteDataSource {
  Future<AppModel> getAppDetails();
}

class AppRemoteDataSourceImpl implements AppRemoteDataSource {
  final DioClient _client;
  AppRemoteDataSourceImpl(this._client);

  @override
  Future<AppModel> getAppDetails() async {
    final response = await _client.get(
      ApiConstants.getAppDetails,
      queryParams: {'purchase_key': AppConstants.purchaseKey},
    );
    final data = AppResponse.fromJson(response.data);
    return data.result!.first;
  }
}
