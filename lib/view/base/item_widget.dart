import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/item_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/wishlist_controller.dart';
import 'package:sixam_mart/data/model/response/config_model.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/data/model/response/module_model.dart';
import 'package:sixam_mart/data/model/response/store_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/discount_tag.dart';
import 'package:sixam_mart/view/base/not_available_widget.dart';
import 'package:sixam_mart/view/base/rating_bar.dart';
import 'package:sixam_mart/view/screens/store/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ItemWidget extends StatelessWidget {
  final Item? item;
  final Store? store;
  final bool isStore;
  final int index;
  final int? length;
  final bool inStore;
  final bool isCampaign;
  final bool isFeatured;
  const ItemWidget(
      {Key? key,
      required this.item,
      required this.isStore,
      required this.store,
      required this.index,
      required this.length,
      this.inStore = false,
      this.isCampaign = false,
      this.isFeatured = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    BaseUrls? baseUrls = Get.find<SplashController>().configModel!.baseUrls;
    bool desktop = ResponsiveHelper.isDesktop(context);
    double? discount;
    String? discountType;
    bool isAvailable;
    if (isStore) {
      discount = store!.discount != null ? store!.discount!.discount : 0;
      discountType =
          store!.discount != null ? store!.discount!.discountType : 'percent';
      // bool _isClosedToday = Get.find<StoreController>().isRestaurantClosed(true, store.active, store.offDay);
      // _isAvailable = DateConverter.isAvailable(store.openingTime, store.closeingTime) && store.active && !_isClosedToday;
      isAvailable = store!.open == 1 && store!.active!;
    } else {
      discount = (item!.storeDiscount == 0 || isCampaign)
          ? item!.discount
          : item!.storeDiscount;
      discountType = (item!.storeDiscount == 0 || isCampaign)
          ? item!.discountType
          : 'percent';
      isAvailable = DateConverter.isAvailable(
          item!.availableTimeStarts, item!.availableTimeEnds);
    }

    return InkWell(
      onTap: () {
        if (isStore) {
          if (store != null) {
            if (isFeatured && Get.find<SplashController>().moduleList != null) {
              for (ModuleModel module
                  in Get.find<SplashController>().moduleList!) {
                if (module.id == store!.moduleId) {
                  Get.find<SplashController>().setModule(module);
                  break;
                }
              }
            }
            Get.toNamed(
              RouteHelper.getStoreRoute(
                  store!.id, isFeatured ? 'module' : 'item'),
              arguments: StoreScreen(store: store, fromModule: isFeatured),
            );
          }
        } else {
          if (isFeatured && Get.find<SplashController>().moduleList != null) {
            for (ModuleModel module
                in Get.find<SplashController>().moduleList!) {
              if (module.id == item!.moduleId) {
                Get.find<SplashController>().setModule(module);
                break;
              }
            }
          }
          Get.find<ItemController>().navigateToItemPage(item, context,
              inStore: inStore, isCampaign: isCampaign);
        }
      },
      child: Container(
        padding: ResponsiveHelper.isDesktop(context)
            ? const EdgeInsets.all(Dimensions.paddingSizeSmall)
            : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          color: ResponsiveHelper.isDesktop(context)
              ? Theme.of(context).cardColor
              : null,
          boxShadow: ResponsiveHelper.isDesktop(context)
              ? [
                  BoxShadow(
                    color: Colors.grey[Get.isDarkMode ? 700 : 300]!,
                    spreadRadius: 1,
                    blurRadius: 5,
                  )
                ]
              : null,
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
              child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: desktop ? 0 : Dimensions.paddingSizeExtraSmall),
            child: Row(children: [
              Stack(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: CustomImage(
                    image:
                        '${isCampaign ? baseUrls!.campaignImageUrl : isStore ? baseUrls!.storeImageUrl : baseUrls!.itemImageUrl}'
                        '/${isStore ? store != null ? store!.logo : '' : item!.image}',
                    height: desktop
                        ? 120
                        : length == null
                            ? 100
                            : 65,
                    width: desktop ? 120 : 80,
                    fit: BoxFit.cover,
                  ),
                ),
                DiscountTag(
                  discount: discount,
                  discountType: discountType,
                  freeDelivery: isStore ? store!.freeDelivery : false,
                ),
                isAvailable
                    ? const SizedBox()
                    : NotAvailableWidget(isStore: isStore),
              ]),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isStore ? store!.name! : item!.name!,
                        style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall),
                        maxLines: desktop ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                          height:
                              isStore ? Dimensions.paddingSizeExtraSmall : 0),
                      (isStore
                              ? store!.address != null
                              : item!.storeName != null)
                          ? Text(
                              isStore
                                  ? store!.address ?? ''
                                  : item!.storeName ?? '',
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: Theme.of(context).disabledColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : const SizedBox(),
                      SizedBox(
                          height: ((desktop || isStore) &&
                                  (isStore
                                      ? store!.address != null
                                      : item!.storeName != null))
                              ? 5
                              : 0),
                      !isStore
                          ? RatingBar(
                              rating:
                                  isStore ? store!.avgRating : item!.avgRating,
                              size: desktop ? 15 : 12,
                              ratingCount: isStore
                                  ? store!.ratingCount
                                  : item!.ratingCount,
                            )
                          : const SizedBox(),
                      SizedBox(
                          height: (!isStore && desktop)
                              ? Dimensions.paddingSizeExtraSmall
                              : 0),
                      isStore
                          ? RatingBar(
                              rating:
                                  isStore ? store!.avgRating : item!.avgRating,
                              size: desktop ? 15 : 12,
                              ratingCount: isStore
                                  ? store!.ratingCount
                                  : item!.ratingCount,
                            )
                          : Row(children: [
                              Text(
                                PriceConverter.convertPrice(item!.price,
                                    discount: discount,
                                    discountType: discountType),
                                style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall),
                                textDirection: TextDirection.ltr,
                              ),
                              SizedBox(
                                  width: discount! > 0
                                      ? Dimensions.paddingSizeExtraSmall
                                      : 0),
                              discount > 0
                                  ? Text(
                                      PriceConverter.convertPrice(item!.price),
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeExtraSmall,
                                        color: Theme.of(context).disabledColor,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                      textDirection: TextDirection.ltr,
                                    )
                                  : const SizedBox(),
                            ]),
                    ]),
              ),
              Column(
                  mainAxisAlignment: isStore
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.spaceBetween,
                  children: [
                    !isStore
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                                vertical:
                                    desktop ? Dimensions.paddingSizeSmall : 0),
                            child: Icon(Icons.add, size: desktop ? 30 : 25),
                          )
                        : const SizedBox(),
                    isStore
                        ? GetBuilder<WishListController>(
                            builder: (wishController) {
                            bool isWished = isStore
                                ? wishController.wishStoreIdList
                                    .contains(store!.id)
                                : wishController.wishItemIdList
                                    .contains(item!.id);
                            return InkWell(
                              onTap: !wishController.isRemoving
                                  ? () {
                                      if (Get.find<AuthController>()
                                          .isLoggedIn()) {
                                        isWished
                                            ? wishController.removeFromWishList(
                                                isStore ? store!.id : item!.id,
                                                isStore)
                                            : wishController.addToWishList(
                                                item, store, isStore);
                                      } else {
                                        showCustomSnackBar(
                                            'you_are_not_logged_in'.tr);
                                      }
                                    }
                                  : null,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: desktop
                                        ? Dimensions.paddingSizeSmall
                                        : 0),
                                child: Icon(
                                  isWished
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: desktop ? 30 : 25,
                                  color: isWished
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).disabledColor,
                                ),
                              ),
                            );
                          })
                        : SizedBox()
                  ]),
            ]),
          )),
          desktop || length == null
              ? const SizedBox()
              : Padding(
                  padding: EdgeInsets.only(left: desktop ? 130 : 90),
                  child: Divider(
                      color: index == length! - 1
                          ? Colors.transparent
                          : Theme.of(context).disabledColor),
                ),
        ]),
      ),
    );
  }
}
