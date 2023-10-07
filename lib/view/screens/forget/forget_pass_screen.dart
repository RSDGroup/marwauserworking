import 'package:country_code_picker/country_code_picker.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/body/social_log_in_body.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/custom_text_field.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_number/phone_number.dart';

class ForgetPassScreen extends StatefulWidget {
  final bool fromSocialLogin;
  final SocialLogInBody? socialLogInBody;
  const ForgetPassScreen({Key? key, required this.fromSocialLogin, required this.socialLogInBody}) : super(key: key);

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
  final TextEditingController _numberController = TextEditingController();
  String? _countryDialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.fromSocialLogin ? 'phone'.tr : 'forgot_password'.tr),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: SafeArea(child: Center(child: Scrollbar(child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: FooterView(child: Container(
          width: context.width > 700 ? 700 : context.width,
          padding: context.width > 700 ? const EdgeInsets.all(Dimensions.paddingSizeDefault) : null,
          margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: context.width > 700 ? BoxDecoration(
            color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, blurRadius: 5, spreadRadius: 1)],
          ) : null,
          child: Column(children: [

            Image.asset(Images.forgot, height: 220),

            Padding(
              padding: const EdgeInsets.all(30),
              child: Text('please_enter_mobile'.tr, style: robotoRegular, textAlign: TextAlign.center),
            ),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                color: Theme.of(context).cardColor,
              ),
              child: Row(children: [
                CountryCodePicker(
                  onChanged: (CountryCode countryCode) {
                    _countryDialCode = countryCode.dialCode;
                  },
                  initialSelection: _countryDialCode,
                  favorite: [_countryDialCode!],
                  showDropDownButton: true,
                  padding: EdgeInsets.zero,
                  showFlagMain: true,
                  dialogBackgroundColor: Theme.of(context).cardColor,
                  textStyle: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
                Expanded(child: CustomTextField(
                  controller: _numberController,
                  inputType: TextInputType.phone,
                  inputAction: TextInputAction.done,
                  hintText: 'phone'.tr,
                  onSubmit: (text) => GetPlatform.isWeb ? _forgetPass(_countryDialCode!) : null,
                )),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            GetBuilder<AuthController>(builder: (authController) {
              return !authController.isLoading ? CustomButton(
                buttonText: 'next'.tr,
                onPressed: () => _forgetPass(_countryDialCode!),
              ) : const Center(child: CircularProgressIndicator());
            }),

          ]),
        )),
      )))),
    );
  }

  void _forgetPass(String countryCode) async {
    String phone = _numberController.text.trim();

    String numberWithCountryCode = countryCode+phone;
    bool isValid = GetPlatform.isAndroid ? false : true;
    if(GetPlatform.isAndroid) {
      try {
        PhoneNumber phoneNumber = await PhoneNumberUtil().parse(numberWithCountryCode);
        numberWithCountryCode = '+${phoneNumber.countryCode}${phoneNumber.nationalNumber}';
        isValid = true;
      } catch (_) {}
    }

    if (phone.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    }else if (!isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
    }else {
      if(widget.fromSocialLogin) {
        widget.socialLogInBody!.phone = numberWithCountryCode;
        Get.find<AuthController>().registerWithSocialMedia(widget.socialLogInBody!);
      }else {
        Get.find<AuthController>().forgetPassword(numberWithCountryCode).then((status) async {
          if (status.isSuccess) {
            Get.toNamed(RouteHelper.getVerificationRoute(numberWithCountryCode, '', RouteHelper.forgotPassword, ''));
          }else {
            showCustomSnackBar(status.message);
          }
        });
      }
    }
  }
}
