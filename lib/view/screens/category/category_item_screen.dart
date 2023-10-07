import 'package:flutter/foundation.dart';
import 'package:sixam_mart/controller/category_controller.dart';
import 'package:sixam_mart/controller/localization_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/data/model/response/store_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/cart_widget.dart';
import 'package:sixam_mart/view/base/item_view.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/base/veg_filter_widget.dart';
import 'package:sixam_mart/view/base/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryItemScreen extends StatefulWidget {
  final String? categoryID;
  final String categoryName;
  const CategoryItemScreen(
      {Key? key, required this.categoryID, required this.categoryName})
      : super(key: key);

  @override
  CategoryItemScreenState createState() => CategoryItemScreenState();
}

class CategoryItemScreenState extends State<CategoryItemScreen>
    with TickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  final ScrollController storeScrollController = ScrollController();
  final bool _ltr = Get.find<LocalizationController>().isLtr;

  @override
  void initState() {
    super.initState();
    Get.find<CategoryController>().searchStoreList?.clear();
    Get.find<CategoryController>().getCategoryStoreList(
      Get.find<CategoryController>().subCategoryIndex == 0
          ? widget.categoryID
          : Get.find<CategoryController>()
              .subCategoryList![Get.find<CategoryController>().subCategoryIndex]
              .id
              .toString(),
      1,
      Get.find<CategoryController>().type,
      false,
    );
    Get.find<CategoryController>().getSubCategoryList(widget.categoryID);
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          Get.find<CategoryController>().categoryItemList != null &&
          !Get.find<CategoryController>().isLoading) {
        int pageSize = (Get.find<CategoryController>().pageSize! / 10).ceil();
        if (Get.find<CategoryController>().offset < pageSize) {
          if (kDebugMode) {
            print('end of the page');
          }
          Get.find<CategoryController>().showBottomLoader();
          Get.find<CategoryController>().getCategoryItemList(
            Get.find<CategoryController>().subCategoryIndex == 0
                ? widget.categoryID
                : Get.find<CategoryController>()
                    .subCategoryList![
                        Get.find<CategoryController>().subCategoryIndex]
                    .id
                    .toString(),
            Get.find<CategoryController>().offset + 1,
            Get.find<CategoryController>().type,
            false,
          );
        }
      }
    });
    storeScrollController.addListener(() {
      if (storeScrollController.position.pixels ==
              storeScrollController.position.maxScrollExtent &&
          Get.find<CategoryController>().categoryStoreList != null &&
          !Get.find<CategoryController>().isLoading) {
        int pageSize =
            (Get.find<CategoryController>().restPageSize! / 10).ceil();
        if (Get.find<CategoryController>().offset < pageSize) {
          if (kDebugMode) {
            print('end of the page');
          }
          Get.find<CategoryController>().showBottomLoader();
          Get.find<CategoryController>().getCategoryStoreList(
            Get.find<CategoryController>().subCategoryIndex == 0
                ? widget.categoryID
                : Get.find<CategoryController>()
                    .subCategoryList![
                        Get.find<CategoryController>().subCategoryIndex]
                    .id
                    .toString(),
            Get.find<CategoryController>().offset + 1,
            Get.find<CategoryController>().type,
            false,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(builder: (catController) {
      List<Item>? item;
      List<Store>? stores;
      if (catController.isSearching
          ? catController.searchItemList != null
          : catController.categoryItemList != null) {
        item = [];
        if (catController.isSearching) {
          item.addAll(catController.searchItemList!);
        } else {
          item.addAll(catController.categoryItemList!);
        }
      }
      if (catController.isSearching
          ? catController.searchStoreList != null
          : catController.categoryStoreList != null) {
        stores = [];
        if (catController.isSearching) {
          stores.addAll(catController.searchStoreList!);
        } else {
          stores.addAll(catController.categoryStoreList!);
        }
      }

      return WillPopScope(
        onWillPop: () async {
          if (catController.isSearching) {
            catController.toggleSearch();
            return false;
          } else {
            return true;
          }
        },
        child: Scaffold(
          appBar: (ResponsiveHelper.isDesktop(context)
              ? const WebMenuBar()
              : AppBar(
                  title: catController.isSearching
                      ? TextField(
                          autofocus: true,
                          textInputAction: TextInputAction.search,
                          decoration: const InputDecoration(
                            hintText: 'Search...',
                            border: InputBorder.none,
                          ),
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeLarge),
                          onSubmitted: (String query) {
                            catController.searchData(
                              query,
                              catController.subCategoryIndex == 0
                                  ? widget.categoryID
                                  : catController
                                      .subCategoryList![
                                          catController.subCategoryIndex]
                                      .id
                                      .toString(),
                              catController.type,
                            );
                    
                          })
                      : Text(widget.categoryName,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          )),
                  centerTitle: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                    onPressed: () {
                      if (catController.isSearching) {
                        catController.toggleSearch();
                      } else {
                        Get.back();
                      }
                    },
                  ),
                  backgroundColor: Theme.of(context).cardColor,
                  elevation: 0,
                  actions: [
                    IconButton(
                      onPressed: () => catController.toggleSearch(),
                      icon: Icon(
                        catController.isSearching
                            ? Icons.close_sharp
                            : Icons.search,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
                      icon: CartWidget(
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                          size: 25),
                    ),
                  ],
                )) as PreferredSizeWidget?,
          endDrawer: const MenuDrawer(),
          endDrawerEnableOpenDragGesture: false,
          body: Center(
              child: SizedBox(
            width: Dimensions.webMaxWidth,
            child: Column(children: [
              (catController.subCategoryList != null &&
                      !catController.isSearching)
                  ? Center(
                      child: Container(
                      height: 50,
                      width: Dimensions.webMaxWidth,
                      color: Theme.of(context).cardColor,
                      padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeExtraSmall),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: catController.subCategoryList!.length,
                        padding: const EdgeInsets.only(
                            left: Dimensions.paddingSizeSmall),
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () => catController.setSubCategoryIndex(
                                index, widget.categoryID),
                            child: Container(
                              padding: EdgeInsets.only(
                                left: index == 0
                                    ? Dimensions.paddingSizeLarge
                                    : Dimensions.paddingSizeSmall,
                                right: index ==
                                        catController.subCategoryList!.length -
                                            1
                                    ? Dimensions.paddingSizeLarge
                                    : Dimensions.paddingSizeSmall,
                                top: Dimensions.paddingSizeSmall,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(
                                    _ltr
                                        ? index == 0
                                            ? Dimensions.radiusExtraLarge
                                            : 0
                                        : index ==
                                                catController.subCategoryList!
                                                        .length -
                                                    1
                                            ? Dimensions.radiusExtraLarge
                                            : 0,
                                  ),
                                  right: Radius.circular(
                                    _ltr
                                        ? index ==
                                                catController.subCategoryList!
                                                        .length -
                                                    1
                                            ? Dimensions.radiusExtraLarge
                                            : 0
                                        : index == 0
                                            ? Dimensions.radiusExtraLarge
                                            : 0,
                                  ),
                                ),
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                              ),
                              child: Column(children: [
                                const SizedBox(height: 3),
                                Text(
                                  catController.subCategoryList![index].name!,
                                  style: index == catController.subCategoryIndex
                                      ? robotoMedium.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: Theme.of(context).primaryColor)
                                      : robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color:
                                              Theme.of(context).disabledColor),
                                ),
                                index == catController.subCategoryIndex
                                    ? Container(
                                        height: 5,
                                        width: 5,
                                        decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            shape: BoxShape.circle),
                                      )
                                    : const SizedBox(height: 5, width: 5),
                              ]),
                            ),
                          );
                        },
                      ),
                    ))
                  : const SizedBox(),

              // Center(child: Container(
              //   width: Dimensions.webMaxWidth,
              //   color: Theme.of(context).cardColor,
              //   child: TabBar(
              //     controller: _tabController,
              //     indicatorColor: Theme.of(context).primaryColor,
              //     indicatorWeight: 3,
              //     labelColor: Theme.of(context).primaryColor,
              //     unselectedLabelColor: Theme.of(context).disabledColor,
              //     unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
              //     labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
              //     tabs: [
              // //      Tab(text: 'item'.tr),
              //       Tab(text: Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
              //           ? 'restaurants'.tr : 'stores'.tr),
              //     ],
              //   ),
              // )),

              VegFilterWidget(
                  type: catController.type,
                  onSelected: (String type) {
                    if (catController.isSearching) {
                      catController.searchData(
                        catController.subCategoryIndex == 0
                            ? widget.categoryID
                            : catController
                                .subCategoryList![
                                    catController.subCategoryIndex]
                                .id
                                .toString(),
                        '1',
                        type,
                      );
                    } else {
                      if (catController.isStore) {
                        catController.getCategoryStoreList(
                          catController.subCategoryIndex == 0
                              ? widget.categoryID
                              : catController
                                  .subCategoryList![
                                      catController.subCategoryIndex]
                                  .id
                                  .toString(),
                          1,
                          type,
                          true,
                        );
                      } else {
                        catController.getCategoryItemList(
                          catController.subCategoryIndex == 0
                              ? widget.categoryID
                              : catController
                                  .subCategoryList![
                                      catController.subCategoryIndex]
                                  .id
                                  .toString(),
                          1,
                          type,
                          true,
                        );
                      }
                    }
                  }),

              Expanded(
                  child: NotificationListener(
                onNotification: (dynamic scrollNotification) {
                  if (scrollNotification is ScrollEndNotification) {
                    if ((!catController.isStore) || catController.isStore) {
                      catController.setRestaurant(true);
                      if (catController.isSearching) {
                        catController.searchData(
                          catController.searchText,
                          catController.subCategoryIndex == 0
                              ? widget.categoryID
                              : catController
                                  .subCategoryList![
                                      catController.subCategoryIndex]
                                  .id
                                  .toString(),
                          catController.type,
                        );
                      } else {
                        //  if(_tabController!.index == 1) {
                        catController.getCategoryStoreList(
                          catController.subCategoryIndex == 0
                              ? widget.categoryID
                              : catController
                                  .subCategoryList![
                                      catController.subCategoryIndex]
                                  .id
                                  .toString(),
                          1,
                          catController.type,
                          false,
                        );
                        //      }
                        // else {
                        //   catController.getCategoryItemList(
                        //     catController.subCategoryIndex == 0 ? widget.categoryID
                        //         : catController.subCategoryList![catController.subCategoryIndex].id.toString(),
                        //     1, catController.type, false,
                        //   );
                        // }
                      }
                    }
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  controller: storeScrollController,
                  child: ItemsView(
                    isStore: true,
                    items: null,
                    stores: stores,
                    noDataText: Get.find<SplashController>()
                            .configModel!
                            .moduleConfig!
                            .module!
                            .showRestaurantText!
                        ? 'no_category_restaurant_found'.tr
                        : 'no_category_store_found'.tr,
                  ),
                ),
              )),

              catController.isLoading
                  ? Center(
                      child: Padding(
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor)),
                    ))
                  : const SizedBox(),
            ]),
          )),
        ),
      );
    });
  }
}
