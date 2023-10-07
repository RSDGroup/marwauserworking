import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:url_launcher/url_launcher_string.dart';

class RegistrationCard extends StatelessWidget {
  final bool isStore;
  const RegistrationCard({Key? key, required this.isStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [

      ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: Opacity(opacity: 0.05, child: Image.asset(Images.landingBg, height: 200, width: context.width, fit: BoxFit.fill)),
      ),

      Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).primaryColor.withOpacity(0.05),
        ),
        child: Row(children: [
          Expanded(flex: 6, child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                isStore ? 'become_a_seller'.tr : 'join_as_a_delivery_man'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge), textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Text(
                isStore ? 'register_as_seller_and_open_shop_in'.tr + AppConstants.appName + 'to_start_your_business'.tr
                    : 'register_as_delivery_man_and_earn_money'.tr,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall), textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
              CustomButton(
                buttonText: 'register'.tr, fontSize: Dimensions.fontSizeSmall,
                width: 100, height: 40,
                onPressed: () async {
                  String url = isStore ? '${AppConstants.baseUrl}/store/apply' : '${AppConstants.baseUrl}/deliveryman/apply';
                  if(await canLaunchUrlString(url)) {
                    launchUrlString(url);
                  }
                },
              ),
            ]),
          )),
          Expanded(flex: 4, child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Image.asset(isStore ? Images.landingStoreOpen : Images.landingDeliveryMan, height: 200, width: 200),
          )),
        ]),
      ),

    ]);
  }
}
