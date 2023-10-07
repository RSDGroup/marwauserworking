import 'package:flutter/rendering.dart';
import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/controller/category_controller.dart';
import 'package:sixam_mart/controller/localization_controller.dart';
import 'package:sixam_mart/controller/store_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/category_model.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/data/model/response/store_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/base/item_view.dart';
import 'package:sixam_mart/view/base/item_widget.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/base/paginated_list_view.dart';
import 'package:sixam_mart/view/base/web_menu_bar.dart';
import 'package:sixam_mart/view/screens/checkout/checkout_screen.dart';
import 'package:sixam_mart/view/screens/store/widget/store_description_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'widget/bottom_cart_widget.dart';

class StoreScreen extends StatefulWidget {
  final Store? store;
  final bool fromModule;
  const StoreScreen({Key? key, required this.store, required this.fromModule}) : super(key: key);

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final ScrollController scrollController = ScrollController();
  final bool _ltr = Get.find<LocalizationController>().isLtr;

  @override
  void initState() {
    super.initState();

    Get.find<StoreController>().hideAnimation();
    Get.find<StoreController>().getStoreDetails(Store(id: widget.store!.id), widget.fromModule).then((value) {
      Get.find<StoreController>().showButtonAnimation();
    });
    if(Get.find<CategoryController>().categoryList == null) {
      Get.find<CategoryController>().getCategoryList(true);
    }
    Get.find<StoreController>().getRestaurantRecommendedItemList(widget.store!.id, false);
    Get.find<StoreController>().getStoreItemList(widget.store!.id, 1, 'all', false);

    scrollController.addListener(() {
      if(scrollController.position.userScrollDirection == ScrollDirection.reverse){
        if(Get.find<StoreController>().showFavButton){
          Get.find<StoreController>().changeFavVisibility();
          Get.find<StoreController>().hideAnimation();
        }
      }else{
        if(!Get.find<StoreController>().showFavButton){
          Get.find<StoreController>().changeFavVisibility();
          Get.find<StoreController>().showButtonAnimation();
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      backgroundColor: Theme.of(context).cardColor,
      body: GetBuilder<StoreController>(builder: (storeController) {
        return GetBuilder<CategoryController>(builder: (categoryController) {
          Store? store;
          if(storeController.store != null && storeController.store!.name != null && categoryController.categoryList != null) {
            store = storeController.store;
          }
          storeController.setCategoryList();

          return (storeController.store != null && storeController.store!.name != null && categoryController.categoryList != null) ? CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: scrollController,
            slivers: [

              ResponsiveHelper.isDesktop(context) ? SliverToBoxAdapter(
                child: Container(
                  color: const Color(0xFF171A29),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  alignment: Alignment.center,
                  child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    child: Row(children: [

                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: CustomImage(
                            fit: BoxFit.cover, height: 220,
                            image: '${Get.find<SplashController>().configModel!.baseUrls!.storeCoverPhotoUrl}/${store!.coverPhoto}',
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeLarge),

                      Expanded(child: StoreDescriptionView(store: store)),

                    ]),
                  ))),
                ),
              ) : SliverAppBar(
                expandedHeight: 230, toolbarHeight: 50,
                pinned: true, floating: false,
                backgroundColor: Theme.of(context).primaryColor,
                leading: IconButton(
                  icon: Container(
                    height: 50, width: 50,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                    alignment: Alignment.center,
                    child: Icon(Icons.chevron_left, color: Theme.of(context).cardColor),
                  ),
                  onPressed: () => Get.back(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: CustomImage(
                    fit: BoxFit.cover,
                    image: '${Get.find<SplashController>().configModel!.baseUrls!.storeCoverPhotoUrl}/${store!.coverPhoto}',
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () => Get.toNamed(RouteHelper.getSearchStoreItemRoute(store!.id)),
                    icon: Container(
                      height: 50, width: 50,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                      alignment: Alignment.center,
                      child: Icon(Icons.search, size: 20, color: Theme.of(context).cardColor),
                    ),
                  ),
                ],
              ),

              SliverToBoxAdapter(child: Center(child: Container(
                width: Dimensions.webMaxWidth,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                color: Theme.of(context).cardColor,
                child: Column(children: [
                  ResponsiveHelper.isDesktop(context) ? const SizedBox() : StoreDescriptionView(store: store),
                  store.discount != null ? Container(
                    width: context.width,
                    margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Theme.of(context).primaryColor),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(
                        store.discount!.discountType == 'percent' ? '${store.discount!.discount}% OFF'
                            : '${PriceConverter.convertPrice(store.discount!.discount)} OFF',
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).cardColor),
                          textDirection: TextDirection.ltr,
                      ),
                      Text(
                        store.discount!.discountType == 'percent'
                            ? '${'enjoy'.tr} ${store.discount!.discount}% ${'off_on_all_categories'.tr}'
                            : '${'enjoy'.tr} ${PriceConverter.convertPrice(store.discount!.discount)}'
                            ' ${'off_on_all_categories'.tr}',
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor), textDirection: TextDirection.ltr,
                      ),
                      SizedBox(height: (store.discount!.minPurchase != 0 || store.discount!.maxDiscount != 0) ? 5 : 0),
                      store.discount!.minPurchase != 0 ? Text(
                        '[ ${'minimum_purchase'.tr}: ${PriceConverter.convertPrice(store.discount!.minPurchase)} ]',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor), textDirection: TextDirection.ltr,
                      ) : const SizedBox(),
                      store.discount!.maxDiscount != 0 ? Text(
                        '[ ${'maximum_discount'.tr}: ${PriceConverter.convertPrice(store.discount!.maxDiscount)} ]',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor), textDirection: TextDirection.ltr,
                      ) : const SizedBox(),
                      Text(
                        '[ ${'daily_time'.tr}: ${DateConverter.convertTimeToTime(store.discount!.startTime!)} '
                            '- ${DateConverter.convertTimeToTime(store.discount!.endTime!)} ]',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor),
                      ),
                    ]),
                  ) : const SizedBox(),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  storeController.recommendedItemModel != null && storeController.recommendedItemModel!.items!.isNotEmpty ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('recommended_items'.tr, style: robotoMedium),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      SizedBox(
                        height: ResponsiveHelper.isDesktop(context) ? 150 : 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: storeController.recommendedItemModel!.items!.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(vertical: 20) : const EdgeInsets.symmetric(vertical: 10) ,
                              child: Container(
                                width: ResponsiveHelper.isDesktop(context) ? 500 : 300,
                                decoration: ResponsiveHelper.isDesktop(context) ? null : BoxDecoration(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    color: Theme.of(context).cardColor,
                                    border: Border.all(color: Theme.of(context).disabledColor, width: 0.2),
                                    boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, blurRadius: 5)]
                                ),
                                padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeExtraSmall),
                                margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                child: ItemWidget(
                                  isStore: false, item: storeController.recommendedItemModel!.items![index],
                                  store: null, index: index, length: null, isCampaign: false, inStore: true,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ) : const SizedBox(),
                ]),
              ))),

              (storeController.categoryList!.isNotEmpty) ? SliverPersistentHeader(
                pinned: true,
                delegate: SliverDelegate(child: Center(child: Container(
                  height: 50, width: Dimensions.webMaxWidth, color: Theme.of(context).cardColor,
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: storeController.categoryList!.length,
                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () => storeController.setCategoryIndex(index),
                        child: Container(
                          padding: EdgeInsets.only(
                            left: index == 0 ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall,
                            right: index == storeController.categoryList!.length-1 ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall,
                            top: Dimensions.paddingSizeSmall,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(
                                _ltr ? index == 0 ? Dimensions.radiusExtraLarge : 0 : index == storeController.categoryList!.length-1
                                    ? Dimensions.radiusExtraLarge : 0,
                              ),
                              right: Radius.circular(
                                _ltr ? index == storeController.categoryList!.length-1 ? Dimensions.radiusExtraLarge : 0 : index == 0
                                    ? Dimensions.radiusExtraLarge : 0,
                              ),
                            ),
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                          ),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(
                              storeController.categoryList![index].name!,
                              style: index == storeController.categoryIndex
                                  ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)
                                  : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                            ),
                            index == storeController.categoryIndex ? Container(
                              height: 5, width: 5,
                              decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                            ) : const SizedBox(height: 5, width: 5),
                          ]),
                        ),
                      );
                    },
                  ),
                ))),
              ) : const SliverToBoxAdapter(child: SizedBox()),

              SliverToBoxAdapter(child: FooterView(child: Container(
                width: Dimensions.webMaxWidth,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                ),
                child: 
                PaginatedListView(
                  scrollController: scrollController,
                  onPaginate: (int? offset) => storeController.getStoreItemList(widget.store!.id, offset!, storeController.type, false),
                  totalSize: storeController.storeItemModel != null ? storeController.storeItemModel!.totalSize : null,
                  offset: storeController.storeItemModel != null ? storeController.storeItemModel!.offset : null,
                  itemView:
              
                   ItemsView(
                    isStore: false, stores: null,
                    items: (storeController.categoryList!.isNotEmpty && storeController.storeItemModel != null)
                        ? storeController.storeItemModel!.items : null,
                    inStorePage: true, type: storeController.type, onVegFilterTap: (String type) {
                    storeController.getStoreItemList(storeController.store!.id, 1, type, true);
                  },
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeSmall,
                      vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0,
                    ),
                  ),
                ),
              )
              )),
            ],
          ) : const Center(child: CircularProgressIndicator());
        });
      }),

      floatingActionButton: GetBuilder<StoreController>(
        builder: (storeController) {
          return Visibility(
            visible: storeController.showFavButton && Get.find<SplashController>().configModel!.moduleConfig!.module!.orderAttachment!
                && (storeController.store != null && storeController.store!.prescriptionOrder!) && Get.find<SplashController>().configModel!.prescriptionStatus!,
            child: Row(mainAxisSize: MainAxisSize.min, children: [

              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                width: storeController.currentState == false ? 0 : ResponsiveHelper.isDesktop(context) ? 180 : 150,
                height: 30,
                curve: Curves.linear,
                decoration: BoxDecoration(
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: storeController.currentState ? Center(
                  child: Text(
                    'prescription_order'.tr, textAlign: TextAlign.center,
                    style: robotoMedium.copyWith(color: Theme.of(context).cardColor), maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ) : const SizedBox(),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              FloatingActionButton(
                onPressed: () => Get.toNamed(
                  RouteHelper.getCheckoutRoute('prescription', storeId: storeController.store!.id),
                  arguments: CheckoutScreen(fromCart: false, cartList: null, storeId: storeController.store!.id),
                ),
                child: Icon(Icons.assignment_outlined, size: 20, color: Theme.of(context).cardColor),
              ),
            ]),
          );
        }
      ),

      bottomNavigationBar: GetBuilder<CartController>(builder: (cartController) {
        return cartController.cartList.isNotEmpty && !ResponsiveHelper.isDesktop(context) ? const BottomCartWidget() : const SizedBox();
      })
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;

  SliverDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != 50 || oldDelegate.minExtent != 50 || child != oldDelegate.child;
  }
}

class CategoryProduct {
  CategoryModel category;
  List<Item> products;
  CategoryProduct(this.category, this.products);
}
