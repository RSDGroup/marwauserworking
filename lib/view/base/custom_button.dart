import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Function? onPressed;
  final String buttonText;
  final bool transparent;
  final EdgeInsets? margin;
  final double? height;
  final double? width;
  final double? fontSize;
  final double radius;
  final IconData? icon;
  final Color? color;
  const CustomButton({Key? key, this.onPressed, required this.buttonText, this.transparent = false, this.margin, this.width, this.height,
    this.fontSize, this.radius = 5, this.icon, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      backgroundColor: onPressed == null ? Theme.of(context).disabledColor : transparent
          ? Colors.transparent : color ?? Theme.of(context).primaryColor,
      minimumSize: Size(width != null ? width! : Dimensions.webMaxWidth, height != null ? height! : 50),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
    );

    return Center(child: SizedBox(width: width ?? Dimensions.webMaxWidth, child: Padding(
      padding: margin == null ? const EdgeInsets.all(0) : margin!,
      child: TextButton(
        onPressed: onPressed as void Function()?,
        style: flatButtonStyle,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          icon != null ? Padding(
            padding: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
            child: Icon(icon, color: transparent ? Theme.of(context).primaryColor : Theme.of(context).cardColor),
          ) : const SizedBox(),
          Text(buttonText, textAlign: TextAlign.center, style: robotoBold.copyWith(
            color: transparent ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
            fontSize: fontSize ?? Dimensions.fontSizeLarge,
          )),
        ]),
      ),
    )));
  }
}
