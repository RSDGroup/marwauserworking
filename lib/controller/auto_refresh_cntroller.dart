import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import "package:universal_html/html.dart" as html;

class CursorTimeoutController extends GetxController {
  RxBool _showPopup = false.obs;
  Timer? _cursorTimer;

  bool get showPopup => _showPopup.value;

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  void startTimer() {
    _cursorTimer?.cancel();
    _cursorTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.tick >= 60 && GetPlatform.isWeb) {
        _showPopup.value = true;
        Get.dialog(WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),

            alignment: Alignment.topRight,
            // icon: const Icon(
            //   Icons.timer,
            //   color: Colors.green,
            // ),
            title: Text(
              'refresh_popup_1'.tr,
              style: TextStyle(color: Colors.green),
            ),
            content: Text(
              'refresh_popup_2'.tr,
              textAlign: TextAlign.center,

            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only( bottom: 10),
                child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text('close'.tr, style: TextStyle(color: Colors.blue),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[100],
                  )
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15, bottom: 10),
                child: ElevatedButton(
                    onPressed: () {
                      if (GetPlatform.isWeb) {
                        html.window.location.reload();
                      }
                      Get.back();
                    },
                    child: Text('refresh'.tr)),
              ),

            ],
          ),
        ));
        _cursorTimer?.cancel();
      }
    });
  }

  void resetTimer() {
    _cursorTimer?.cancel();
    // _showPopup.value = false;
    startTimer();
  }

  @override
  void onClose() {
    _cursorTimer?.cancel();
    super.onClose();
  }
}
