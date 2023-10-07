import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/controller/coupon_controller.dart';
import 'package:sixam_mart/controller/localization_controller.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/order_controller.dart';
import 'package:sixam_mart/controller/parcel_controller.dart';
import 'package:sixam_mart/controller/store_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/user_controller.dart';
import 'package:sixam_mart/data/model/body/place_order_body.dart';
import 'package:sixam_mart/data/model/response/address_model.dart';
import 'package:sixam_mart/data/model/response/cart_model.dart';
import 'package:sixam_mart/data/model/response/config_model.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/data/model/response/zone_response_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/custom_text_field.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/base/image_picker_widget.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/base/my_text_field.dart';
import 'package:sixam_mart/view/base/not_logged_in_screen.dart';
import 'package:sixam_mart/view/screens/address/widget/address_widget.dart';
import 'package:sixam_mart/view/screens/cart/widget/delivery_option_button.dart';
import 'package:sixam_mart/view/screens/checkout/widget/condition_check_box.dart';
import 'package:sixam_mart/view/screens/checkout/widget/payment_button.dart';
import 'package:sixam_mart/view/screens/checkout/widget/slot_widget.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/view/screens/checkout/widget/tips_widget.dart';
import 'package:sixam_mart/view/screens/home/home_screen.dart';
import 'package:sixam_mart/view/screens/store/widget/camera_button_sheet.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;




class CheckoutScreen extends StatefulWidget {
  final List<CartModel?>? cartList;
  final bool fromCart;
  final int? storeId;
  const CheckoutScreen({Key? key, required this.fromCart, required this.cartList, required this.storeId}) : super(key: key);

  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _couponController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _streetNumberController = TextEditingController();
  final TextEditingController _doorBellController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _tipController = TextEditingController();
  final FocusNode _streetNode = FocusNode();
  final FocusNode _doorbellNode = FocusNode();
  final FocusNode _houseNode = FocusNode();
  final FocusNode _floorNode = FocusNode();

  double? _taxPercent = 0;
  bool? _isCashOnDeliveryActive = false;
  bool? _isDigitalPaymentActive = false;
  bool? _isPaypalPaymentActive = false;
  bool? _isStripePaymentActive = false;
  bool? _isOtpPaymentActive = false;
  bool? _isKhPaymentActive = false;
  bool? _isMbhPaymentActive = false;

  String? platform = GetPlatform.isWeb  ? 'web' : GetPlatform.isIOS ? 'ios' : 'android' ;

  final ScrollController _scrollController = ScrollController();

  late bool _isLoggedIn;
  List<CartModel?>? _cartList;
  late bool _isWalletActive;

