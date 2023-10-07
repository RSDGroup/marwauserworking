import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
class ModuleViewWidget extends StatelessWidget {
  const ModuleViewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      List<int> moduleIndexList = [];
      if(authController.moduleList != null) {
        for(int index=0; index < authController.moduleList!.length; index++) {
          if(authController.moduleList![index].moduleType != 'parcel') {
            moduleIndexList.add(index);
          }
        }
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Text(
          'select_module'.tr,
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        authController.moduleList != null ? Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 5))],
          ),
          child: DropdownButton<int>(
            value: authController.selectedModuleIndex,
            items: moduleIndexList.map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(authController.moduleList![value].moduleName!),
              );
            }).toList(),
            onChanged: (value) {
              authController.selectModuleIndex(value);
            },
            isExpanded: true,
            underline: const SizedBox(),
          ),
        ) : Center(child: Text('not_available_module'.tr)),
      ]);
    });
  }
}
