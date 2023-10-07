import 'package:sixam_mart/data/model/response/address_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressWidget extends StatelessWidget {
  final AddressModel? address;
  final bool fromAddress;
  final bool fromCheckout;
  final Function? onRemovePressed;
  final Function? onEditPressed;
  final Function? onTap;
  const AddressWidget({Key? key, required this.address, required this.fromAddress, this.onRemovePressed, this.onEditPressed,
    this.onTap, this.fromCheckout = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: InkWell(
        onTap: onTap as void Function()?,
        child: Container(
          padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeDefault
              : Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: fromCheckout ? null : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            border: fromCheckout ? Border.all(color: Theme.of(context).disabledColor, width: 1) : null,
            boxShadow: fromCheckout ? null : [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, blurRadius: 5, spreadRadius: 1)],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(
              address!.addressType == 'home' ? Icons.home_filled : address!.addressType == 'office'
                  ? Icons.work : Icons.location_on,
              size: ResponsiveHelper.isDesktop(context) ? 50 : 40, color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  address!.addressType!.tr,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Text(
                  address!.address!,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ]),
            ),
            // fromAddress ? IconButton(
            //   icon: Icon(Icons.edit, color: Colors.blue, size: ResponsiveHelper.isDesktop(context) ? 35 : 25),
            //   onPressed: onEditPressed,
            // ) : SizedBox(),
            fromAddress ? IconButton(
              icon: Icon(Icons.delete, color: Colors.red, size: ResponsiveHelper.isDesktop(context) ? 35 : 25),
              onPressed: onRemovePressed as void Function()?,
            ) : const SizedBox(),
          ]),
        ),
      ),
    );
  }
}