  Map<String,dynamic>? stripepaymentIntent;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = Get.find<AuthController>().isLoggedIn();
    if(_isLoggedIn) {


      _streetNumberController.text = Get.find<LocationController>().getUserAddress()!.streetNumber ?? '';
      _doorBellController.text = Get.find<LocationController>().getUserAddress()!.doorBell ?? '';
      _houseController.text = Get.find<LocationController>().getUserAddress()!.house ?? '';
      _floorController.text = Get.find<LocationController>().getUserAddress()!.floor ?? '';

      Get.find<LocationController>().getZone(
          Get.find<LocationController>().getUserAddress()!.latitude,
          Get.find<LocationController>().getUserAddress()!.longitude, false, updateInAddress: true
      );
      if(Get.find<UserController>().userInfoModel == null) {
        Get.find<UserController>().getUserInfo();
      }
      if(Get.find<LocationController>().addressList == null) {
        Get.find<LocationController>().getAddressList();
      }
      if(widget.storeId == null){
        _cartList = [];
        widget.fromCart ? _cartList!.addAll(Get.find<CartController>().cartList) : _cartList!.addAll(widget.cartList!);
        Get.find<StoreController>().initCheckoutData(_cartList![0]!.item!.storeId);
      }
      if(widget.storeId != null){
        Get.find<StoreController>().initCheckoutData(widget.storeId);
        Get.find<StoreController>().pickPrescriptionImage(isRemove: true, isCamera: false);
        Get.find<CouponController>().removeCouponData(false);
      }
      _isWalletActive = Get.find<SplashController>().configModel!.customerWalletStatus == 1;
      Get.find<OrderController>().updateTips(-1, notify: false);
      Get.find<OrderController>().paymentint();

    }
  }

  @override
  void dispose() {
    super.dispose();
    _streetNumberController.dispose();
    _doorBellController.dispose();
    _houseController.dispose();
    _floorController.dispose();
  }



  @override
  Widget build(BuildContext context) {
    Module? module = Get.find<SplashController>().configModel!.moduleConfig!.module;

    return Scaffold(
      appBar: CustomAppBar(title: 'checkout'.tr),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: _isLoggedIn ? GetBuilder<LocationController>(builder: (locationController) {
        return GetBuilder<StoreController>(builder: (storeController) {
          List<DropdownMenuItem<int>> addressList = [];
          addressList.add(DropdownMenuItem<int>(value: -1, child: SizedBox(
            width: context.width > Dimensions.webMaxWidth ? Dimensions.webMaxWidth-50 : context.width-50,
            child: AddressWidget(
              address: Get.find<LocationController>().getUserAddress(),
              fromAddress: false, fromCheckout: true,
            ),
          )));
          if(locationController.addressList != null && storeController.store != null) {
            for(int index=0; index<locationController.addressList!.length; index++) {
              if(locationController.addressList![index].zoneIds!.contains(storeController.store!.zoneId)) {
                addressList.add(DropdownMenuItem<int>(value: index, child: SizedBox(
                  width: context.width > Dimensions.webMaxWidth ? Dimensions.webMaxWidth-50 : context.width-50,
                  child: AddressWidget(
                    address: locationController.addressList![index],
                    fromAddress: false, fromCheckout: true,
                  ),
                )));
              }
            }
          }

          bool todayClosed = false;
          bool tomorrowClosed = false;
          Pivot? moduleData;
          if(storeController.store != null) {
            for(ZoneData zData in Get.find<LocationController>().getUserAddress()!.zoneData!) {

              if(zData.id ==  storeController.store!.zoneId){
                _isCashOnDeliveryActive = zData.cashOnDelivery;
                _isDigitalPaymentActive = zData.digitalPayment;
                _isPaypalPaymentActive = zData.paypalPayment;
                _isStripePaymentActive = zData.stripePayment;
                _isOtpPaymentActive = zData.otpPayment;
                _isKhPaymentActive = zData.khPayment;
                _isMbhPaymentActive = zData.mbhPayment;
             //   Get.find<OrderController>().setPaymentMethod(_isCashOnDeliveryActive! ? 0 : _isDigitalPaymentActive! ? 1 : 2, isUpdate: false);
              }
              for(Modules m in zData.modules!) {
                if(m.id == Get.find<SplashController>().module!.id) {
                  moduleData = m.pivot;
                  break;
                }
              }
            }
            todayClosed = storeController.isStoreClosed(true, storeController.store!.active!, storeController.store!.schedules);
            tomorrowClosed = storeController.isStoreClosed(false, storeController.store!.active!, storeController.store!.schedules);
            _taxPercent = storeController.store!.tax;
          }
          return GetBuilder<CouponController>(builder: (couponController) {
            return GetBuilder<OrderController>(builder: (orderController) {
              double? deliveryCharge = -1;
              double? charge = -1;
              double? maxCodOrderAmount;
              if(storeController.store != null && orderController.distance != null && orderController.distance != -1 && storeController.store!.selfDeliverySystem == 1) {
                deliveryCharge = orderController.distance! * storeController.store!.perKmShippingCharge!;
                charge = orderController.distance! * storeController.store!.perKmShippingCharge!;
                double? maximumCharge = storeController.store!.maximumShippingCharge;

                if(deliveryCharge < storeController.store!.minimumShippingCharge!) {
                  deliveryCharge = storeController.store!.minimumShippingCharge;
                  charge = storeController.store!.minimumShippingCharge;
                }else if(maximumCharge != null && deliveryCharge > maximumCharge){
                  deliveryCharge = maximumCharge;
                  charge = maximumCharge;
                }
              }else if(storeController.store != null && orderController.distance != null && orderController.distance != -1) {
                deliveryCharge = orderController.distance! * moduleData!.perKmShippingCharge!;
                charge = orderController.distance! * moduleData.perKmShippingCharge!;

                if(deliveryCharge < moduleData.minimumShippingCharge!) {
                  deliveryCharge = moduleData.minimumShippingCharge;
                  charge = moduleData.minimumShippingCharge;
                }else if(moduleData.maximumShippingCharge != null && deliveryCharge > moduleData.maximumShippingCharge!){
                  deliveryCharge = moduleData.maximumShippingCharge;
                  charge = moduleData.maximumShippingCharge;
                }
              }

              if(storeController.store != null && storeController.store!.selfDeliverySystem == 0 && orderController.extraCharge != null){
                deliveryCharge = deliveryCharge! + orderController.extraCharge!;
                charge = charge! + orderController.extraCharge!;
              }

              if(moduleData != null) {
                maxCodOrderAmount = moduleData.maximumCodOrderAmount;
              }

              double price = 0;
              double? discount = 0;
              double couponDiscount = couponController.discount!;
              double tax = 0;
              bool taxIncluded = Get.find<SplashController>().configModel!.taxIncluded == 1;
              double addOns = 0;
              double subTotal = 0;
              double orderAmount = 0;
              if(storeController.store != null && _cartList != null) {
                for (var cartModel in _cartList!) {
                  List<AddOns> addOnList = [];
                  for (var addOnId in cartModel!.addOnIds!) {
                    for (AddOns addOns in cartModel.item!.addOns!) {
                      if (addOns.id == addOnId.id) {
                        addOnList.add(addOns);
                        break;
                      }
                    }
                  }

                  for (int index = 0; index < addOnList.length; index++) {
                    addOns = addOns + (addOnList[index].price! * cartModel.addOnIds![index].quantity!);
                  }
                  price = price + (cartModel.price! * cartModel.quantity!);
                  double? dis = (storeController.store!.discount != null
                      && DateConverter.isAvailable(storeController.store!.discount!.startTime, storeController.store!.discount!.endTime))
                      ? storeController.store!.discount!.discount : cartModel.item!.discount;
                  String? disType = (storeController.store!.discount != null
                      && DateConverter.isAvailable(storeController.store!.discount!.startTime, storeController.store!.discount!.endTime))
                      ? 'percent' : cartModel.item!.discountType;
                  discount = discount! + ((cartModel.price! - PriceConverter.convertWithDiscount(cartModel.price, dis, disType)!) * cartModel.quantity!);
                }
                if (storeController.store != null && storeController.store!.discount != null) {
                  if (storeController.store!.discount!.maxDiscount != 0 && storeController.store!.discount!.maxDiscount! < discount!) {
                    discount = storeController.store!.discount!.maxDiscount;
                  }
                  if (storeController.store!.discount!.minPurchase != 0 && storeController.store!.discount!.minPurchase! > (price + addOns)) {
                    discount = 0;
                  }
                }
                subTotal = price + addOns;
                orderAmount = (price - discount!) + addOns - couponDiscount;
              }

              if (orderController.orderType == 'take_away' || (storeController.store != null && storeController.store!.freeDelivery!)
                  || (Get.find<SplashController>().configModel!.freeDeliveryOver != null && orderAmount
                      >= Get.find<SplashController>().configModel!.freeDeliveryOver!) || couponController.freeDelivery) {
                deliveryCharge = 0;
              }

              if(taxIncluded){
                tax = orderAmount * _taxPercent! /(100 + _taxPercent!);
              }else{
                tax = PriceConverter.calculation(orderAmount, _taxPercent, 'percent', 1);
              }
              double total = subTotal + deliveryCharge! - discount- couponDiscount + (taxIncluded ? 0 : tax) + orderController.tips;

              return (orderController.distance != null && locationController.addressList != null && storeController.store != null) ? Column(
                children: [

                  Expanded(child: Scrollbar(
                    controller: _scrollController,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? 0.0 : Dimensions.paddingSizeSmall),
                    child: FooterView(child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        widget.storeId != null ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('your_prescription'.tr, style: robotoMedium),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: storeController.pickedPrescriptions.length+1,
                              itemBuilder: (context, index) {
                                XFile? file = index == storeController.pickedPrescriptions.length ? null : storeController.pickedPrescriptions[index];
                                if(index == storeController.pickedPrescriptions.length) {
                                  return InkWell(
                                    onTap: () => Get.bottomSheet(const CameraButtonSheet()),
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
                                        onTap: () => storeController.removePrescriptionImage(index),
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
                        ]) : const SizedBox(),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        // Order type
                        Text('delivery_option'.tr, style: robotoMedium),
                        widget.storeId != null ? DeliveryOptionButton(
                          value: 'delivery', title: 'home_delivery'.tr, charge: charge, isFree: storeController.store!.freeDelivery,
                        ) : Column(children: [
                          storeController.store!.delivery! ? DeliveryOptionButton(
                            value: 'delivery', title: 'home_delivery'.tr, charge: charge, isFree: storeController.store!.freeDelivery,
                          ) : const SizedBox(),
                          storeController.store!.takeAway! ? DeliveryOptionButton(
                            value: 'take_away', title: 'take_away'.tr, charge: deliveryCharge, isFree: true,
                          ) : const SizedBox(),
                        ]),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        orderController.orderType != 'take_away' ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('deliver_to'.tr, style: robotoMedium),
                            TextButton.icon(
                              onPressed: () async {
                                var address = await Get.toNamed(RouteHelper.getAddAddressRoute(true, false, storeController.store!.zoneId));
                                if(address != null) {
                                  if(storeController.store!.selfDeliverySystem == 0) {
                                    orderController.getDistanceInKM(
                                      LatLng(double.parse(address.latitude), double.parse(address.longitude)),
                                      LatLng(double.parse(storeController.store!.latitude!), double.parse(storeController.store!.longitude!)),
                                    );
                                  }
                                  _streetNumberController.text = address.streetNumber ?? '';
                                  _doorBellController.text = address.doorBell ?? '';
                                  _houseController.text = address.house ?? '';
                                  _floorController.text = address.floor ?? '';
                                }
                              },
                              icon: const Icon(Icons.add, size: 20),
                              label: Text('add'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                            ),
                          ]),

                          DropdownButton(
                            value: orderController.addressIndex,
                            items: addressList,
                            itemHeight: ResponsiveHelper.isMobile(context) ? 70 : 85, elevation: 0, iconSize: 30, underline: const SizedBox(),
                            onChanged: (int? index) {
                              if(storeController.store!.selfDeliverySystem == 0) {
                                orderController.getDistanceInKM(
                                  LatLng(
                                    double.parse(index == -1 ? locationController.getUserAddress()!.latitude! : locationController.addressList![index!].latitude!),
                                    double.parse(index == -1 ? locationController.getUserAddress()!.longitude! : locationController.addressList![index!].longitude!),
                                  ),
                                  LatLng(double.parse(storeController.store!.latitude!), double.parse(storeController.store!.longitude!)),
                                );
                              }
                              orderController.setAddressIndex(index);

                              _streetNumberController.text = orderController.addressIndex == -1 ? locationController.getUserAddress()!.streetNumber ?? '' : locationController.addressList![orderController.addressIndex!].streetNumber ?? '';
                              _doorBellController.text = orderController.addressIndex == -1 ? locationController.getUserAddress()!.doorBell ?? '' : locationController.addressList![orderController.addressIndex!].doorBell ?? '';
                              _houseController.text = orderController.addressIndex == -1 ? locationController.getUserAddress()!.house ?? '' : locationController.addressList![orderController.addressIndex!].house ?? '';
                              _floorController.text = orderController.addressIndex == -1 ? locationController.getUserAddress()!.floor ?? '' : locationController.addressList![orderController.addressIndex!].floor ?? '';
                            },
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          Text(
                            'street_number'.tr,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          MyTextField(
                            hintText: 'street_number'.tr,
                            inputType: TextInputType.streetAddress,
                            focusNode: _streetNode,
                            nextFocus: _houseNode,
                            controller: _streetNumberController,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          Text(
                            '${'house'.tr} / ${'floor'.tr} ${'number'.tr}',
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Row(
                            children: [
                              Expanded(
                                child: MyTextField(
                                  hintText: 'house'.tr,
                                  inputType: TextInputType.text,
                                  focusNode: _houseNode,
                                  nextFocus: _floorNode,
                                  controller: _houseController,
                                ),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              Expanded(
                                child: MyTextField(
                                  hintText: 'floor'.tr,
                                  inputType: TextInputType.text,
                                  focusNode: _floorNode,
                                  inputAction: TextInputAction.done,
                                  controller: _floorController,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          Text(
                            'doorbell'.tr,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          MyTextField(
                            hintText: 'doorbell'.tr,
                            inputType: TextInputType.streetAddress,
                            focusNode: _doorbellNode,
                            nextFocus: _doorbellNode,
                            controller: _doorBellController,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                        ]) : const SizedBox(),

                        // Time Slot
                        widget.storeId == null && storeController.store!.scheduleOrder! ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('preference_time'.tr, style: robotoMedium),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          SizedBox(
                            height: 50,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount: 2,
                              itemBuilder: (context, index) {
                                return SlotWidget(
                                  title: index == 0 ? 'today'.tr : 'tomorrow'.tr,
                                  isSelected: orderController.selectedDateSlot == index,
                                  onTap: () => orderController.updateDateSlot(index, storeController.store!.orderPlaceToScheduleInterval),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          SizedBox(
                            height: 50,
                            child: ((orderController.selectedDateSlot == 0 && todayClosed)
                            || (orderController.selectedDateSlot == 1 && tomorrowClosed))
                            ? Center(child: Text(module!.showRestaurantText!
                            ? 'restaurant_is_closed'.tr : 'store_is_closed'.tr)) : orderController.timeSlots != null
                            ? orderController.timeSlots!.isNotEmpty ? ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount: orderController.timeSlots!.length,
                              itemBuilder: (context, index) {
                                return SlotWidget(
                                  title: (index == 0 && orderController.selectedDateSlot == 0
                                      && storeController.isStoreOpenNow(storeController.store!.active!, storeController.store!.schedules)
                                      && (module!.orderPlaceToScheduleInterval! ? storeController.store!.orderPlaceToScheduleInterval == 0 : true))
                                      ? 'now'.tr : '${DateConverter.dateToTimeOnly(orderController.timeSlots![index].startTime!)} '
                                      '- ${DateConverter.dateToTimeOnly(orderController.timeSlots![index].endTime!)}',
                                  isSelected: orderController.selectedTimeSlot == index,
                                  onTap: () => orderController.updateTimeSlot(index),
                                );
                              },
                            ) : Center(child: Text('no_slot_available'.tr)) : const Center(child: CircularProgressIndicator()),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                        ]) : const SizedBox(),

                        // Coupon
                        widget.storeId == null ? GetBuilder<CouponController>(
                          builder: (couponController) {
                            return Container(
                              color: Theme.of(context).cardColor,
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                              child: Column(children: [

                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text('promo_code'.tr, style: robotoMedium),
                                  InkWell(
                                    onTap: () {
                                      Get.toNamed(RouteHelper.getCouponRoute(fromCheckout: true))!.then((value) => _couponController.text = value.toString());
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(children: [
                                        Text('add_voucher'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
                                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                        Icon(Icons.add, size: 20, color: Theme.of(context).primaryColor),
                                      ]),
                                    ),
                                  )
                                ]),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    border: Border.all(color: Theme.of(context).primaryColor),
                                  ),
                                  child: Row(children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 50,
                                        child: TextField(
                                          controller: _couponController,
                                          style: robotoRegular.copyWith(height: ResponsiveHelper.isMobile(context) ? null : 2),
                                          decoration: InputDecoration(
                                            hintText: 'enter_promo_code'.tr,
                                            hintStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                                            isDense: true,
                                            filled: true,
                                            enabled: couponController.discount == 0,
                                            fillColor: Theme.of(context).cardColor,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.horizontal(
                                                left: Radius.circular(Get.find<LocalizationController>().isLtr ? 10 : 0),
                                                right: Radius.circular(Get.find<LocalizationController>().isLtr ? 0 : 10),
                                              ),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        String couponCode = _couponController.text.trim();
                                        if(couponController.discount! < 1 && !couponController.freeDelivery) {
                                          if(couponCode.isNotEmpty && !couponController.isLoading) {
                                            couponController.applyCoupon(couponCode, (price-discount!)+addOns, deliveryCharge,
                                                storeController.store!.id).then((discount) {
                                              if (discount! > 0) {
                                                showCustomSnackBar(
                                                  '${'you_got_discount_of'.tr} ${PriceConverter.convertPrice(discount)}',
                                                  isError: false,
                                                );
                                              }
                                            });
                                          } else if(couponCode.isEmpty) {
                                            showCustomSnackBar('enter_a_coupon_code'.tr);
                                          }
                                        } else {
                                          couponController.removeCouponData(true);
                                        }
                                      },
                                      child: Container(
                                        height: 50, width: 100,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          // boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200], spreadRadius: 1, blurRadius: 5)],
                                          borderRadius: BorderRadius.horizontal(
                                            left: Radius.circular(Get.find<LocalizationController>().isLtr ? 0 : 10),
                                            right: Radius.circular(Get.find<LocalizationController>().isLtr ? 10 : 0),
                                          ),
                                        ),
                                        child: (couponController.discount! <= 0 && !couponController.freeDelivery) ? !couponController.isLoading ? Text(
                                          'apply'.tr,
                                          style: robotoMedium.copyWith(color: Theme.of(context).cardColor),
                                        ) : const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                                            : const Icon(Icons.clear, color: Colors.white),
                                      ),
                                    ),
                                  ]),
                                ),
                                const SizedBox(height: Dimensions.paddingSizeLarge),

                              ]),
                            );
                          },
                        ) : const SizedBox(),
                        SizedBox(height: widget.storeId == null ? Dimensions.paddingSizeLarge : 0),

                        ( widget.storeId == null && orderController.orderType != 'take_away' && Get.find<SplashController>().configModel!.dmTipsStatus == 1) ?
                        Container(
                          color: Theme.of(context).cardColor,
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge, horizontal: Dimensions.paddingSizeSmall),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                            Text('delivery_man_tips'.tr, style: robotoMedium),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                border: Border.all(color: Theme.of(context).primaryColor),
                              ),
                              child: TextField(
                                controller: _tipController,
                                onChanged: (String value) {
                                  if(value.isNotEmpty){
                                    orderController.addTips(double.parse(value));
                                  }else{
                                    orderController.addTips(0.0);
                                  }
                                },
                                maxLength: 10,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                                decoration: InputDecoration(
                                  hintText: 'enter_amount'.tr,
                                  counterText: '',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeDefault),

                            SizedBox(
                              height: 55,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: AppConstants.tips.length,
                                itemBuilder: (context, index) {
                                  return TipsWidget(
                                    title: AppConstants.tips[index].toString(),
                                    isSelected: orderController.selectedTips == index,
                                    onTap: () {
                                      orderController.updateTips(index);
                                      orderController.addTips(AppConstants.tips[index].toDouble());
                                      _tipController.text = orderController.tips.toString();
                                    },
                                  );
                                },
                              ),
                            ),
                          ]),
                        ) : const SizedBox.shrink(),
                        SizedBox(height: (orderController.orderType != 'take_away'
                            && Get.find<SplashController>().configModel!.dmTipsStatus == 1) ? Dimensions.paddingSizeExtraSmall : 0),


                        Text('choose_payment_method'.tr, style: robotoMedium),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        _isCashOnDeliveryActive! ? PaymentButton(
                          icon: Images.cashOnDelivery,
                          title: 'cash_on_delivery'.tr,
                          subtitle: 'pay_your_payment_after_getting_item'.tr,
                          isSelected: orderController.paymentMethodIndex == 0,
                          onTap: () => orderController.setPaymentMethod(0),
                        ) : const SizedBox(),

                        // widget.storeId == null && _isDigitalPaymentActive! ? PaymentButton(
                        //   icon: Images.digitalPayment,
                        //   title: 'digital_payment'.tr,
                        //   subtitle: 'faster_and_safe_way'.tr,
                        //   isSelected: orderController.paymentMethodIndex == 1,
                        //   onTap: () => orderController.setPaymentMethod(1),
                        // ) : const SizedBox(),

                        widget.storeId == null && _isPaypalPaymentActive! ?  PaymentButton(
                          isSelected: orderController.paymentMethodIndex == 1,
                          icon: Images.paypal_colour,
                          title: 'Paypal'.tr,
                          subtitle: 'pay with paypal'.tr,
                          onTap: () => orderController.setPaymentMethod(1),
                        ) : const SizedBox(),

                        widget.storeId == null && _isWalletActive ?  PaymentButton(
                          icon: Images.wallet,
                          title: 'wallet_payment'.tr,
                          subtitle: 'pay_from_your_existing_balance'.tr,
                          isSelected: orderController.paymentMethodIndex == 2,
                          onTap: () => orderController.setPaymentMethod(2),
                        )  : const SizedBox(),

                        widget.storeId == null && _isStripePaymentActive! ?  PaymentButton(
                            isSelected: orderController.paymentMethodIndex == 3,
                            icon: Images.debitcard,
                            title: 'stripe'.tr,
                            subtitle: 'pay witripe'.tr,
                          onTap: () => orderController.setPaymentMethod(3),
                        ) : const SizedBox(),


                        widget.storeId == null && _isOtpPaymentActive! ?  PaymentButton(
                            isSelected: orderController.paymentMethodIndex == 4,
                            icon: Images.otpbank,
                            title: 'otp'.tr,
                            subtitle: 'otp_desc'.tr,
                          onTap: () => orderController.setPaymentMethod(4),
                        ) : const SizedBox(),


                        widget.storeId == null && _isKhPaymentActive! ?  PaymentButton(
                            isSelected: orderController.paymentMethodIndex == 5,
                            icon: Images.kh,
                            title: 'kh'.tr,
                            subtitle: 'kh_desc'.tr,
                          onTap: () => orderController.setPaymentMethod(5),
                        ) : const SizedBox(),

                         widget.storeId == null && _isMbhPaymentActive! ?  PaymentButton(
                            isSelected: orderController.paymentMethodIndex == 6,
                            icon: Images.mkb,
                            title: 'mbh'.tr,
                            subtitle: 'mbh_desc'.tr,
                          onTap: () => orderController.setPaymentMethod(6),
                        ) : const SizedBox(),
                        Row(
                          children: [
                            Text('techss'.tr),
                          SizedBox(
                              height: 100,
                              width: 100,
                              child: Image.asset(Images.bb)),
                          ],
                        ),


                        CustomTextField(
                          controller: _noteController,
                          hintText: 'additional_note'.tr,
                          maxLines: 3,
                          inputType: TextInputType.multiline,
                          inputAction: TextInputAction.newline,
                          capitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        widget.storeId == null && Get.find<SplashController>().configModel!.moduleConfig!.module!.orderAttachment! ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text('prescription'.tr, style: robotoMedium),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                              Text(
                                '(${'max_size_2_mb'.tr})',
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ]),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            ImagePickerWidget(
                              image: '', rawFile: orderController.rawAttachment,
                              onTap: () => orderController.pickImage(),
                            ),
                          ],
                        ) : const SizedBox(),

                        widget.storeId == null ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(module!.addOn! ? 'subtotal'.tr : 'item_price'.tr, style: robotoMedium),
                          Text(PriceConverter.convertPrice(subTotal), style: robotoMedium, textDirection: TextDirection.ltr),
                        ]) : const SizedBox(),
                        SizedBox(height: widget.storeId == null ? Dimensions.paddingSizeSmall : 0),

                        widget.storeId == null ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('discount'.tr, style: robotoRegular),
                          Text('(-) ${PriceConverter.convertPrice(discount)}', style: robotoRegular, textDirection: TextDirection.ltr),
                        ]) : const SizedBox(),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        (couponController.discount! > 0 || couponController.freeDelivery) ? Column(children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('coupon_discount'.tr, style: robotoRegular),
                            (couponController.coupon != null && couponController.coupon!.couponType == 'free_delivery') ? Text(
                              'free_delivery'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor),
                            ) : Text(
                              '(-) ${PriceConverter.convertPrice(couponController.discount)}',
                              style: robotoRegular, textDirection: TextDirection.ltr,
                            ),
                          ]),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                        ]) : const SizedBox(),
                        widget.storeId == null ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('${'vat_tax'.tr} ${taxIncluded ? 'tax_included'.tr : ''}', style: robotoRegular),
                          Text((taxIncluded ? '' : '(+) ') + PriceConverter.convertPrice(tax), style: robotoRegular, textDirection: TextDirection.ltr),
                        ]) : const SizedBox(),
                        SizedBox(height: widget.storeId == null ? Dimensions.paddingSizeSmall : 0),

                        (widget.storeId == null && Get.find<SplashController>().configModel!.dmTipsStatus == 1) ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('delivery_man_tips'.tr, style: robotoRegular),
                            Text('(+) ${PriceConverter.convertPrice(orderController.tips)}', style: robotoRegular, textDirection: TextDirection.ltr),
                          ],
                        ) : const SizedBox.shrink(),
                        SizedBox(height: Get.find<SplashController>().configModel!.dmTipsStatus == 1 ? Dimensions.paddingSizeSmall : 0.0),

                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('delivery_fee'.tr, style: robotoRegular),
                          deliveryCharge == -1 ? Text(
                            'calculating'.tr, style: robotoRegular.copyWith(color: Colors.red),
                          ) : (deliveryCharge == 0 || (couponController.coupon != null && couponController.coupon!.couponType == 'free_delivery')) ? Text(
                            'free'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor),
                          ) : Text(
                            '(+) ${PriceConverter.convertPrice(deliveryCharge)}', style: robotoRegular, textDirection: TextDirection.ltr,
                          ),
                        ]),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                          child: Divider(thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5)),
                        ),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(
                            'total_amount'.tr,
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                          ),
                          Text(
                            PriceConverter.convertPrice(total), textDirection: TextDirection.ltr,
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                          ),
                        ]),

                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        CheckoutCondition(orderController: orderController, parcelController: Get.find<ParcelController>()),

                        ResponsiveHelper.isDesktop(context) ? Padding(
                          padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                          child: _orderPlaceButton(
                            orderController, storeController, locationController, todayClosed, tomorrowClosed, orderAmount, deliveryCharge, tax, discount, total, maxCodOrderAmount,
                          ),
                        ) : const SizedBox(),

                      ]),
                    )),
                  ))),

                  ResponsiveHelper.isDesktop(context) ? const SizedBox() : _orderPlaceButton(
                    orderController, storeController, locationController, todayClosed, tomorrowClosed, orderAmount, deliveryCharge, tax, discount, total, maxCodOrderAmount
                  ),

                ],
              ) : const Center(child: CircularProgressIndicator());
            });
          });
        });
      }) : const NotLoggedInScreen(),
    );
  }

  Future<void> stripepayment(OrderController orderController,PlaceOrderBody placeOrderBody,int? zoneID, Function(bool isSuccess, String? message, String orderID, int? zoneID, double amount, double? maximumCodOrderAmount) callback, double amount, double? maximumCodOrderAmount,
      StoreController storeController, AddressModel address,double discount,double tax,DateTime scheduleEndDate,List<Cart> carts,double payamount) async {
   try{

     String payamountString = payamount.toString(); // Convert double to string
     String amountWithoutCommas = payamountString.replaceAll(',', ''); // Remove commas from payamountString
     String amountWithoutDecimal = amountWithoutCommas.replaceAll(RegExp(r'\.0*$'), '');
     Map<String,dynamic> body = {
        'amount' :amountWithoutDecimal.toString(), //100
        'currency' : "HUF",
      };


      http.Response response = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
          headers: {
    'Authorization': 'Bearer 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',
    'Content-Type': 'application/x-www-form-urlencoded'
    },
           body: body,
           );
    stripepaymentIntent = json.decode(response.body);
      }catch (error){
     throw Exception(error.toString());
      }
   var gpay = const PaymentSheetGooglePay(merchantCountryCode: "HU",
       currencyCode: "HUF",
       testEnv: true);

      await Stripe.instance.initPaymentSheet(paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: stripepaymentIntent!['client_secret'],
        style: ThemeMode.light,
        merchantDisplayName: 'Marwa',
        googlePay: gpay,
        applePay:const PaymentSheetApplePay(merchantCountryCode: 'HU'),
        billingDetails: const BillingDetails(address: Address(city: 'city', country: 'HU', line1: 'line1', line2: 'line2', postalCode: 'postalCode', state: 'state')),
      ),).then((value) => {});
   try{
     await Stripe.instance.presentPaymentSheet().then((value) => {

     orderController.placeOrder(PlaceOrderBody(
     cart: carts, couponDiscountAmount: Get.find<CouponController>().discount, distance: orderController.distance,
     scheduleAt: !storeController.store!.scheduleOrder! ? null : (orderController.selectedDateSlot == 0
     && orderController.selectedTimeSlot == 0) ? null : DateConverter.dateToDateAndTime(scheduleEndDate),
     orderAmount: amount, orderNote: _noteController.text, orderType: orderController.orderType,
     paymentMethod:'stripe',
     couponCode: (Get.find<CouponController>().discount! > 0 || (Get.find<CouponController>().coupon != null
     && Get.find<CouponController>().freeDelivery)) ? Get.find<CouponController>().coupon!.code : null,
     storeId: _cartList![0]!.item!.storeId,
     address: address.address, latitude: address.latitude, longitude: address.longitude, addressType: address.addressType,
     contactPersonName: address.contactPersonName ?? '${Get.find<UserController>().userInfoModel!.fName} '
     '${Get.find<UserController>().userInfoModel!.lName}',
     contactPersonNumber: address.contactPersonNumber ?? Get.find<UserController>().userInfoModel!.phone,
     streetNumber: _streetNumberController.text.trim(), house: _houseController.text.trim(), floor: _floorController.text.trim(),
     doorbell: _doorBellController.text.trim(),
     discountAmount: discount, taxAmount: tax, receiverDetails: null, parcelCategoryId: null,
     chargePayer: null, dmTips: _tipController.text.trim(),platform: platform!
     ), zoneID, _callback, amount, maximumCodOrderAmount,)

     });
   }catch(error){
     throw Exception(error.toString());
   }
  }

  void _callback(bool isSuccess, String? message, String orderID, int? zoneID, double amount, double? maximumCodOrderAmount) async {
    if(isSuccess) {
      if(widget.fromCart) {
        Get.find<CartController>().clearCartList();
      }
      if(!Get.find<OrderController>().showBottomSheet){
        Get.find<OrderController>().showRunningOrders();
      }
      Get.find<OrderController>().stopLoader();
      HomeScreen.loadData(true);
      if(Get.find<OrderController>().paymentMethodIndex == 1) {
        if(GetPlatform.isWeb) {
          Get.back();
          String? hostname = html.window.location.hostname;
          String protocol = html.window.location.protocol;
          String selectedUrl = '${AppConstants.baseUrl}/payment-mobile/paypal?order_id=$orderID&&customer_id=${Get.find<UserController>()
              .userInfoModel!.id}&&callback=$protocol//$hostname${RouteHelper.orderSuccess}?id=$orderID&status=';
          html.window.open(selectedUrl,"_self");
        } else{
          Get.offNamed(RouteHelper.getPaymentRoute(
            orderID, Get.find<UserController>().userInfoModel!.id, Get.find<OrderController>().orderType, amount, _isCashOnDeliveryActive,'paypal'
          ));
        }
      }
      else if(Get.find<OrderController>().paymentMethodIndex == 4){
        if(GetPlatform.isWeb) {
          Get.back();
          String? hostname = html.window.location.hostname;
          String protocol = html.window.location.protocol;
          String selectedUrl = '${AppConstants.baseUrl}/payment-mobile/otp?order_id=$orderID&&customer_id=${Get.find<UserController>()
              .userInfoModel!.id}&&callback=$protocol//$hostname${RouteHelper.orderSuccess}?id=$orderID&status=';
          html.window.open(selectedUrl,"_self");
        } else{
          Get.offNamed(RouteHelper.getPaymentRoute(
              orderID, Get.find<UserController>().userInfoModel!.id, Get.find<OrderController>().orderType, amount, _isCashOnDeliveryActive,'otp'
          ));
        }
      }
      else if(Get.find<OrderController>().paymentMethodIndex == 5){
        if(GetPlatform.isWeb) {
          Get.back();
          String? hostname = html.window.location.hostname;
          String protocol = html.window.location.protocol;
          String selectedUrl = '${AppConstants.baseUrl}/payment-mobile/kh?order_id=$orderID&&customer_id=${Get.find<UserController>()
              .userInfoModel!.id}&&callback=$protocol//$hostname${RouteHelper.orderSuccess}?id=$orderID&status=';
          html.window.open(selectedUrl,"_self");
        } else{
          Get.offNamed(RouteHelper.getPaymentRoute(
              orderID, Get.find<UserController>().userInfoModel!.id, Get.find<OrderController>().orderType, amount, _isCashOnDeliveryActive,'kh'
          ));
        }
      }
      else if(Get.find<OrderController>().paymentMethodIndex == 6){
        if(GetPlatform.isWeb) {
          Get.back();
          String? hostname = html.window.location.hostname;
          String protocol = html.window.location.protocol;
          String selectedUrl = '${AppConstants.baseUrl}/payment-mobile/mbh?order_id=$orderID&&customer_id=${Get.find<UserController>()
              .userInfoModel!.id}&&callback=$protocol//$hostname${RouteHelper.orderSuccess}?id=$orderID&status=';
          html.window.open(selectedUrl,"_self");
        } else{
          Get.offNamed(RouteHelper.getPaymentRoute(
              orderID, Get.find<UserController>().userInfoModel!.id, Get.find<OrderController>().orderType, amount, _isCashOnDeliveryActive,'mbh'
          ));
        }
      }
      else if(Get.find<OrderController>().paymentMethodIndex == 3 ){
        if(GetPlatform.isWeb) {
          Get.back();
          String? hostname = html.window.location.hostname;
          String protocol = html.window.location.protocol;
          String selectedUrl = '${AppConstants.baseUrl}/payment-mobile/stripe?order_id=$orderID&&customer_id=${Get.find<UserController>()
              .userInfoModel!.id}&&callback=$protocol//$hostname${RouteHelper.orderSuccess}?id=$orderID&status=';
          html.window.open(selectedUrl,"_self");
        } else{
          Get.offNamed(RouteHelper.getOrderSuccessRoute(orderID));
        }
      }

      else {
        Get.offNamed(RouteHelper.getOrderSuccessRoute(orderID));
      }
      Get.find<OrderController>().clearPrevData(zoneID);
      Get.find<CouponController>().removeCouponData(false);
      Get.find<OrderController>().updateTips(-1, notify: false);
    }else {
      showCustomSnackBar(message);
    }
  }






  Widget _orderPlaceButton(OrderController orderController, StoreController storeController, LocationController locationController, bool todayClosed, bool tomorrowClosed,
      double orderAmount, double? deliveryCharge, double tax, double? discount, double total, double? maxCodOrderAmount) {
    return Container(
      width: Dimensions.webMaxWidth,
      alignment: Alignment.center,
      padding: ResponsiveHelper.isDesktop(context) ? null : const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: !orderController.isLoading ? CustomButton(buttonText: 'confirm_order'.tr, onPressed: orderController.acceptTerms ? () {
        bool isAvailable = true;
        DateTime scheduleStartDate = DateTime.now();
        DateTime scheduleEndDate = DateTime.now();
        if(orderController.timeSlots == null || orderController.timeSlots!.isEmpty) {
          isAvailable = false;
        }else {
          DateTime date = orderController.selectedDateSlot == 0 ? DateTime.now() : DateTime.now().add(const Duration(days: 1));
          DateTime startTime = orderController.timeSlots![orderController.selectedTimeSlot].startTime!;
          DateTime endTime = orderController.timeSlots![orderController.selectedTimeSlot].endTime!;
          scheduleStartDate = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute+1);
          scheduleEndDate = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute+1);
          if(_cartList != null){
            for (CartModel? cart in _cartList!) {
              if (!DateConverter.isAvailable(
                cart!.item!.availableTimeStarts, cart.item!.availableTimeEnds,
                time: storeController.store!.scheduleOrder! ? scheduleStartDate : null,
              ) && !DateConverter.isAvailable(
                cart.item!.availableTimeStarts, cart.item!.availableTimeEnds,
                time: storeController.store!.scheduleOrder! ? scheduleEndDate : null,
              )) {
                isAvailable = false;
                break;
              }
            }
          }
        }
        if(!_isCashOnDeliveryActive! && !_isDigitalPaymentActive! && !_isWalletActive) {
          showCustomSnackBar('no_payment_method_is_enabled'.tr);
        }else if(orderAmount < storeController.store!.minimumOrder!) {
          showCustomSnackBar('${'minimum_order_amount_is'.tr} ${storeController.store!.minimumOrder}');
        }else if((orderController.selectedDateSlot == 0 && todayClosed) || (orderController.selectedDateSlot == 1 && tomorrowClosed)) {
          showCustomSnackBar(Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
              ? 'restaurant_is_closed'.tr : 'store_is_closed'.tr);
        }else if(orderController.paymentMethodIndex == 0 && _isCashOnDeliveryActive! && maxCodOrderAmount != null && maxCodOrderAmount != 0 && (total > maxCodOrderAmount) && widget.storeId == null){
          showCustomSnackBar('${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
        }else if (orderController.timeSlots == null || orderController.timeSlots!.isEmpty) {
          if(storeController.store!.scheduleOrder!) {
            showCustomSnackBar('select_a_time'.tr);
          }else {
            showCustomSnackBar(Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                ? 'restaurant_is_closed'.tr : 'store_is_closed'.tr);
          }
        }else if (!isAvailable) {
          showCustomSnackBar('one_or_more_products_are_not_available_for_this_selected_time'.tr);
        }else if (orderController.orderType != 'take_away' && orderController.distance == -1 && deliveryCharge == -1) {
          showCustomSnackBar('delivery_fee_not_set_yet'.tr);
        }else if (widget.storeId != null && storeController.pickedPrescriptions.isEmpty) {
          showCustomSnackBar('please_upload_your_prescription_images'.tr);
        }else if (!orderController.acceptTerms) {
          showCustomSnackBar('please_accept_privacy_policy_trams_conditions_refund_policy_first'.tr);
        }
        else {

          AddressModel? address = orderController.addressIndex == -1 ? Get.find<LocationController>().getUserAddress()
              : locationController.addressList![orderController.addressIndex!];

          if(widget.storeId == null){
            List<Cart> carts = [];
            for (int index = 0; index < _cartList!.length; index++) {
              CartModel cart = _cartList![index]!;
              List<int?> addOnIdList = [];
              List<int?> addOnQtyList = [];
              for (var addOn in cart.addOnIds!) {
                addOnIdList.add(addOn.id);
                addOnQtyList.add(addOn.quantity);
              }

              List<OrderVariation> variations = [];
              if(Get.find<SplashController>().getModuleConfig(cart.item!.moduleType).newVariation!) {
                for(int i=0; i<cart.item!.foodVariations!.length; i++) {
                  if(cart.foodVariations![i].contains(true)) {
                    variations.add(OrderVariation(name: cart.item!.foodVariations![i].name, values: OrderVariationValue(label: [])));
                    for(int j=0; j<cart.item!.foodVariations![i].variationValues!.length; j++) {
                      if(cart.foodVariations![i][j]!) {
                        variations[variations.length-1].values!.label!.add(cart.item!.foodVariations![i].variationValues![j].level);
                      }
                    }
                  }
                }
              }
              carts.add(Cart(
                cart.isCampaign! ? null : cart.item!.id, cart.isCampaign! ? cart.item!.id : null,
                cart.discountedPrice.toString(), '',
                Get.find<SplashController>().getModuleConfig(cart.item!.moduleType).newVariation! ? null : cart.variation,
                Get.find<SplashController>().getModuleConfig(cart.item!.moduleType).newVariation! ? variations : null,
                cart.quantity, addOnIdList, cart.addOns, addOnQtyList,
              ));
            }

            if(orderController.paymentMethodIndex == 3 && !GetPlatform.isWeb){
                 orderController.stripecheck(PlaceOrderBody(
                   cart: carts, couponDiscountAmount: Get.find<CouponController>().discount, distance: orderController.distance,
                   scheduleAt: !storeController.store!.scheduleOrder! ? null : (orderController.selectedDateSlot == 0
                       && orderController.selectedTimeSlot == 0) ? null : DateConverter.dateToDateAndTime(scheduleEndDate),
                   orderAmount: total, orderNote: _noteController.text, orderType: orderController.orderType,
                   paymentMethod: orderController.paymentMethodIndex == 0 ? 'cash_on_delivery'
                       : orderController.paymentMethodIndex == 1 ? 'digital_payment' : orderController.paymentMethodIndex == 2 ? 'wallet' : 'stripe',
                   couponCode: (Get.find<CouponController>().discount! > 0 || (Get.find<CouponController>().coupon != null
                       && Get.find<CouponController>().freeDelivery)) ? Get.find<CouponController>().coupon!.code : null,
                   storeId: _cartList![0]!.item!.storeId,
                   address: address!.address, latitude: address.latitude, longitude: address.longitude, addressType: address.addressType,
                   contactPersonName: address.contactPersonName ?? '${Get.find<UserController>().userInfoModel!.fName} '
                       '${Get.find<UserController>().userInfoModel!.lName}',
                   contactPersonNumber: address.contactPersonNumber ?? Get.find<UserController>().userInfoModel!.phone,
                   streetNumber: _streetNumberController.text.trim(),doorbell: _doorBellController.text.trim(), house: _houseController.text.trim(), floor: _floorController.text.trim(),
                   discountAmount: discount, taxAmount: tax, receiverDetails: null, parcelCategoryId: null,
                   chargePayer: null, dmTips: _tipController.text.trim(),platform: platform!
                 ), storeController.store!.zoneId, total, maxCodOrderAmount).then((value) => {
                    if(value!.isSuccess){
                     stripepayment(orderController, PlaceOrderBody(
                       cart: carts, couponDiscountAmount: Get.find<CouponController>().discount, distance: orderController.distance,
                       scheduleAt: !storeController.store!.scheduleOrder! ? null : (orderController.selectedDateSlot == 0
                           && orderController.selectedTimeSlot == 0) ? null : DateConverter.dateToDateAndTime(scheduleEndDate),
                       orderAmount: total, orderNote: _noteController.text, orderType: orderController.orderType,
                       paymentMethod: orderController.paymentMethodIndex == 0 ? 'cash_on_delivery'
                           : orderController.paymentMethodIndex == 1 ? 'digital_payment' : orderController.paymentMethodIndex == 2 ? 'wallet' : 'stripe',
                       couponCode: (Get.find<CouponController>().discount! > 0 || (Get.find<CouponController>().coupon != null
                           && Get.find<CouponController>().freeDelivery)) ? Get.find<CouponController>().coupon!.code : null,
                       storeId: _cartList![0]!.item!.storeId,
                       address: address.address, latitude: address.latitude, longitude: address.longitude, addressType: address.addressType,
                       contactPersonName: address.contactPersonName ?? '${Get.find<UserController>().userInfoModel!.fName} '
                           '${Get.find<UserController>().userInfoModel!.lName}',
                       contactPersonNumber: address.contactPersonNumber ?? Get.find<UserController>().userInfoModel!.phone,
                       streetNumber: _streetNumberController.text.trim(),
                       doorbell: _doorBellController.text.trim(),
                       house: _houseController.text.trim(), floor: _floorController.text.trim(),
                       discountAmount: discount, taxAmount: tax, receiverDetails: null, parcelCategoryId: null,
                       chargePayer: null, dmTips: _tipController.text.trim(),platform: platform!
                     ), storeController.store!.zoneId, _callback, total, maxCodOrderAmount, storeController, address, discount!, tax, scheduleEndDate, carts,total*100)

                     }else{
                     showCustomSnackBar(value.message)

            }
                 });



            }else{
              orderController.placeOrder(PlaceOrderBody(
                cart: carts, couponDiscountAmount: Get.find<CouponController>().discount, distance: orderController.distance,
                scheduleAt: !storeController.store!.scheduleOrder! ? null : (orderController.selectedDateSlot == 0
                    && orderController.selectedTimeSlot == 0) ? null : DateConverter.dateToDateAndTime(scheduleEndDate),
                orderAmount: total, orderNote: _noteController.text, orderType: orderController.orderType,
                paymentMethod: orderController.paymentMethodIndex == 0 ? 'cash_on_delivery'
                    : orderController.paymentMethodIndex == 1 ? 'paypal' : orderController.paymentMethodIndex == 2 ? 'wallet' :
                orderController.paymentMethodIndex == 3 ?'stripe' : orderController.paymentMethodIndex == 4 ? 'otp' : orderController.paymentMethodIndex == 5 ? 'kh' : 'mbh',
                couponCode: (Get.find<CouponController>().discount! > 0 || (Get.find<CouponController>().coupon != null
                    && Get.find<CouponController>().freeDelivery)) ? Get.find<CouponController>().coupon!.code : null,
                storeId: _cartList![0]!.item!.storeId,
                address: address!.address, latitude: address.latitude, longitude: address.longitude, addressType: address.addressType,
                contactPersonName: address.contactPersonName ?? '${Get.find<UserController>().userInfoModel!.fName} '
                    '${Get.find<UserController>().userInfoModel!.lName}',
                contactPersonNumber: address.contactPersonNumber ?? Get.find<UserController>().userInfoModel!.phone,
                streetNumber: _streetNumberController.text.trim(), doorbell :_doorBellController.text.trim(),house: _houseController.text.trim(), floor: _floorController.text.trim(),
                discountAmount: discount, taxAmount: tax, receiverDetails: null, parcelCategoryId: null,
                chargePayer: null, dmTips: _tipController.text.trim(),platform: platform!
              ), storeController.store!.zoneId, _callback, total, maxCodOrderAmount);

            }

          }else{

            orderController.placePrescriptionOrder(widget.storeId, storeController.store!.zoneId, orderController.distance,
                address!.address!, address.longitude!, address.latitude!, _noteController.text, storeController.pickedPrescriptions, _callback, 0, 0
            );
          }

        }
      } : null) : const Center(child: CircularProgressIndicator()),
    );
  }

}
