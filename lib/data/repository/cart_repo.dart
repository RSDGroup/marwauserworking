import 'dart:convert';

import 'package:sixam_mart/data/model/response/cart_model.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartRepo{
  final SharedPreferences sharedPreferences;
  CartRepo({required this.sharedPreferences});

  List<CartModel> getCartList() {
    List<String>? carts = [];
    if(sharedPreferences.containsKey(AppConstants.cartList)) {
      carts = sharedPreferences.getStringList(AppConstants.cartList);
    }
    List<CartModel> cartList = [];
    for (var cart in carts!) {
      cartList.add(CartModel.fromJson(jsonDecode(cart)));
    }
    return cartList;
  }

  Future<void> addToCartList(List<CartModel> cartProductList) async {
    List<String> carts = [];
    for (var cartModel in cartProductList) {
      carts.add(jsonEncode(cartModel));
    }
    await sharedPreferences.setStringList(AppConstants.cartList, carts);
  }

}