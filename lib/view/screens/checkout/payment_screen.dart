import 'dart:async';
import 'dart:io';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/order_model.dart';
import 'package:sixam_mart/data/model/response/zone_response_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sixam_mart/view/screens/checkout/widget/payment_failed_dialog.dart';

import '../../../controller/order_controller.dart';

class PaymentScreen extends StatefulWidget {
  final OrderModel orderModel;
  final bool isCashOnDelivery;
  final String paymentMethod;
  const PaymentScreen({Key? key, required this.orderModel, required this.isCashOnDelivery, required this.paymentMethod}) : super(key: key);

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  late String selectedUrl;
  double value = 0.0;
  final bool _isLoading = true;
  PullToRefreshController? pullToRefreshController;
  late MyInAppBrowser browser;
  double? _maximumCodOrderAmount;

  @override
  void initState() {
    super.initState();
    selectedUrl = '${AppConstants.baseUrl}/payment-mobile/${widget.paymentMethod}/?customer_id=${widget.orderModel.userId}&order_id=${widget.orderModel.id}';

    _initData();
  }

  void _initData() async {
    for(ZoneData zData in Get.find<LocationController>().getUserAddress()!.zoneData!) {
      for(Modules m in zData.modules!) {
        if(m.id == Get.find<SplashController>().module!.id) {
          _maximumCodOrderAmount = m.pivot!.maximumCodOrderAmount;
          break;
        }
      }
    }

    browser = MyInAppBrowser(orderID: widget.orderModel.id.toString(), orderType: widget.orderModel.orderType, orderAmount: widget.orderModel.orderAmount, maxCodOrderAmount: _maximumCodOrderAmount, isCashOnDelivery: widget.isCashOnDelivery);

    if (Platform.isAndroid) {
      await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

      bool swAvailable = await AndroidWebViewFeature.isFeatureSupported(AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
      bool swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

      if (swAvailable && swInterceptAvailable) {
        AndroidServiceWorkerController serviceWorkerController = AndroidServiceWorkerController.instance();
        await serviceWorkerController.setServiceWorkerClient(AndroidServiceWorkerClient(
          shouldInterceptRequest: (request) async {
            return null;
          },
        ));
      }
    }

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.black,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          browser.webViewController.reload();
        } else if (Platform.isIOS) {
          browser.webViewController.loadUrl(urlRequest: URLRequest(url: await browser.webViewController.getUrl()));
        }
      },
    );
    browser.pullToRefreshController = pullToRefreshController;

    await browser.openUrlRequest(
      urlRequest: URLRequest(url: Uri.parse(selectedUrl)),
      options: InAppBrowserClassOptions(
        crossPlatform: InAppBrowserOptions(hideUrlBar: true, hideToolbarTop: true),
        inAppWebViewGroupOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(useShouldOverrideUrlLoading: true, useOnLoadResource: true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (() => _exitApp().then((value) => value!)),
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: CustomAppBar(title: 'payment'.tr, onBackPressed: () => _exitApp()),
        body: Center(
          child: SizedBox(
            width: Dimensions.webMaxWidth,
            child: Stack(
              children: [
                _isLoading ? Center(
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
                ) : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _exitApp() async {
    Get.find<OrderController>().cancelOrder(int.parse(widget.orderModel.id.toString()!), 'Digital payment issue').then((success) {
      if(success){
        Get.offAllNamed(RouteHelper.getInitialRoute());
      }
    });
  //  return Get.dialog(PaymentFailedDialog(orderID: widget.orderModel.id.toString(), orderAmount: widget.orderModel.orderAmount, maxCodOrderAmount: _maximumCodOrderAmount, orderType: widget.orderModel.orderType, isCashOnDelivery: widget.isCashOnDelivery));
  }

}

class MyInAppBrowser extends InAppBrowser {
  final String orderID;
  final String? orderType;
  final double? orderAmount;
  final double? maxCodOrderAmount;
  final bool isCashOnDelivery;
  MyInAppBrowser({required this.orderID, required this.orderType, required this.orderAmount, required this.maxCodOrderAmount, required this.isCashOnDelivery, int? windowId, UnmodifiableListView<UserScript>? initialUserScripts})
      : super(windowId: windowId, initialUserScripts: initialUserScripts);

  bool _canRedirect = true;

  @override
  Future onBrowserCreated() async {
    if (kDebugMode) {
      print("\n\nBrowser Created!\n\n");
    }
  }

  @override
  Future onLoadStart(url) async {
    if (kDebugMode) {
      print("\n\nStarted: $url\n\n");
    }
    _redirect(url.toString());
  }

  @override
  Future onLoadStop(url) async {
    pullToRefreshController?.endRefreshing();
    if (kDebugMode) {
      print("\n\nStopped: $url\n\n");
    }
    _redirect(url.toString());
  }

  @override
  void onLoadError(url, code, message) {
    pullToRefreshController?.endRefreshing();
    if (kDebugMode) {
      print("Can't load [$url] Error: $message");
    }
  }

  @override
  void onProgressChanged(progress) {
    if (progress == 100) {
      pullToRefreshController?.endRefreshing();
    }
    if (kDebugMode) {
      print("Progress: $progress");
    }
  }

  @override
  void onExit() {
    if(_canRedirect) {
      Get.find<OrderController>().cancelOrder(int.parse(orderID), 'Digital payment issue').then((success) {
        if(success){
          Get.offAllNamed(RouteHelper.getInitialRoute());
        }
      });
     // Get.dialog(PaymentFailedDialog(orderID: orderID, orderAmount: orderAmount, maxCodOrderAmount: maxCodOrderAmount, orderType: orderType, isCashOnDelivery: isCashOnDelivery));
    }
    if (kDebugMode) {
      print("\n\nBrowser closed!\n\n");
    }
  }

  @override
  Future<NavigationActionPolicy> shouldOverrideUrlLoading(navigationAction) async {
    if (kDebugMode) {
      print("\n\nOverride ${navigationAction.request.url}\n\n");
    }
    return NavigationActionPolicy.ALLOW;
  }

  @override
  void onLoadResource(resource) {
    if (kDebugMode) {
      print("Started at: ${resource.startTime}ms ---> duration: ${resource.duration}ms ${resource.url ?? ''}");
    }
  }

  @override
  void onConsoleMessage(consoleMessage) {
    if (kDebugMode) {
      print("""
    console output:
      message: ${consoleMessage.message}
      messageLevel: ${consoleMessage.messageLevel.toValue()}
   """);
    }
  }

  void _redirect(String url) {
    if(_canRedirect) {
      bool isSuccess = url.contains('success') && url.contains(AppConstants.baseUrl);
      bool isFailed = url.contains('fail') && url.contains(AppConstants.baseUrl);
      bool isCancel = url.contains('cancel') && url.contains(AppConstants.baseUrl);
      if (isSuccess || isFailed || isCancel) {
        _canRedirect = false;
        close();
      }
      if (isSuccess) {
        Get.offNamed(RouteHelper.getOrderSuccessRoute(orderID));
      } else if (isFailed || isCancel) {
        Get.find<OrderController>().cancelOrder(int.parse(orderID), 'Digital payment issue').then((success) {
          if(success){
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }
        });
       // Get.offNamed(RouteHelper.getOrderSuccessRoute(orderID));
      }
    }
  }

}