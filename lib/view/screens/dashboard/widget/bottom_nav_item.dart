import 'package:flutter/material.dart';

import '../../../../util/images.dart';

class BottomNavItem extends StatelessWidget {
  final IconData iconData;
  final bool module;
  final Function? onTap;
  final bool isSelected;
  const BottomNavItem(
      {Key? key,
      required this.iconData,
      this.onTap,
      this.isSelected = false,
      this.module = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: module
          ? InkWell(
            onTap:onTap as void Function()? ,
            child: Image.asset(
                                                    Images.moduleIcon,
                                                    height: 25,
                                                    width: 25,
                                             color:          isSelected ? Theme.of(context).primaryColor : Colors.grey,),
          )
          : IconButton(
              icon: Icon(iconData,
                  color:
                      isSelected ? Theme.of(context).primaryColor : Colors.grey,
                  size: 25),
              onPressed: onTap as void Function()?,
            ),
    );
  }
}
