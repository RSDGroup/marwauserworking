import 'package:sixam_mart/util/dimensions.dart';
import 'package:flutter/material.dart';

class QuantityButton extends StatelessWidget {
  final bool isIncrement;
  final Function onTap;
  const QuantityButton({Key? key, required this.isIncrement, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Container(
        height: 22, width: 22,
        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 1, color: isIncrement ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
          color: isIncrement ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.2),
        ),
        alignment: Alignment.center,
        child: Icon(
          isIncrement ? Icons.add : Icons.remove,
          size: 15,
          color: isIncrement ? Theme.of(context).cardColor : Theme.of(context).disabledColor,
        ),
      ),
    );
  }
}