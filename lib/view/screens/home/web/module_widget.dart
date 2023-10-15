import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_image.dart';

class ModuleWidget extends StatelessWidget {
  const ModuleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splashController) {
      return (ResponsiveHelper.isDesktop(context) &&
          splashController.configModel!.module == null &&
          splashController.moduleList != null
          && splashController.moduleList!.length > 1) ? Container(
        width: Get.width,
        height: 60,
        decoration: BoxDecoration(
          color: Theme
              .of(context)
              .cardColor,
          borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(Dimensions.radiusDefault)),
          // boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 200]!, spreadRadius: 0.5, blurRadius: 5)],
        ),
        child: Center(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: splashController.moduleList!.length,
            padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(
                    bottom: Dimensions.paddingSizeSmall),
                child: InkWell(
                  onTap: () => splashController.switchModule(index, false),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .primaryColor
                          .withAlpha((splashController.module != null
                          && splashController.moduleList![index].id ==
                              splashController.module!.id) ? Get.isDarkMode
                          ? 250
                          : 250 : Get.isDarkMode ? 0 : 0),
                      borderRadius: const BorderRadius.all(Radius.circular(60)),
                      // border: Border.all(color: Theme.of(context).primaryColor)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, top: 8, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(splashController.moduleList![index].moduleName!,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: splashController.module != null
                                  && splashController.moduleList![index].id ==
                                      splashController.module!.id ? Colors.white : Get.isDarkMode ? Colors.white : Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,),
                          const SizedBox(width: 2),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                                Dimensions.radiusSmall),
                            child: CustomImage(
                              image: '${splashController.configModel!.baseUrls!
                                  .moduleImageUrl}/${splashController
                                  .moduleList![index].icon}',
                              height: 40, width: 40,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) =>
            const SizedBox(width: Dimensions.paddingSizeSmall),
          ),
        ),
      ) : const SizedBox();
    });
  }
}
