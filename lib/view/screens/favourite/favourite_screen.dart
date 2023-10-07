import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/wishlist_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/base/not_logged_in_screen.dart';
import 'package:sixam_mart/view/screens/favourite/widget/fav_item_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({Key? key}) : super(key: key);

  @override
  FavouriteScreenState createState() => FavouriteScreenState();
}

class FavouriteScreenState extends State<FavouriteScreen> with SingleTickerProviderStateMixin {
  
  @override
  void initState() {
    super.initState();

  
    Get.find<WishListController>().getWishList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'favourite'.tr, backButton: false),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: Get.find<AuthController>().isLoggedIn() ? SafeArea(child: Column(children: [


        Expanded(child:  FavItemView(isStore: true),),

      ])) : const NotLoggedInScreen(),
    );
  }
}
