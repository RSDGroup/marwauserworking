import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool? isButtonActive;
  final Function onTap;
  const ProfileButton({Key? key, required this.icon, required this.title, required this.onTap, this.isButtonActive}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: isButtonActive != null ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeDefault,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
        ),
        child: Row(children: [
          Icon(icon, size: 25),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(child: Text(title, style: robotoRegular)),
          isButtonActive != null ? Switch(
            value: isButtonActive!,
            onChanged: (bool isActive) => onTap(),
            activeColor: Theme.of(context).primaryColor,
            activeTrackColor: Theme.of(context).primaryColor.withOpacity(0.5),
          ) : const SizedBox(),
        ]),
      ),
    );
  }
}
