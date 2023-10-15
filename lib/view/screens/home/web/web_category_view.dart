import 'package:sixam_mart/controller/category_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class WebCategoryView extends StatelessWidget {
  final CategoryController categoryController;

  const WebCategoryView({Key? key, required this.categoryController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController = ScrollController();

    void scrollToPosition(int steps) {
      double currentPosition = _scrollController.position.pixels;
      double newPosition = currentPosition +
          (steps *
              150); // Replace yourStepSize with the actual step size you want to use
      if (newPosition < 0) {
        newPosition = 0;
      } else if (newPosition > _scrollController.position.maxScrollExtent) {
        newPosition = _scrollController.position.maxScrollExtent;
      }
      _scrollController.animateTo(newPosition,
          duration: const Duration(milliseconds: 800), curve: Curves.easeInOut);
    }

    return Container(
      width: Get.width,
      decoration:  BoxDecoration(
        color: Get.isDarkMode ? Colors.black : Colors.white,
        borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(Dimensions.radiusSmall)),
        // boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 200]!, blurRadius: 5, spreadRadius: 1)]
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: Dimensions.paddingSizeSmall,
                  left: Dimensions.paddingSizeExtraSmall),
              child: Text('categories'.tr,
                  style: robotoMedium.copyWith(fontSize: 24, color: Get.isDarkMode ? Colors.white : Colors.black)),
            ),
            Row(
              children: [
                InkWell(
                  onTap: () => scrollToPosition(-5),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: Dimensions.paddingSizeSmall,
                        right: Dimensions.paddingSizeExtraSmall),
                    child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Get.isDarkMode ? Theme.of(context)
                            .primaryColor
                            .withOpacity(0.5) : Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Icon(Icons.arrow_back,
                            size: 20, color: Theme.of(context).primaryColor)),
                  ),
                ),
                const SizedBox(width: 2),
                InkWell(
                  onTap: () => scrollToPosition(5),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: Dimensions.paddingSizeSmall,
                        right: Dimensions.paddingSizeExtraSmall),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Get.isDarkMode ? Theme.of(context)
                          .primaryColor
                          .withOpacity(0.5) : Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Icon(Icons.arrow_forward,
                          size: 20, color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
        // const SizedBox(height: Dimensions.paddingSizeDefault),

        categoryController.categoryList != null
            ? Container(
                color: Theme.of(context).cardColor,
                height: 230,
                child: ListView.builder(
                  controller: _scrollController,

                  scrollDirection: Axis.horizontal,
                  // physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: categoryController.categoryList!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 4,
                        right: 4,
                        top: 8,
                      ),
                      child: InkWell(
                        onTap: () =>
                            Get.toNamed(RouteHelper.getCategoryItemRoute(
                          categoryController.categoryList![index].id,
                          categoryController.categoryList![index].name!,
                        )),
                        child: Container(

                          height: 230,
                          width: 150,
                          padding: const EdgeInsets.all(
                              Dimensions.paddingSizeExtraSmall),
                          // color: Theme.of(context).primaryColor.withOpacity(0.1),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radiusSmall),
                              color: Theme.of(context).cardColor,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors
                                        .grey[Get.isDarkMode ? 700 : 400]!,
                                    blurRadius: 5,
                                    spreadRadius: 1)
                              ]),
                          margin: const EdgeInsets.only(
                              bottom: Dimensions.paddingSizeSmall),
                          child: Column(children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radiusSmall),
                              child: CustomImage(
                                image:
                                    '${Get.find<SplashController>().configModel!.baseUrls!.categoryImageUrl}/${categoryController.categoryList![index].image}',
                                height: 150,
                                width: 140,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            Expanded(
                                child: Text(
                              categoryController.categoryList![index].name!,
                              style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )),
                          ]),
                        ),
                      ),
                    );
                  },
                ),
              )
            : WebCategoryShimmer(categoryController: categoryController),
      ]),
    );
  }
}

class WebCategoryShimmer extends StatelessWidget {
  final CategoryController categoryController;

  const WebCategoryShimmer({Key? key, required this.categoryController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 11,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(
              left: 4,
              right: 4,
              top: 8,
            ),
            child: Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              margin:
                  const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              child: Shimmer(
                duration: const Duration(seconds: 2),
                enabled: categoryController.categoryList == null,
                child: Column(children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusSmall),
                        color: Colors.grey[300]),
                    height: 150,
                    width: 150,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Container(height: 15, width: 150, color: Colors.grey[300]),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}
