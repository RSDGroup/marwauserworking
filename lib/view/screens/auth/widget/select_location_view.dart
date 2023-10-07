import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_text_field.dart';
import 'package:sixam_mart/view/screens/location/widget/location_search_dialog.dart';

class SelectLocationView extends StatefulWidget {
  final bool fromView;
  final GoogleMapController? mapController;
  const SelectLocationView({Key? key, required this.fromView, this.mapController}) : super(key: key);

  @override
  State<SelectLocationView> createState() => _SelectLocationViewState();
}

class _SelectLocationViewState extends State<SelectLocationView> {
  late CameraPosition _cameraPosition;
  final Set<Polygon> _polygons = HashSet<Polygon>();
  GoogleMapController? _mapController;
  GoogleMapController? _screenMapController;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      List<int> zoneIndexList = [];
      if(authController.zoneList != null && authController.zoneIds != null) {
        for(int index=0; index<authController.zoneList!.length; index++) {
          if(authController.zoneIds!.contains(authController.zoneList![index].id)) {
            zoneIndexList.add(index);
          }
        }
      }

      return SizedBox(width: Dimensions.webMaxWidth, child: Padding(
        padding: EdgeInsets.all(widget.fromView ? 0 : Dimensions.paddingSizeSmall),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            widget.fromView ? Center(
              child: Text(
                'set_your_store_location'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
              ),
            ) : const SizedBox(),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            InkWell(
              onTap: () async {
                var p = await Get.dialog(LocationSearchDialog(mapController: widget.fromView ? _mapController : _screenMapController));
                Position? position = p;
                if(position != null) {
                  _cameraPosition = CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 16);
                  if(!widget.fromView) {
                    widget.mapController!.moveCamera(CameraUpdate.newCameraPosition(_cameraPosition));
                    authController.setLocation(_cameraPosition.target);
                  }
                }
              },
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(color: Theme.of(context).disabledColor.withOpacity(0.5), borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                child: Row(children: [
                  Icon(Icons.location_on, size: 25, color: Theme.of(context).primaryColor),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Expanded(
                    child: GetBuilder<LocationController>(builder: (locationController) {
                      return Text(
                        locationController.pickAddress!.isEmpty ? 'search'.tr : locationController.pickAddress!,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge), maxLines: 1, overflow: TextOverflow.ellipsis,
                      );
                    }),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Icon(Icons.search, size: 25, color: Theme.of(context).textTheme.bodyLarge!.color),
                ]),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            authController.zoneList!.isNotEmpty ? Container(
              height: widget.fromView ? 200 : (context.height * 0.55),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                border: Border.all(width: 2, color: Theme.of(context).primaryColor),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                child: Stack(clipBehavior: Clip.none, children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lat ?? '0'),
                        double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lng ?? '0'),
                      ), zoom: 16,
                    ),
                    minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                    zoomControlsEnabled: true,
                    compassEnabled: false,
                    indoorViewEnabled: true,
                    mapToolbarEnabled: false,
                    myLocationEnabled: false,
                    zoomGesturesEnabled: true,
                    polygons: _polygons,
                    onCameraIdle: () {
                      authController.setLocation(_cameraPosition.target);
                      if(!widget.fromView) {
                        widget.mapController!.moveCamera(CameraUpdate.newCameraPosition(_cameraPosition));
                      }
                    },
                    onCameraMove: ((position) => _cameraPosition = position),
                    onMapCreated: (GoogleMapController controller) {
                      if(widget.fromView) {
                        _mapController = controller;
                      }else {
                        _screenMapController = controller;
                      }
                    },
                  ),
                  Center(child: Image.asset(Images.pickMarker, height: 50, width: 50)),
                  widget.fromView ? Positioned(
                    top: 10, right: 0,
                    child: InkWell(
                      onTap: () {
                        Get.to(Scaffold(
                            appBar: CustomAppBar(title: 'set_your_store_location'.tr),
                            body: SelectLocationView(fromView: false, mapController: _mapController)),
                        );
                      },
                      child: Container(
                        width: 30, height: 30,
                        margin: const EdgeInsets.only(right: Dimensions.paddingSizeLarge),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Colors.white),
                        child: Icon(Icons.fullscreen, color: Theme.of(context).primaryColor, size: 20),
                      ),
                    ),
                  ) : const SizedBox(),
                ]),
              ),
            ) : const SizedBox(),
            SizedBox(height: authController.zoneList!.isNotEmpty ? Dimensions.paddingSizeSmall : 0),
            authController.zoneList!.isNotEmpty ? Row(children: [
              Expanded(child: CustomTextField(
                hintText: 'latitude'.tr,
                controller: TextEditingController(
                  text: authController.restaurantLocation != null ? authController.restaurantLocation!.latitude.toString() : '',
                ),
                isEnabled: false,
                showTitle: true,
              )),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(child: CustomTextField(
                hintText: 'longitude'.tr,
                controller: TextEditingController(
                  text: authController.restaurantLocation != null ? authController.restaurantLocation!.longitude.toString() : '',
                ),
                isEnabled: false,
                showTitle: true,
              )),
            ]) : const SizedBox(),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Center(
              child: Text(
                'select_your_store_zone'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            authController.zoneIds != null ? Container(
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
                  // _polygons = HashSet();
                  // _polygons.add(Polygon(
                  //   polygonId: PolygonId("0"),
                  //   points: authController.zoneList[value].coordinates.coordinates,
                  //   fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  //   strokeColor: Theme.of(context).primaryColor,
                  //   strokeWidth: 1,
                  // ));
                  // Get.find<LocationController>().zoomToFit(_mapController, authController.zoneList[value].coordinates.coordinates);
                  authController.setZoneIndex(value);
                },
                isExpanded: true,
                underline: const SizedBox(),
              ),
            ) : Center(child: Text('service_not_available_in_this_area'.tr)),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            !widget.fromView ? CustomButton(
              buttonText: 'set_location'.tr,
              onPressed: () {
                widget.mapController!.moveCamera(CameraUpdate.newCameraPosition(_cameraPosition));
                Get.back();
              },
            ) : const SizedBox()

          ]),
        ),
      ));
    });
  }
}
