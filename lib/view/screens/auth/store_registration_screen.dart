import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/data/model/body/store_body.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/custom_text_field.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/screens/auth/widget/module_view.dart';
import 'package:sixam_mart/view/screens/auth/widget/select_location_view.dart';

class StoreRegistrationScreen extends StatefulWidget {
  const StoreRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<StoreRegistrationScreen> createState() => _StoreRegistrationScreenState();
}

class _StoreRegistrationScreenState extends State<StoreRegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _vatController = TextEditingController();
  final TextEditingController _minTimeController = TextEditingController();
  final TextEditingController _maxTimeController = TextEditingController();
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _vatFocus = FocusNode();
  final FocusNode _minTimeFocus = FocusNode();
  final FocusNode _maxTimeFocus = FocusNode();
  final FocusNode _fNameFocus = FocusNode();
  final FocusNode _lNameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    Get.find<AuthController>().getZoneList();
    Get.find<AuthController>().setDeliveryTimeTypeIndex(Get.find<AuthController>().deliveryTimeTypeList[0], false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'store_registration'.tr),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: SingleChildScrollView(
        padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
        child: FooterView(
          child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: GetBuilder<AuthController>(builder: (authController) {
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              CustomTextField(
                hintText: 'store_name'.tr,
                controller: _nameController,
                focusNode: _nameFocus,
                nextFocus: _addressFocus,
                inputType: TextInputType.name,
                capitalization: TextCapitalization.words,
                showTitle: true,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              CustomTextField(
                hintText: 'store_address'.tr,
                controller: _addressController,
                focusNode: _addressFocus,
                nextFocus: _vatFocus,
                inputType: TextInputType.text,
                capitalization: TextCapitalization.sentences,
                maxLines: 3,
                showTitle: true,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              CustomTextField(
                hintText: 'vat_tax'.tr,
                controller: _vatController,
                focusNode: _vatFocus,
                nextFocus: _minTimeFocus,
                inputType: TextInputType.number,
                isAmount: true,
                showTitle: true,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Row(children: [
                Expanded(child: CustomTextField(
                  hintText: 'minimum_delivery_time'.tr,
                  controller: _minTimeController,
                  focusNode: _minTimeFocus,
                  nextFocus: _maxTimeFocus,
                  inputType: TextInputType.number,
                  isNumber: true,
                  showTitle: true,
                )),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(child: CustomTextField(
                  hintText: 'maximum_delivery_time'.tr,
                  controller: _maxTimeController,
                  focusNode: _maxTimeFocus,
                  inputType: TextInputType.number,
                  isNumber: true,
                  inputAction: TextInputAction.done,
                  showTitle: true,
                )),
              ]),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        'delivery_time_type'.tr,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 5))],
                        ),
                        child: DropdownButton<String>(
                          value: authController.deliveryTimeTypeList[authController.deliveryTimeTypeIndex],
                          items: authController.deliveryTimeTypeList.map((String? value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value!.tr),
                            );
                          }).toList(),
                          onChanged: (value) {
                            authController.setDeliveryTimeTypeIndex(value, true);
                          },
                          isExpanded: true,
                          underline: const SizedBox(),
                        ),
                      ),
                    ]),
                  ),
                  /*SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

                  Expanded(child: ModuleViewWidget()),*/
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Text(
                'logo'.tr,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Align(alignment: Alignment.center, child: Stack(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: authController.pickedLogo != null ? GetPlatform.isWeb ? Image.network(
                    authController.pickedLogo!.path, width: 150, height: 120, fit: BoxFit.cover,
                  ) : Image.file(
                    File(authController.pickedLogo!.path), width: 150, height: 120, fit: BoxFit.cover,
                  ) : Image.asset(
                    Images.placeholder, width: 150, height: 120, fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 0, right: 0, top: 0, left: 0,
                  child: InkWell(
                    onTap: () => authController.pickImage(true, false),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        border: Border.all(width: 1, color: Theme.of(context).primaryColor),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.white),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ])),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text(
                'cover_photo'.tr,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Stack(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: authController.pickedCover != null ? GetPlatform.isWeb ? Image.network(
                    authController.pickedCover!.path, width: context.width, height: 170, fit: BoxFit.cover,
                  ) : Image.file(
                    File(authController.pickedCover!.path), width: context.width, height: 170, fit: BoxFit.cover,
                  ) : Image.asset(
                    Images.placeholder, width: context.width, height: 170, fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 0, right: 0, top: 0, left: 0,
                  child: InkWell(
                    onTap: () => authController.pickImage(false, false),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        border: Border.all(width: 1, color: Theme.of(context).primaryColor),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          border: Border.all(width: 3, color: Colors.white),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 50),
                      ),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              authController.zoneList != null ? const SelectLocationView(fromView: true) : const Center(child: CircularProgressIndicator()),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              authController.moduleList != null ? const ModuleViewWidget() : const SizedBox(),
              SizedBox(height: authController.moduleList != null ? Dimensions.paddingSizeLarge : 0),

              Center(child: Text(
                'owner_information'.tr,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
              )),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Row(children: [
                Expanded(child: CustomTextField(
                  hintText: 'first_name'.tr,
                  controller: _fNameController,
                  focusNode: _fNameFocus,
                  nextFocus: _lNameFocus,
                  inputType: TextInputType.name,
                  capitalization: TextCapitalization.words,
                  showTitle: true,
                )),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(child: CustomTextField(
                  hintText: 'last_name'.tr,
                  controller: _lNameController,
                  focusNode: _lNameFocus,
                  nextFocus: _phoneFocus,
                  inputType: TextInputType.name,
                  capitalization: TextCapitalization.words,
                  showTitle: true,
                )),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              CustomTextField(
                hintText: 'phone'.tr,
                controller: _phoneController,
                focusNode: _phoneFocus,
                nextFocus: _emailFocus,
                inputType: TextInputType.phone,
                showTitle: true,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Center(child: Text(
                'login_information'.tr,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
              )),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              CustomTextField(
                hintText: 'email'.tr,
                controller: _emailController,
                focusNode: _emailFocus,
                nextFocus: _passwordFocus,
                inputType: TextInputType.emailAddress,
                showTitle: true,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Row(children: [
                Expanded(child: CustomTextField(
                  hintText: 'password'.tr,
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  nextFocus: _confirmPasswordFocus,
                  inputType: TextInputType.visiblePassword,
                  isPassword: true,
                  showTitle: true,
                )),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(child: CustomTextField(
                  hintText: 'confirm_password'.tr,
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocus,
                  inputType: TextInputType.visiblePassword,
                  isPassword: true,
                  showTitle: true,
                )),
              ]),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              !authController.isLoading ? CustomButton(
                buttonText: 'submit'.tr,
                onPressed: () {
                  String name = _nameController.text.trim();
                  String address = _addressController.text.trim();
                  String vat = _vatController.text.trim();
                  String minTime = _minTimeController.text.trim();
                  String maxTime = _maxTimeController.text.trim();
                  String fName = _fNameController.text.trim();
                  String lName = _lNameController.text.trim();
                  String phone = _phoneController.text.trim();
                  String email = _emailController.text.trim();
                  String password = _passwordController.text.trim();
                  String confirmPassword = _confirmPasswordController.text.trim();
                  if(name.isEmpty) {
                    showCustomSnackBar('enter_store_name'.tr);
                  }else if(address.isEmpty) {
                    showCustomSnackBar('enter_store_address'.tr);
                  }else if(vat.isEmpty) {
                    showCustomSnackBar('enter_vat_amount'.tr);
                  }else if(minTime.isEmpty) {
                    showCustomSnackBar('enter_minimum_delivery_time'.tr);
                  }else if(maxTime.isEmpty) {
                    showCustomSnackBar('enter_maximum_delivery_time'.tr);
                  }else if(double.parse(minTime) > double.parse(maxTime)) {
                    showCustomSnackBar('maximum_delivery_time_can_not_be_smaller_then_minimum_delivery_time'.tr);
                  }else if(authController.pickedLogo == null) {
                    showCustomSnackBar('select_store_logo'.tr);
                  }else if(authController.pickedCover == null) {
                    showCustomSnackBar('select_store_cover_photo'.tr);
                  }else if(authController.restaurantLocation == null) {
                    showCustomSnackBar('set_store_location'.tr);
                  }else if(fName.isEmpty) {
                    showCustomSnackBar('enter_your_first_name'.tr);
                  }else if(lName.isEmpty) {
                    showCustomSnackBar('enter_your_last_name'.tr);
                  }else if(phone.isEmpty) {
                    showCustomSnackBar('enter_phone_number'.tr);
                  }else if(email.isEmpty) {
                    showCustomSnackBar('enter_email_address'.tr);
                  }else if(!GetUtils.isEmail(email)) {
                    showCustomSnackBar('enter_a_valid_email_address'.tr);
                  }else if(password.isEmpty) {
                    showCustomSnackBar('enter_password'.tr);
                  }else if(password.length < 6) {
                    showCustomSnackBar('password_should_be'.tr);
                  }else if(password != confirmPassword) {
                    showCustomSnackBar('confirm_password_does_not_matched'.tr);
                  }else {
                    authController.registerStore(StoreBody(
                      storeName: name, storeAddress: address, tax: vat, minDeliveryTime: minTime,
                      maxDeliveryTime: maxTime, lat: authController.restaurantLocation!.latitude.toString(), email: email,
                      lng: authController.restaurantLocation!.longitude.toString(), fName: fName, lName: lName, phone: phone,
                      password: password, zoneId: authController.zoneList![authController.selectedZoneIndex!].id.toString(),
                      moduleId: authController.moduleList![authController.selectedModuleIndex!].id.toString(),
                      deliveryTimeType: authController.deliveryTimeTypeList[authController.deliveryTimeTypeIndex],
                    ));
                  }
                },
              ) : const Center(child: CircularProgressIndicator()),

            ]);
          }))),
        ),
      ),
    );
  }

}
