import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phone_number/phone_number.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/body/delivery_man_body.dart';
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

class DeliveryManRegistrationScreen extends StatefulWidget {
  const DeliveryManRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryManRegistrationScreen> createState() => _DeliveryManRegistrationScreenState();
}

class _DeliveryManRegistrationScreenState extends State<DeliveryManRegistrationScreen> {
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _identityNumberController = TextEditingController();
  final FocusNode _fNameNode = FocusNode();
  final FocusNode _lNameNode = FocusNode();
  final FocusNode _emailNode = FocusNode();
  final FocusNode _phoneNode = FocusNode();
  final FocusNode _passwordNode = FocusNode();
  final FocusNode _identityNumberNode = FocusNode();
  String? _countryDialCode;

  @override
  void initState() {
    super.initState();

    _countryDialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;
    Get.find<AuthController>().pickDmImage(false, true);
    Get.find<AuthController>().setIdentityTypeIndex(Get.find<AuthController>().identityTypeList[0], false);
    Get.find<AuthController>().setDMTypeIndex(Get.find<AuthController>().dmTypeList[0], false);
    Get.find<AuthController>().getZoneList();
    Get.find<AuthController>().getVehicleList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'delivery_man_registration'.tr),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<AuthController>(builder: (authController) {
        List<int> zoneIndexList = [];
        if(authController.zoneList != null) {
          for(int index=0; index<authController.zoneList!.length; index++) {
            zoneIndexList.add(index);
          }
        }

        return Column(children: [

          Expanded(child: SingleChildScrollView(
            padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeSmall),
            physics: const BouncingScrollPhysics(),
            child: FooterView(
              child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Align(alignment: Alignment.center, child: Text(
                  'delivery_man_image'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                )),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Align(alignment: Alignment.center, child: Stack(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: authController.pickedImage != null ? GetPlatform.isWeb ? Image.network(
                      authController.pickedImage!.path, width: 150, height: 120, fit: BoxFit.cover,
                    ) : Image.file(
                      File(authController.pickedImage!.path), width: 150, height: 120, fit: BoxFit.cover,
                    ) : Image.asset(
                      Images.placeholder, width: 150, height: 120, fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 0, right: 0, top: 0, left: 0,
                    child: InkWell(
                      onTap: () => authController.pickDmImage(true, false),
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
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Row(children: [
                  Expanded(child: CustomTextField(
                    hintText: 'first_name'.tr,
                    controller: _fNameController,
                    capitalization: TextCapitalization.words,
                    inputType: TextInputType.name,
                    focusNode: _fNameNode,
                    nextFocus: _lNameNode,
                    showTitle: true,
                  )),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(child: CustomTextField(
                    hintText: 'last_name'.tr,
                    controller: _lNameController,
                    capitalization: TextCapitalization.words,
                    inputType: TextInputType.name,
                    focusNode: _lNameNode,
                    nextFocus: _emailNode,
                    showTitle: true,
                  )),
                ]),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                CustomTextField(
                  hintText: 'email'.tr,
                  controller: _emailController,
                  focusNode: _emailNode,
                  nextFocus: _phoneNode,
                  inputType: TextInputType.emailAddress,
                  showTitle: true,
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Row(children: [
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      // boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200], spreadRadius: 1, blurRadius: 5, offset: Offset(0, 5))],
                    ),
                    child: CountryCodePicker(
                      onChanged: (CountryCode countryCode) {
                        _countryDialCode = countryCode.dialCode;
                      },
                      initialSelection: _countryDialCode,
                      favorite: [_countryDialCode!],
                      showDropDownButton: true,
                      padding: EdgeInsets.zero,
                      showFlagMain: true,
                      flagWidth: 30,
                      textStyle: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(flex: 1, child: CustomTextField(
                    hintText: 'phone'.tr,
                    controller: _phoneController,
                    focusNode: _phoneNode,
                    nextFocus: _passwordNode,
                    inputType: TextInputType.phone,
                  )),
                ]),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                CustomTextField(
                  hintText: 'password'.tr,
                  controller: _passwordController,
                  focusNode: _passwordNode,
                  nextFocus: _identityNumberNode,
                  inputType: TextInputType.visiblePassword,
                  isPassword: true,
                  showTitle: true,
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      'delivery_man_type'.tr,
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
                        value: authController.dmTypeList[authController.dmTypeIndex],
                        items: authController.dmTypeList.map((String? value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value!.tr),
                          );
                        }).toList(),
                        onChanged: (value) {
                          authController.setDMTypeIndex(value, true);
                        },
                        isExpanded: true,
                        underline: const SizedBox(),
                      ),
                    ),
                  ])),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      'zone'.tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    authController.zoneList != null ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 5))],
                      ),
                      child: DropdownButton<int>(
                        value: authController.selectedZoneIndex,
                        items: zoneIndexList.map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(authController.zoneList![value].name!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          authController.setZoneIndex(value);
                        },
                        isExpanded: true,
                        underline: const SizedBox(),
                      ),
                    ) : const Center(child: CircularProgressIndicator()),
                  ])),
                ]),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Row(children: [

                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      'identity_type'.tr,
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
                        value: authController.identityTypeList[authController.identityTypeIndex],
                        items: authController.identityTypeList.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value.tr),
                          );
                        }).toList(),
                        onChanged: (value) {
                          authController.setIdentityTypeIndex(value, true);
                        },
                        isExpanded: true,
                        underline: const SizedBox(),
                      ),
                    ),
                  ])),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(child: CustomTextField(
                    hintText: 'identity_number'.tr,
                    controller: _identityNumberController,
                    focusNode: _identityNumberNode,
                    inputAction: TextInputAction.done,
                    showTitle: true,
                  )),

                ]),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                authController.vehicleIds != null ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'vehicle_type'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      // boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200], spreadRadius: 2, blurRadius: 5, offset: Offset(0, 5))],
                    ),
                    child: DropdownButton<int>(
                      value: authController.vehicleIndex,
                      items: authController.vehicleIds!.map((int? value) {
                        return DropdownMenuItem<int>(
                          value: authController.vehicleIds!.indexOf(value),
                          child: Text(value != 0 ? authController.vehicles![(authController.vehicleIds!.indexOf(value)-1)].type! : 'Select'),
                        );
                      }).toList(),
                      onChanged: (int? value) {
                        authController.setVehicleIndex(value, true);
                      },
                      isExpanded: true,
                      underline: const SizedBox(),
                    ),
                  ),
                ]) : const CircularProgressIndicator(),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Text(
                  'identity_images'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: authController.pickedIdentities.length+1,
                    itemBuilder: (context, index) {
                      XFile? file = index == authController.pickedIdentities.length ? null : authController.pickedIdentities[index];
                      if(index == authController.pickedIdentities.length) {
                        return InkWell(
                          onTap: () => authController.pickDmImage(false, false),
                          child: Container(
                            height: 120, width: 150, alignment: Alignment.center, decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                          ),
                            child: Container(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                              decoration: BoxDecoration(
                                border: Border.all(width: 2, color: Theme.of(context).primaryColor),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.camera_alt, color: Theme.of(context).primaryColor),
                            ),
                          ),
                        );
                      }
                      return Container(
                        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: Stack(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            child: GetPlatform.isWeb ? Image.network(
                              file!.path, width: 150, height: 120, fit: BoxFit.cover,
                            ) : Image.file(
                              File(file!.path), width: 150, height: 120, fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 0, top: 0,
                            child: InkWell(
                              onTap: () => authController.removeIdentityImage(index),
                              child: const Padding(
                                padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                                child: Icon(Icons.delete_forever, color: Colors.red),
                              ),
                            ),
                          ),
                        ]),
                      );
                    },
                  ),
                ),

                const SizedBox(height: Dimensions.paddingSizeLarge),

                (ResponsiveHelper.isDesktop(context) || ResponsiveHelper.isWeb()) ? buttonView() : const SizedBox() ,

              ]))),
            ),
          )),

          (ResponsiveHelper.isDesktop(context) || ResponsiveHelper.isWeb()) ? const SizedBox() : buttonView(),

        ]);
      }),
    );
  }

  Widget buttonView(){
    return GetBuilder<AuthController>(builder: (authController) {
        return !authController.isLoading ? CustomButton(
          buttonText: 'submit'.tr,
          margin: EdgeInsets.all((ResponsiveHelper.isDesktop(context) || ResponsiveHelper.isWeb()) ? 0 : Dimensions.paddingSizeSmall),
          height: 50,
          onPressed: () => _addDeliveryMan(authController),
        ) : const Center(child: CircularProgressIndicator());
      });
  }

  void _addDeliveryMan(AuthController authController) async {
    String fName = _fNameController.text.trim();
    String lName = _lNameController.text.trim();
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String identityNumber = _identityNumberController.text.trim();

    String numberWithCountryCode = _countryDialCode!+phone;
    bool isValid = GetPlatform.isAndroid ? false : true;
    if(GetPlatform.isAndroid) {
      try {
        PhoneNumber phoneNumber = await PhoneNumberUtil().parse(numberWithCountryCode);
        numberWithCountryCode = '+${phoneNumber.countryCode}${phoneNumber.nationalNumber}';
        isValid = true;
      } catch (_) {}
    }
    if(fName.isEmpty) {
      showCustomSnackBar('enter_delivery_man_first_name'.tr);
    }else if(lName.isEmpty) {
      showCustomSnackBar('enter_delivery_man_last_name'.tr);
    }else if(email.isEmpty) {
      showCustomSnackBar('enter_delivery_man_email_address'.tr);
    }else if(!GetUtils.isEmail(email)) {
      showCustomSnackBar('enter_a_valid_email_address'.tr);
    }else if(phone.isEmpty) {
      showCustomSnackBar('enter_delivery_man_phone_number'.tr);
    }else if(!isValid) {
      showCustomSnackBar('enter_a_valid_phone_number'.tr);
    }else if(password.isEmpty) {
      showCustomSnackBar('enter_password_for_delivery_man'.tr);
    }else if(password.length < 6) {
      showCustomSnackBar('password_should_be'.tr);
    }else if(identityNumber.isEmpty) {
      showCustomSnackBar('enter_delivery_man_identity_number'.tr);
    }else if(authController.pickedImage == null) {
      showCustomSnackBar('upload_delivery_man_image'.tr);
    }else if(authController.vehicleIndex!-1 == -1) {
      showCustomSnackBar('please_select_vehicle_for_the_deliveryman'.tr);
    }else {
      authController.registerDeliveryMan(DeliveryManBody(
        fName: fName, lName: lName, password: password, phone: numberWithCountryCode, email: email,
        identityNumber: identityNumber, identityType: authController.identityTypeList[authController.identityTypeIndex],
        earning: authController.dmTypeIndex == 0 ? '1' : '0', zoneId: authController.zoneList![authController.selectedZoneIndex!].id.toString(),
        vehicleId: authController.vehicles![authController.vehicleIndex! - 1].id.toString(),
      ));
    }
  }
}

