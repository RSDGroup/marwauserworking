import 'package:sixam_mart/data/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class StoreRepo {
  final ApiClient apiClient;
  StoreRepo({required this.apiClient});

  Future<Response> getStoreList(int offset, String filterBy) async {
    return await apiClient.getData('${AppConstants.storeUri}/$filterBy?offset=$offset&limit=10');
  }

  Future<Response> getPopularStoreList(String type) async {
    return await apiClient.getData('${AppConstants.popularStoreUri}?type=$type');
  }

  Future<Response> getLatestStoreList(String type) async {
    return await apiClient.getData('${AppConstants.latestStoreUri}?type=$type');
  }

  Future<Response> getFeaturedStoreList() async {
    return await apiClient.getData('${AppConstants.storeUri}/all?featured=1&offset=1&limit=50');
  }

  Future<Response> getStoreDetails(String storeID) async {
    return await apiClient.getData('${AppConstants.storeDetailsUri}$storeID');
  }

  Future<Response> getStoreItemList(int? storeID, int offset, int? categoryID, String type) async {
    return await apiClient.getData(
      '${AppConstants.storeItemUri}?store_id=$storeID&category_id=$categoryID&offset=$offset&limit=10&type=$type',
    );
  }

  Future<Response> getStoreSearchItemList(String searchText, String? storeID, int offset, String type) async {
    return await apiClient.getData(
      '${AppConstants.searchUri}items/search?store_id=$storeID&name=$searchText&offset=$offset&limit=10&type=$type',
    );
  }

  Future<Response> getStoreReviewList(String? storeID) async {
    return await apiClient.getData('${AppConstants.storeReviewUri}?store_id=$storeID');
  }
  
  Future<Response> getStoreRecommendedItemList(int? storeId) async {
    return await apiClient.getData('${AppConstants.storeRecommendedItemUri}?store_id=$storeId&offset=1&limit=50');
  }

}