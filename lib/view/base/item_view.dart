import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/data/model/response/store_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/view/base/no_data_screen.dart';
import 'package:sixam_mart/view/base/item_shimmer.dart';
import 'package:sixam_mart/view/base/item_widget.dart';
import 'package:sixam_mart/view/base/veg_filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/view/screens/home/theme1/store_widget.dart';

class ItemsView extends StatefulWidget {
  final List<Item?>? items;
  final List<Store?>? stores;
  final bool isStore;
  final EdgeInsetsGeometry padding;
  final bool isScrollable;
  final int shimmerLength;
  final String? noDataText;
  final bool isCampaign;
  final bool inStorePage;
  final String? type;
  final bool isFeatured;
  final bool showTheme1Store;
  final Function(String type)? onVegFilterTap;
  const ItemsView(
      {Key? key,
      required this.stores,
      required this.items,
      required this.isStore,
      this.isScrollable = false,
      this.shimmerLength = 20,
      this.padding = const EdgeInsets.all(Dimensions.paddingSizeSmall),
      this.noDataText,
      this.isCampaign = false,
      this.inStorePage = false,
      this.type,
      this.onVegFilterTap,
      this.isFeatured = false,
      this.showTheme1Store = false})
      : super(key: key);

  @override
  State<ItemsView> createState() => _ItemsViewState();
}

class _ItemsViewState extends State<ItemsView> {
  @override
  Widget build(BuildContext context) {
    bool isNull = true;
    int length = 0;
    if (widget.isStore) {
      isNull = widget.stores == null;
      if (!isNull) {
        length = widget.stores!.length;
      }
    } else {
      isNull = widget.items == null;
      if (!isNull) {
        length = widget.items!.length;
      }
    }

    return Column(children: [
      widget.type != null
          ? VegFilterWidget(
              type: widget.type, onSelected: widget.onVegFilterTap)
          : const SizedBox(),
      !isNull
          ? length > 0
              ? GridView.builder(
                  key: UniqueKey(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: Dimensions.paddingSizeLarge,
                    mainAxisSpacing: ResponsiveHelper.isDesktop(context)
                        ? Dimensions.paddingSizeLarge
                        : 0.01,
                    childAspectRatio: ResponsiveHelper.isDesktop(context)
                        ? 4
                        : widget.showTheme1Store
                            ? 1.9
                            : 4,
                    crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
                  ),
                  physics: widget.isScrollable
                      ? const BouncingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  shrinkWrap: widget.isScrollable ? false : true,
                  itemCount: length,
                  padding: widget.padding,
                  itemBuilder: (context, index) {
                    return widget.showTheme1Store
                        ? StoreWidget(
                            store: widget.stores![index],
                            index: index,
                            inStore: widget.inStorePage):
                      
                         ItemWidget(
                            isStore: widget.isStore,
                            item: widget.isStore ? null : widget.items![index],
                            isFeatured: widget.isFeatured,
                            store:
                                widget.isStore ? widget.stores![index] : null,
                            index: index,
                            length: length,
                            isCampaign: widget.isCampaign,
                            inStore: widget.inStorePage,
                          );
                  },
                )
              : NoDataScreen(
                  text: widget.noDataText ??
                      (widget.isStore
                          ? Get.find<SplashController>()
                                  .configModel!
                                  .moduleConfig!
                                  .module!
                                  .showRestaurantText!
                              ? 'no_restaurant_available'.tr
                              : 'no_store_available'.tr
                          : 'no_item_available'.tr),
                )
          : GridView.builder(
              key: UniqueKey(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: Dimensions.paddingSizeLarge,
                mainAxisSpacing: ResponsiveHelper.isDesktop(context)
                    ? Dimensions.paddingSizeLarge
                    : 0.01,
                childAspectRatio: ResponsiveHelper.isDesktop(context)
                    ? 4
                    : widget.showTheme1Store
                        ? 1.9
                        : 4,
                crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
              ),
              physics: widget.isScrollable
                  ? const BouncingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              shrinkWrap: widget.isScrollable ? false : true,
              itemCount: widget.shimmerLength,
              padding: widget.padding,
              itemBuilder: (context, index) {
                return widget.showTheme1Store
                    ? StoreShimmer(isEnable: isNull)
                    : ItemShimmer(
                        isEnabled: isNull,
                        isStore: widget.isStore,
                        hasDivider: index != widget.shimmerLength - 1);
              },
            ),
    ]);
  }
}
