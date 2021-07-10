import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ippo_app/Constants.dart';
import 'package:ippo_app/dto/AggregatorDTO.dart';
import 'package:ippo_app/dto/OnlineAppCustomerDTO.dart';
import 'package:ippo_app/dto/Status.dart';
import 'dart:collection';
import 'dart:convert' as convert;
import 'package:marquee/marquee.dart';
import 'package:store_redirect/store_redirect.dart';


//import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:android_intent/android_intent.dart';

import 'package:flutter/material.dart';
import 'package:ippo_app/app_config.dart';
import 'package:ippo_app/dto/BaseDTO.dart';
import 'package:ippo_app/dto/BranchDTO.dart';
import 'package:ippo_app/dto/ContentListDTO.dart';
import 'package:ippo_app/dto/ContentListResponseDTO.dart';
import 'package:ippo_app/dto/CouponDTO.dart';
import 'package:ippo_app/dto/CurrentLocationDTO.dart';
import 'package:ippo_app/dto/DeliveryPersonRiderStatus.dart';
import 'package:ippo_app/dto/DisplayType.dart';
import 'package:ippo_app/dto/FcmAppType.dart';
import 'package:ippo_app/dto/FcmNotification.dart';
import 'package:ippo_app/dto/FcmRegisterationDTO.dart';
import 'package:ippo_app/dto/FilterDTO.dart';
import 'package:ippo_app/dto/FoodType.dart';
import 'package:ippo_app/dto/GenericDTO.dart';
import 'package:ippo_app/dto/MenuDTO.dart';
import 'package:ippo_app/dto/OnlineAppCustomerOrderDTO.dart';
import 'package:ippo_app/dto/OnlineOrderStatus.dart';
import 'package:ippo_app/dto/ProductDTO.dart';
import 'package:ippo_app/dto/SectionContentDTO.dart';
import 'package:ippo_app/dto/SectionDTO.dart';
import 'package:ippo_app/dto/SectionType.dart';
import 'package:ippo_app/dto/TagDTO.dart';
import 'package:ippo_app/globals.dart' as globals;
import 'package:flutter_icons/flutter_icons.dart';
import 'package:ippo_app/components/ModalRoundedProgressBar.dart';
import 'package:ippo_app/all_translations.dart';
import 'package:ippo_app/dto/LocationDTO.dart';
import 'package:ippo_app/dto/OutletRequestDTO.dart';
import 'package:ippo_app/dto/OutletResponseDTO.dart';
import 'package:ippo_app/route/RouteConstants.dart';
import 'package:ippo_app/screens/Promotions/PopupLayout.dart';
import 'package:ippo_app/services/ApiService.dart';
import 'package:ippo_app/services/LocationService.dart';
import 'package:ippo_app/services/NetworkService.dart';
import 'package:ippo_app/util/AnimatedLoader.dart';
import 'package:ippo_app/util/ExceptionHandler.dart';
import 'package:ippo_app/util/NoInternetScreen.dart';
import 'package:minimize_app/minimize_app.dart';
import 'package:rounded_letter/rounded_letter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ippo_app/Constants.dart';
import 'package:ippo_app/services/SharedPreferenceService.dart';
import 'dart:convert';
import 'package:ippo_app/util/util.dart';
import 'dart:math';

import 'package:geocoder/geocoder.dart';
import 'package:ippo_app/dto/ReverseGeoCodingOutput.dart';
//import 'package:network_to_file_image/network_to_file_image.dart';

import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sprintf/sprintf.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:package_info/package_info.dart';
import 'package:upgrader/upgrader.dart';
import 'package:ippo_app/services/CartService.dart';

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  print('myBackgroundMessageHandler  called');
  if (message.containsKey('data')) {
// Handle data message
    final dynamic data = message['data'];
    print('Fire base data received $data');
  }
  if (message.containsKey('notification')) {
// Handle notification message
    final dynamic notification = message['notification'];
    print('Fire base notification received $notification');
  }

// Or do other work.
}


class NewOutlet extends StatefulWidget {
  Coordinates coordinates;
  String subLocality;
  String pincode;
  final Function() notifyParent;
  // NewOutlet({Key key, @required this.notifyParent}) : super(key: key);
  //const NewOutlet({Key? key}) : super(key: key);
  NewOutlet(
      {Coordinates coordinates, String subLocality, String pincode, String adminArea,
        String subAdminArea, @required this.notifyParent}) {
    this.coordinates = coordinates;
    this.subLocality = subLocality;
    this.pincode = pincode;

    globals.productListS = new Map();
    globals.locationDTOS = new Map();
    globals.newCartListS = new Map();
    globals.newCartList = new Map();
  }

  @override
  State createState() {
    if (this.coordinates != null && this.subLocality != null)
      return new _NewOutlet(
          coordinates: coordinates, subLocality: subLocality, pincode: pincode);
    else
      return new _NewOutlet();
  }
}


class _NewOutlet extends State<NewOutlet> {
  _NewOutlet(
      {Coordinates coordinates, String subLocality, String pincode}) {
    this.coordinates = coordinates;
    this.subLocality = subLocality;
    this.pincode = pincode;
  }

  //Firebase messaging

  Map<int, ProductDTO> productlist = new Map();
  CartService cartService;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  //Customer name
  String customerName = '';
  //Bottom down arrow image
  String bottomDownArrowImage = 'images/screens/restaurant/bottomdownarrow.svg';
  String searchImage = 'images/screens/restaurant/search.svg';

  //String filterImage = 'images/screens/restaurant/filter.svg';
  String filterImage = 'images/icons/searchnew.png';
  String lineImage = 'images/icons/linebelow.png';

  AssetImage vegiconImage = AssetImage('images/screens/home/vegicon.png');
  AssetImage Location = AssetImage('images/icons/Location.png');
  AssetImage nonvegiconImage = AssetImage('images/screens/home/nonvegicon.png');
  Map<int, List<GenericDTO>> sectionMapGenericDTOList = new HashMap();
  Map<int, List<LocationDTO>> sectionMapLocationList = new HashMap();
  String noOperationImage = 'images/screens/restaurant/nooperation.png';
  String noOutletImage = 'images/screens/restaurant/outletunavailable.png';
  AssetImage percentageImage =
  AssetImage('images/screens/common/percentage.png');


  var geolocator = Geolocator();
  Coordinates coordinates;
  var locationOptions =
  LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
  StreamSubscription<Position> positionStream;
  AssetImage gpsImage = AssetImage('images/screens/restaurant/gps.png');

  ProgressBarHandler _handler;
  bool isLoading = true;
  bool isLocationEnabled = true;
  Position position;
  String subLocality;
  String adminArea = "NO";
  String subAdminArea = "area";

/*  print("ankurnewTry2 ${add[i].adminArea}");
  print("ankurnewTry2 ${add[i].subAdminArea}");*/
  String mobileNumber = ' ';
  bool isSubLocalitySet = false;
  Offset positionSubLocality;
  TextEditingController textcontroller = new TextEditingController();
  bool _searchStarted = false;
  bool _searchFoundOutlet = false;
  int backButtonCounter = 0;
  String registerationToken;

  bool registerationTokenUpdated;

  bool INTERNET_STATUS = true;
  String pincode;
  AssetImage nooutletImage = AssetImage('images/screens/common/nooutlet.png');

  List<SectionDTO> sectionDTOList;
  Map<int, List<LocationDTO>> storedLocationList =
  new HashMap<int, List<LocationDTO>>();

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> _subLocalityKey = new GlobalKey<ScaffoldState>();
  PackageInfo packageInfo;
  Map<String, Object> cartItems = new HashMap();

  Timer regTimer;

  bool downSwipe = false;

  Map<String, OnlineAppCustomerOrderDTO> orderNotificationMap = new Map();
  OnlineAppCustomerOrderDTO _selectedOnlineAppCustomerOrderDTO;
  int currentNotificationOrderIndex = 0;
  bool orderNotificatonSwiped = false;

  //Scroll controller map
  Map<int, ScrollController> _mediaScrollControllerMap = new HashMap();


  void _configureSelectNotificationSubject() {
    globals.selectNotificationSubject.stream.listen((String payload) async {
      //    print('Received payload $payload');
      String existingOrderId = globals.notificationOrderMap[payload];
      try {
        if (payload != null && existingOrderId == null) {
          globals.notificationOrderMap[payload] = payload;
          int orderId = int.parse(payload);
          if (orderNotificationMap[orderId.toString()] != null) {
            //     print('Order id $orderId available');
            return;
          }
          setState(() {
            isLoading = true;
          });
          BaseDTO baseDTO = await ApiService.getOnlineOrder(orderId);

          setState(() {
            isLoading = false;
          });
          if (baseDTO != null && baseDTO.status == true) {
            OnlineAppCustomerOrderDTO onlineAppCustomerOrderDTO = OnlineAppCustomerOrderDTO
                .fromJson(baseDTO.content);
            if (onlineAppCustomerOrderDTO != null) {
              List<Object> argsList = new List();
              argsList.add(onlineAppCustomerOrderDTO);
              bool toHome = true;
              argsList.add(toHome);
              //Add to notification
              orderNotificationMap[onlineAppCustomerOrderDTO.orderId
                  .toString()] = onlineAppCustomerOrderDTO;
              //    print('Before navigator $context ');
              Navigator.pushNamed(
                  context, RouteConstants.trackYourOrderRoute,
                  arguments: argsList);
            }
          }
        }
      } catch (s, e) {
        //   print('$e , $s');
      }
    });
  }

  @override
  void dispose() {
    globals.selectNotificationSubject.close();
    super.dispose();
  }

  //checks version and redirects to play store
  void checkVersion() async {
    BaseDTO baseDto = await ApiService.getAggregator(globals.aggregatorId);
    if (baseDto != null && baseDto.status == true) {
      AggregatorDTO aggregatorDTO = AggregatorDTO.fromJson(baseDto.content);
      if (aggregatorDTO != null) {
        //   print('Received aggreagator after back button page');
        globals.aggregatorDTO = aggregatorDTO;
      } else {
        //    print('Received aggreagator after back button page is null !!!');
      }
    } else {
      print('Received aggreagator basedto is null');
    }
    String packagaeName = "com." + globals.flavor + ".onlineapp";
    print('Packaage name $packagaeName : Version in servier side ${globals
        .aggregatorDTO.packageVersion } : Current version ${packageInfo
        .version} ');
    if (globals.aggregatorDTO != null &&
        globals.aggregatorDTO.packageVersion != null &&
        globals.aggregatorDTO.packageVersion != packageInfo.version) {
      print('Redirection to playstore/apple store for version ${packageInfo
          .version} for package $packagaeName');
      navigateToVersionUpgrade(globals.aggregatorDTO.packageVersion);
    }
  }

  void navigateToVersionUpgrade(String version) async {
    String packagaeName = "com." + globals.flavor + ".onlineapp";
    List<Object> object = new List();
    object.add(version);
    object.add(packagaeName);
    await Navigator.pushNamed(
        context, RouteConstants.versionUpgradetagRoute,
        arguments: object);
    //check with server for aggregator
    setState(() {
      isLoading = true;
    });

    BaseDTO baseDto = await ApiService.getAggregator(globals.aggregatorId);
    if (baseDto != null && baseDto.status == true) {
      AggregatorDTO aggregatorDTO = AggregatorDTO.fromJson(baseDto.content);
      if (aggregatorDTO != null) {
        //  print('Received aggreagator after back button page');
        globals.aggregatorDTO = aggregatorDTO;
      } else {
        print('Received aggreagator after back button page is null !!!');
      }
    } else {
      print('Received aggreagator basedto is null');
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  initState()  {
    super.initState();
    /* String Subadmin = SharedPreferenceService.getValuesStringSF(Constants.subAdminArea);
    print("sublocality ${Subadmin}");*/
    SharedPref();
    _configureSelectNotificationSubject();
    subLocality = allTranslations.text('home_locality');
    configureFirebase();
//     cartService = new CartService(productlist);
// print("ankurhere:--- ${cartService.getTotalCartItemCount()}");

    regTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      sendRegisterationToken(this.registerationToken);
    });

    checkProfileUpdate();
    textcontroller.addListener(() {
      searchOutlet(textcontroller.text);
      if (textcontroller.text != null && textcontroller.text.length > 0)
        _searchStarted = true;
      //   print(textcontroller.text);
    });

    getNameMobileNumber();
    getLocationFromGoogle();
    //Scroll movement
  }

  void scroll() {
    // print('scroll called');

    int secondsPerBanner = 3;
    if (_mediaScrollControllerMap != null) {
      _mediaScrollControllerMap.forEach((secIndex, _mediaScrollController) {
        _mediaScrollController.addListener(() {
          if (_mediaScrollController.position.pixels ==
              _mediaScrollController.position.maxScrollExtent) {
            int noOfBanners;
            noOfBanners = sectionDTOList[secIndex].sectionContentList.length;
            int timeToScroll = 1000 * secondsPerBanner * (noOfBanners ?? 1);
            _mediaScrollController.animateTo(
                _mediaScrollController.position.minScrollExtent,
                curve: Curves.easeOut,
                duration: Duration(milliseconds: timeToScroll));
          }
        });
        _mediaScrollController.addListener(() {
          if (_mediaScrollController.position.pixels ==
              _mediaScrollController.position.minScrollExtent) {
            int noOfBanners;
            noOfBanners = sectionDTOList[secIndex].sectionContentList.length;
            int timeToScroll = 1000 * secondsPerBanner * (noOfBanners ?? 1);
            _mediaScrollController.animateTo(
                _mediaScrollController.position.maxScrollExtent,
                curve: Curves.easeOut,
                duration: Duration(milliseconds: timeToScroll));
          }
        });
        int noOfBanners;
        noOfBanners = sectionDTOList[secIndex].sectionContentList.length;
        int timeToScroll = 1000 * secondsPerBanner * (noOfBanners ?? 1);
        _mediaScrollController.animateTo(
            _mediaScrollController.position.maxScrollExtent,
            curve: Curves.easeOut,
            duration: Duration(milliseconds: timeToScroll));
      });
    }
  }

  void displayNotification(var message) async {
    //   print("Firebase onMessage recevied: ${message}");
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '5', 'Online order', 'Online order channile',
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    var res = message['notification'];
    //  print('Runtime type : ${res.runtimeType}');
    //  print('Notification messsage ${message['notification']}');

    var n = message['notification'];
    String title = n['title'];
    String body = n['body'];


    // print('Title $title  : Body $body');
    var data = message['data'];
    var jsondata = data['jsondata'];
    //  print('Data payload $jsondata');
    String orderId = data['order_id'];
    //String body=  message['body'];
    if (title != null && body != null && orderId != null) {
      //     print('Order id $orderId');
      orderNotificationMap[orderId] = null;
      await FlutterLocalNotificationsPlugin().show(
          0, title, body,
          platformChannelSpecifics,
          payload: orderId);
    }
  }

  void configureFirebase() {
    // print('Configuring firebase');
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        displayNotification(message);
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        //  print("Firebase onLaunch called: $message");
        displayNotification(message);
      },
      onResume: (Map<String, dynamic> message) async {
        //   print("Firebase onResume called: $message");
        displayNotification(message);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      //   print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      if (token != null) {
        this.registerationToken = token;
        sendRegisterationToken(token);
      }
    });
  }

  void sendRegisterationToken(String token) async {
    if (token == null || registerationTokenUpdated == true)
      return;

    FcmRegisterationDTO request = FcmRegisterationDTO();
    int refId = await SharedPreferenceService.getValuesIntSF(
        Constants.onlineAppcustomerId);

    // String cartCheck = await SharedPreferenceService.getValuesStringSF("cart");
    // print("cartCheckOne:--- $cartCheck");

    request.refId = refId.toString();
    //  print('Firebase registration token [$token]');
    request.aggregatorId = globals.aggregatorId;
    request.customerId = null;
    request.fcmAppType = FcmAppType.CUS_APP;
    request.registerationToken = token;
    BaseDTO baseDTO = await ApiService.sendregisterationTokenUpdate(request);
    if (baseDTO != null && baseDTO.status == true && baseDTO.code == 200) {
      registerationTokenUpdated = true;
    }
  }

  void checkProfileUpdate() async {
    bool status = await SharedPreferenceService.getValuesBoolSF(
        Constants.isProfileUpdated);
    if (!status)
      var result = await Navigator.pushNamed(
          context, RouteConstants.profileRoute);
  }

  void setCustomerName() {}

  getNameMobileNumber() async {
    bool locationEnabled = await LocationService().getLocationServiceStatus();
    if (!locationEnabled) {
      Fluttertoast.showToast(msg: allTranslations.text('enable_location_msg'));
      locationEnabled = await LocationService().openLocationSetting();
      if (locationEnabled == false) {
        Fluttertoast.showToast(
            msg: allTranslations.text('enable_location_msg'));
        setState(() {
          isLoading = false;
        });
      }
    }

    String name =
    await SharedPreferenceService.getValuesStringSF(Constants.customerName);
    // print('Got custname $customerName');
    if (name != null && name.isNotEmpty && name.length > 0) {
      name =
          name.substring(0, 1).toUpperCase() + name.substring(1, name.length);
    }
    String mobileNumber =
    await SharedPreferenceService.getValuesStringSF(Constants.mobileNumber);
    if (mobileNumber != null)
      mobileNumber =
      globals.countrycode + mobileNumber != null ? mobileNumber : ' ';
    //  print('Got custname mobile number : $mobileNumber');

    setState(() {
      this.customerName = name;
      this.mobileNumber = mobileNumber;
    });
  }

  Future<bool> getLocationServiceStatus() async {
    bool status = await Geolocator().isLocationServiceEnabled();
    // print('Location :  $status');
    return status;
  }

  void searchOutlet(String text) {
    //   print('Search outlet called $text');
    int sectionIndex = 0;
    if (sectionDTOList != null && sectionDTOList.length > 0) {
      sectionDTOList.forEach((e) {
        if (e.sectionType == SectionType.RESTURANT_LISTING) {
          e.locationDtoList = storedLocationList[sectionIndex];
          _searchFoundOutlet = false;
        }
        sectionIndex++;
      });
    }
    if (text != null && text.isNotEmpty) {
      _searchStarted = true;

      if (sectionDTOList != null && sectionDTOList.length > 0) {
        sectionDTOList.forEach((e) {
          if (e.sectionType == SectionType.RESTURANT_LISTING) {
            if (e.locationDtoList != null && e.locationDtoList.length > 0) {
              List<LocationDTO> newLocationList = new List();
              e.locationDtoList.forEach((loc) {
                if (loc.name.toUpperCase().startsWith(text.toUpperCase())) {
                  newLocationList.add(loc);
                  _searchFoundOutlet = true;
                }
              });
              e.locationDtoList = newLocationList;
            }
          }
        });
      }
    } else {
      _searchStarted = false;
      _searchFoundOutlet = false;
    }
    setState(() {});
  }

  void getLocationFromGoogle() async {
    try {
      //Check for getLocation status
      packageInfo = await PackageInfo.fromPlatform();
      //    print('Package version  ${packageInfo.version}');
      checkVersion();
      double latitude = 0.0;
      double longitude = 0.0;
      //     print('In init');
      if (coordinates == null) {
        //     print('About to get lat and lng');
        this.position = await Geolocator()
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        isLocationEnabled = true;
        isLoading = true;
        print(
            'Got current location from geolocator : ${position.latitude} , ${position.longitude}');
        latitude = position.latitude;
        longitude = position.longitude;
        if (latitude != null) {
          //       print("ankurnewTry01 ${latitude}");
          var add = _getAddress(latitude, longitude);
          print(add);
          //var first = add.first;
          //print("${first.featureName} : ${first.addressLine}");

          // for (var i = 0; i < add.length; i++) {
          //   print("ankurnewTry2 ${add[i]}");
          // }
        }
      } else {
        //     print(
        //         'Got coordinates location : ${coordinates.latitude} , ${coordinates
        //            .longitude}');
        latitude = coordinates.latitude;
        longitude = coordinates.longitude;
        if (latitude != null) {
          //   print("ankurnewTry01 ${latitude}");

          var add = _getAddress(latitude, longitude);
          //  print(add);
          // var first = add.first;
          // print("${first.featureName} : ${first.addressLine}");
          // for (var i = 0; i < add.length; i++) {
          //   print("ankurnewTry2 ${add[i]}");
          // }
        }
      }
      //Check network
      INTERNET_STATUS = await NetworkService.check();
      if (INTERNET_STATUS == false) {
        //     print('Internet status $INTERNET_STATUS');
        setState(() {
          INTERNET_STATUS = false;
        });
        return;
      }
      //   print('Internet status $INTERNET_STATUS');
      //Show Loation not  availb
      if (latitude == null || longitude == null) {}
      //   print('The value of subLocality is${subLocality}');
      if (subLocality == null ||
          subLocality == allTranslations.text('home_locality')) {
        this.subLocality =
        await getLocationUsingGoogleReverseGeocoding(latitude, longitude);
        SharedPreferenceService.addDoubleToSF(
            Constants.geoLocationLatitude, latitude);
        SharedPreferenceService.addDoubleToSF(
            Constants.geoLocationLongitude, longitude);
        SharedPreferenceService.addStringToSF(
            Constants.subLocality, subLocality);
      }

      // Address not available from google reverse geocding
      if (this.subLocality == null) {}
      if (this.subLocality == null) {
        this.subLocality = allTranslations.text('home_locality');
      }
      isSubLocalitySet = true;
      // getOutletList(latitude, longitude);
      //Get Online app customer and check for blocked status
      getContentList(latitude, longitude);

      setState(() {
        isSubLocalitySet = true;
        //  getRunningOrders();
      });
    } catch (e, s) {
      // print('$e , $s');
      if (this.subLocality == null) {
        this.subLocality = allTranslations.text('home_locality');
      }
    }
    //getRunningOrders();
  }

  void getContentList(double latitude, double longitude) async {
    //  print('getContentList called ');
    // setState(() {
    isLoading = true;
    //   });
    ContentListDTO contentListDTO = new ContentListDTO();
    contentListDTO.onlineAppCustomerId =
    await SharedPreferenceService.getValuesIntSF(
        Constants.onlineAppcustomerId.toString());
    contentListDTO.aggregatorId = globals.aggregatorId;
    contentListDTO.longitude = longitude;
    contentListDTO.latitude = latitude;
    contentListDTO.pincode = this.pincode;


    ApiService.getContentListV1(contentListDTO).then((baseDto) {
      if (baseDto != null && baseDto.content != null) {
        sectionDTOList = (baseDto.content as List).map((e) {
          SectionDTO sectionDTO = SectionDTO.fromJson(e);
          // print(
          //     'Section name ${sectionDTO.name} : ${sectionDTO
          //         .sectionType}  :: ${sectionDTO.displayType} ');
          if (sectionDTO.sectionContentList != null) {
            // print(
            //     'Section dto content length ${sectionDTO.sectionContentList
            //         .length}');
          }

          return sectionDTO;
        }).toList();
        sectionDTOList
            .sort((a, b) => a.sectionSortOrder.compareTo(b.sectionSortOrder));
        if (sectionDTOList != null && sectionDTOList.length > 0) {
          int sectionIndex = 0;
          sectionDTOList.forEach((e) {
            if (e.sectionType == SectionType.RESTURANT_LISTING)
              storedLocationList[sectionIndex] = e.locationDtoList;
            sectionIndex++;
            //Add the category products for tow and three grid sections
            if (e.sectionType == SectionType.PRODUCT_CATEGORY_THREE_GRID ||
                e.sectionType == SectionType.PRODUCT_CATEGORY_TWO_GRID ||
                e.sectionType == SectionType.CATEGORY ||
                e.sectionType == SectionType.CATEGORY_TWO_GRID ||
                e.sectionType == SectionType.PRODUCT_CATEGORY_MULTI_GRID ||
                e.sectionType == SectionType.CATEGORY_THREE_GRID) {
              print(
                  'In section type PRODUCT_CATEGORY_THREE_GRID & PRODUCT_CATEGORY_TWO_GRID ');
              if (e.menuDTO != null && e.menuDTO.menuItems != null &&
                  e.menuDTO.menuItems.length > 0) {
                //   print('Menu items length ${e.menuDTO.menuItems.length}');

                e.menuDTO.categoryList = new List();
                e.menuDTO.categoryMap = new HashMap();
                e.menuDTO.categoryIdNameMap = new HashMap();
                e.menuDTO.menuItems.forEach((element) {
                  if (element.product != null &&
                      element.product.categoryName != null &&
                      element.product.categoryName.isNotEmpty) {
                    // print('Menu item cat name : ${element.product
                    //     .categoryName}  Category id : ${element.product
                    //     .categoryId}');
                    String catName = element.product.categoryName;
                    List<ProductDTO> plist = e.menuDTO.categoryMap[catName];
                    if (plist == null)
                      plist = new List();
                    element.product.price = element.productPrice;
                    plist.add(element.product);

                    e.menuDTO.categoryMap[catName] = plist;
                    e.menuDTO.categoryIdNameMap[element.product
                        .categoryId.toString()] = catName;
                  }
                });
                if (e.menuDTO.categoryMap != null &&
                    e.menuDTO.categoryMap.length > 0) {
                  e.menuDTO.categoryMap.forEach((key, value) {
                    e.menuDTO.categoryList.add(key);
                    value.sort((a, b) => a.name.compareTo(b.name));
                  });
                  //sort category
                  e.menuDTO.categoryList.sort((a, b) => a.compareTo(b));
                  //sort producct lsit

                }

                print(' Category Map length  : ${e.menuDTO.categoryMap
                    .length} : cat length : ${e.menuDTO.categoryList.length}');
              }
            }
          });
          //For image cache clearing
          String serverTime = sectionDTOList[0].imageCacheExpriyDate;
          Util.clearCacheImage(serverTime);
        }
      } else {
        sectionDTOList = null;
      }

      setState(() {
        isLoading = false;
      });
    }).catchError((s, e) {
      print('$e, $s');
      try {
        ExceptionHandler().handleException(e);
      } catch (x) {
        print(x);
      }
      if (this.mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });

    BaseDTO bdto = await ApiService.getOnlineAppCustomer(
        contentListDTO.onlineAppCustomerId);
    if (bdto != null && bdto.content != null && bdto.status == true) {
      OnlineAppCustomerDTO appcustomer = OnlineAppCustomerDTO.fromJson(
          bdto.content);
      if (appcustomer != null) {
        if (appcustomer.status == Status.INACTIVE) {
          Fluttertoast.showToast(
              msg: allTranslations.text('Newoutlet_customer_blocked'));
          setState(() {
            isLoading = false;
          });
          Navigator.pushNamed(
              context,
              RouteConstants.accountBlockedScreen);
          return;
        }
      } else {
        Fluttertoast.showToast(
            msg: allTranslations.text('Newoutlet_customer_unableto_get'));
        setState(() {
          isLoading = false;
        });
        Navigator.pushNamed(
            context,
            RouteConstants.accountBlockedScreen);
        return;
      }
    } else {
      Fluttertoast.showToast(
          msg: allTranslations.text('Newoutlet_customer_unableto_get'));
      setState(() {
        isLoading = false;
      });
      Navigator.pushNamed(
          context,
          RouteConstants.accountBlockedScreen);
      return;
    }
  }

  Color getRandomColor() {
    Random random = new Random();
    int randomNumber = random.nextInt(3);
    randomNumber = randomNumber + 1;
    switch (randomNumber) {
      case 1:
        return Colors.pink[50];
      case 2:
        return Colors.blue[50];
      case 3:
        return Colors.green[50];
    }
  }

  void resetFilter() {
    if (sectionDTOList != null && sectionDTOList.length > 0) {
      sectionDTOList.forEach((e) {
        if (e.sectionType == SectionType.PRODUCT_LISTING_NOADDBTN ||
            e.sectionType == SectionType.PRODUCT_LISTING_ADDBTN ||
            e.sectionType == SectionType.PRODUCT_LISTING_SINGLE_IMG ||
            e.sectionType == SectionType.PRODUCT_LISTING_GRID) {
          if (sectionMapGenericDTOList[e.id] != null)
            e.menuDTO.menuItems = sectionMapGenericDTOList[e.id];
        } else if (e.sectionType == SectionType.RESTURANT_LISTING) {
          if (sectionMapLocationList[e.id] != null)
            e.locationDtoList = sectionMapLocationList[e.id];
        }
      });
    }
  }

  void applyFilter(FilterDTO filterDTO) {
    // print(' apply called ');
    setState(() {
      if (filterDTO.subLocalityName != null && filterDTO.position != null) {
        this.subLocality = filterDTO.subLocalityName;
        this.position = filterDTO.position;
      }
      if (sectionDTOList != null && sectionDTOList.length > 0) {
        sectionDTOList.forEach((e) {
          if (e.sectionType == SectionType.PRODUCT_LISTING_NOADDBTN ||
              e.sectionType == SectionType.PRODUCT_LISTING_ADDBTN ||
              e.sectionType == SectionType.PRODUCT_LISTING_SINGLE_IMG ||
              e.sectionType == SectionType.PRODUCT_LISTING_GRID) {
            //FoodType
            if (e.menuDTO != null &&
                e.menuDTO.menuItems != null &&
                e.menuDTO.menuItems.length > 0) {
              List<GenericDTO> gDTOList = new List();
              if (!sectionMapGenericDTOList.containsKey(e.id)) {
                sectionMapGenericDTOList[e.id] = e.menuDTO.menuItems;
              }
              e.menuDTO.menuItems.forEach((genericDTO) {
                bool isProductAdd = false;
                bool isOutletAdd = false;
                if (genericDTO.product.foodType != null) {
                  switch (genericDTO.foodType) {
                    case FoodType.VEG:
                      if (filterDTO.isVegSelected) isProductAdd = true;
                      break;
                    case FoodType.NON_VEG:
                      if (filterDTO.isNonVegSelected) isProductAdd = true;
                      break;
                    case FoodType.EGG:
                      if (filterDTO.isEggitarianSelected) isProductAdd = true;
                      break;
                    case FoodType.NA:
                    //gDTOList.add(genericDTO);
                      break;
                  }
                }
                //Delivery time
                if (e.menuDTO.locationIdList != null &&
                    e.menuDTO.locationIdList.length > 0) {
                  LocationDTO loc = e.menuDTO.locationIdList[0];
                  if (loc != null && loc.deliveryTimeInMins != null &&
                      loc.deliveryTimeInMins >= filterDTO.lowerDeliveryTime &&
                      loc.deliveryTimeInMins <= filterDTO.upperDeliveryTime) {
                    isOutletAdd = true;
                  }
                }
                if (isOutletAdd && isProductAdd) {
                  //Filter the rating
                  if (getRating(filterDTO, genericDTO))
                    gDTOList.add(genericDTO);
                }
              });
              e.menuDTO.menuItems = gDTOList;
            }
          } else if (e.sectionType == SectionType.RESTURANT_LISTING) {
            //Location filterring
            if (e.locationDtoList != null && e.locationDtoList.length > 0) {
              List<LocationDTO> newLocList = new List();
              e.locationDtoList.forEach((locationDTO) {
                if (!sectionMapLocationList.containsKey(e.id)) {
                  sectionMapLocationList[e.id] = e.locationDtoList;
                }
                if (locationDTO.deliveryTimeInMins >=
                    filterDTO.lowerDeliveryTime &&
                    locationDTO.deliveryTimeInMins <=
                        filterDTO.upperDeliveryTime) {
                  newLocList.add(locationDTO);
                }
                e.locationDtoList = newLocList;
              });
            }
          }
        });
      }
    });
  }

  bool getRating(FilterDTO filterDTO, GenericDTO genericDTO) {
    genericDTO.rating = genericDTO.rating ?? 5;

    if (filterDTO.isRating5Selected && genericDTO.rating == 5) {
      return true;
    }
    if (filterDTO.isRating4Selected && genericDTO.rating == 4) {
      return true;
    }
    if (filterDTO.isRating3Selected && genericDTO.rating == 3) {
      return true;
    }
    if (filterDTO.isRating2Selected && genericDTO.rating == 2) {
      return true;
    }
    return false;
  }
  Future<String> getLocationUsingGoogleReverseGeocoding(final double latitude,
      final double longitude) async {
    String googlePlaccesApiKey = globals.googlePlaccesApiKey;
    String latlng = '$latitude,$longitude';
    String subLocality;
    try {
      ReverseGeoCodingOutput reverseGeoCodingOutput =
      await ApiService.googleReverseGeocodingApiRequest(
          latlng, googlePlaccesApiKey);

      //Postal code
      reverseGeoCodingOutput.results[0].addressComponents.forEach((value) {
        value.types.forEach((e) {
          if (e == 'postal_code') {
            pincode = value.longName;
            //       print('Postal  from reverse geocoding $pincode');
          }
        });
      });

      //Sublocality
      reverseGeoCodingOutput.results[0].addressComponents.forEach((value) {
        value.types.forEach((e) {
          if (e == 'sublocality_level_1') {
            subLocality = value.longName;
            //     print('Sublocality from reverse geocoding $subLocality');
            return subLocality;
          }
        });
      });
      if (subLocality != null) {
        return subLocality;
      }
      //City - locality
      reverseGeoCodingOutput.results[0].addressComponents.forEach((value) {
        value.types.forEach((e) {
          if (e == 'locality') {
            subLocality = value.longName;
            //   print('Sublocality from reverse geocoding $subLocality');
            return subLocality;
          }
        });
      });
      //City - locality
      reverseGeoCodingOutput.results[0].addressComponents.forEach((value) {
        value.types.forEach((e) {
          if (e == 'administrative_area_level_2') {
            subLocality = value.longName;
            // print('Sublocality from reverse geocoding $subLocality');
            return subLocality;
          }
        });
      });

      //City - state
      reverseGeoCodingOutput.results[0].addressComponents.forEach((value) {
        value.types.forEach((e) {
          if (e == 'administrative_area_level_2') {
            subLocality = value.longName;
            // print('Sublocality from reverse geocoding $subLocality');

            return subLocality;
          }
        });
      });

      //City - Cuountry
      reverseGeoCodingOutput.results[0].addressComponents.forEach((value) {
        value.types.forEach((e) {
          if (e == 'administrative_area_level_1') {
            subLocality = value.longName;
            //   print('Sublocality from reverse geocoding $subLocality');
            return subLocality;
          }
        });
      });

      reverseGeoCodingOutput.results[0].addressComponents.forEach((value) {
        value.types.forEach((e) {
          if (e == 'locality') {
            subLocality = value.longName;
            // print('Sublocality from reverse geocoding $subLocality');
            return subLocality;
          }
        });
      });
      //    print('Sublocality from reverse geocoding $subLocality');
      return subLocality;
    } catch (e) {
      print('Exception : $e');
      return null;
    }
  }


  void openLocationSetting() async {
    final AndroidIntent intent = new AndroidIntent(
      action: 'android.settings.LOCATION_SOURCE_SETTINGS',
    );
    await intent.launch();
  }

  void filterOutletByCategory(int index, int sectionIndex) {
    //print('filterOutletByCategory outlet called');

    int sindex = 0;
    if (sectionDTOList != null && sectionDTOList.length > 0) {
      sectionDTOList.forEach((e) {
        if (e.sectionType == SectionType.RESTURANT_LISTING) {
          e.locationDtoList = storedLocationList[sindex];
        }
        sindex++;
      });
    }

    //For deselcting the cagegory
    if (sectionDTOList[sectionIndex].tagDtoList != null &&
        sectionDTOList[sectionIndex].tagDtoList[index].isCategorySelected ==
            null) {
      sectionDTOList[sectionIndex].tagDtoList[index].isCategorySelected = false;
    }
    if (sectionDTOList[sectionIndex].tagDtoList != null &&
        sectionDTOList[sectionIndex].tagDtoList[index].isCategorySelected ==
            true) {
      sectionDTOList[sectionIndex].tagDtoList[index].isCategorySelected =
      !sectionDTOList[sectionIndex].tagDtoList[index].isCategorySelected;

      sectionDTOList.forEach((v) {
        if (sectionDTOList[sectionIndex].tagDtoList != null) {
          sectionDTOList[sectionIndex].tagDtoList.forEach((v) {
            v.isCategorySelected = false;
          });
        }
      });
      setState(() {});
      return;
    }

    sectionDTOList[sectionIndex].tagDtoList[index].isCategorySelected =
    !sectionDTOList[sectionIndex].tagDtoList[index].isCategorySelected;

    if (sectionDTOList != null && sectionDTOList.length > 0) {
      sectionDTOList.forEach((e) {
        if (e.sectionType == SectionType.RESTURANT_LISTING) {
          if (e.locationDtoList != null && e.locationDtoList.length > 0) {
            List<LocationDTO> newLocationList = new List();
            e.locationDtoList.forEach((loc) {
              if (sectionDTOList[sectionIndex].tagDtoList != null) {
                if (sectionDTOList[sectionIndex]
                    .tagDtoList[index]
                    .locationIdList !=
                    null) {
                  if (sectionDTOList[sectionIndex]
                      .tagDtoList[index]
                      .locationIdList
                      .contains(loc.id)) {
                    newLocationList.add(loc);
                  }
                }
              }
            });
            e.locationDtoList = newLocationList;
          }
        }
      });
    }

    setState(() {});
  }

  Map<int, List<ProductDTO>> getCartItems(String key) {
    return cartItems[key];
  }

  void navigateToProductListPage(int index, int sectionIndex) async {
    LocationDTO locationDTO =
    sectionDTOList[sectionIndex].locationDtoList[index];
    //set the pincode
    locationDTO.pincode = this.pincode;
    List<Object> object = new List();
    object.add(sectionDTOList[sectionIndex].locationDtoList[index].displayName);
    object.add(locationDTO);
    //sending null for product dto
    object.add(null);
    object.add(
        getCartItems(locationDTO.displayName + locationDTO.id.toString()));
    var result = await Navigator.pushNamed(
        context, RouteConstants.productListingRoute,
        arguments: object);
    if (result != null) {
      Map<int, List<ProductDTO>> cartData = result;
      cartItems[locationDTO.displayName + locationDTO.id.toString()] = cartData;
      widget.notifyParent();
    }
  }


  LocationDTO getLocationFromMap(MenuDTO menuDTO, ProductDTO productDTO) {
    LocationDTO locationDTO;
    List<int> locIdList = new List();

    if (menuDTO != null && menuDTO.locationProductMap != null) {
      menuDTO.locationProductMap.forEach((key, value) {
        List<int> plist = value;
        if (plist != null && plist.length > 0) {
          plist.forEach((pid) {
            if (productDTO.availability == true && productDTO.id == pid) {
              locIdList.add(int.parse(key));
            }
          });
        }
      });
    }
    if (locIdList != null) {
      bool found = false;
      locIdList.forEach((locId) {
        menuDTO.locationIdList.forEach((element) {
          // print('Location id : ${element.locationDTO.id }');
          if (locationDTO == null && found == false && element.id == locId &&
              element.availability == true) {
            locationDTO = element;
            found = true;
          }
        });
      });
    }
    if (locationDTO != null)
      //  print('Found loction ${locationDTO.id} ');
      return locationDTO;
  }

  void navigateToProductListPageFromProduct(int index, int sectionIndex,
      int productId) async {
    if (sectionDTOList[sectionIndex].menuDTO.locationIdList != null &&
        sectionDTOList[sectionIndex].menuDTO.locationIdList.length > 0) {
      ProductDTO productDTO = sectionDTOList[sectionIndex].menuDTO
          .menuItems[index].product;
      LocationDTO locationDTO = getLocationFromMap(
          sectionDTOList[sectionIndex].menuDTO, productDTO);

      if (productDTO == null || locationDTO == null)
        return;
      if (productDTO.availability == true) {
        // print('Location name is ${locationDTO.displayName}');
        // print('Location Availablity ${locationDTO.availability}');
        List<Object> object = new List();
        object.add(locationDTO.displayName);
        object.add(locationDTO);
        object.add(productDTO);
        object.add(
            getCartItems(locationDTO.displayName + locationDTO.id.toString()));
        var result = await Navigator.pushNamed(
            context, RouteConstants.productListingRoute,
            arguments: object);
        if (result != null) {
          Map<int, List<ProductDTO>> cartData = result;
          cartItems[locationDTO.displayName + locationDTO.id.toString()] =
              cartData;
        }
      }
    }
  }

  List<LocationDTO> getLocationListFromCategoryMap(MenuDTO menuDTO,
      String categoryName) {
    ProductDTO productDTO;
    List<int> locIdList = new List();
    List<LocationDTO> locationDTOList = new List();
    //Get product from category
    if (menuDTO != null && menuDTO.menuItems != null) {
      for (int i = 0; i < menuDTO.menuItems.length; i++) {
        ProductDTO pdto = menuDTO.menuItems[i].product;
        if (pdto.categoryName.toLowerCase() == categoryName.toLowerCase()) {
          print('found product ${pdto.name}');
          productDTO = pdto;
          break;
        }
      }
    }


    if (productDTO != null && menuDTO != null &&
        menuDTO.locationProductMap != null) {
      menuDTO.locationProductMap.forEach((key, value) {
        List<int> plist = value;
        if (plist != null && plist.length > 0) {
          plist.forEach((pid) {
            if (productDTO.id == pid) {
              print('Found locaiton id $key');
              locIdList.add(int.parse(key));
            }
          });
        }
      });
    }
    if (locIdList != null) {
      locIdList.forEach((locId) {
        menuDTO.locationIdList.forEach((element) {
          // print('Location id : ${element.locationDTO.id }');
          if (element.id == locId && element.availability == true) {
            locationDTOList.add(element);
          }
        });
      });
    }
    return locationDTOList;
  }


  //For tag based
  void navigateToCatgoryListScreenForTags(int index, int sectionIndex) async {
    SectionDTO sectionDTO = sectionDTOList[sectionIndex];
    print(
        'navigateToCatgoryListScreenForTags called  :: ${sectionDTO.menuDTO}');


    if (sectionDTO != null &&
        sectionDTO.tagDtoList != null && sectionDTO.tagDtoList.length > 0) {
      // print(
      //     'Lenght of category list ${sectionDTO.tagDtoList[index].categoryIdList
      //         .length}');

      String categoryName = sectionDTO.tagDtoList[index].name ?? '';
      String description = sectionDTO.tagDtoList[index].description;
      List<Object> object = new List();
//      List<LocationDTO> locationDTOList = getLocationListFromCategoryMap(
      //         sectionDTO.menuDTO, categoryName);
      List<LocationDTO> locationDTOList = sectionDTO.tagDtoList[index]
          .locationDtoList;
      if (locationDTOList == null || locationDTOList.length == 0) {
        //print('Total outlets ${locationDTOList.length}');
        showOutletNotAvailablePopUp(context, buildOutletNotAvailable());
        return;
      }
      if (locationDTOList.length > 1) {
        //     print('Category name : $categoryName');
        object.add(categoryName);
        object.add(description);
        object.add(locationDTOList);
        object.add(cartItems);
        var result = await Navigator.pushNamed(
            context, RouteConstants.tagProductListingRoute,
            arguments: object);
        if (result != null) {
          Map<String, List<ProductDTO>> cartData = result;
          cartItems = cartData;
        }
      } else if (locationDTOList.length == 1) {
        LocationDTO locationDTO = locationDTOList[0];
        List<Object> object = new List();
        object.add(locationDTO.displayName);
        object.add(locationDTO);
        //sending null for product dto
        object.add(null);
        object.add(
            getCartItems(locationDTO.displayName + locationDTO.id.toString()));
        var result = await Navigator.pushNamed(
            context, RouteConstants.productListingRoute,
            arguments: object);
        if (result != null) {
          Map<String, List<ProductDTO>> cartData = result;
          cartItems = cartData;
        }
      }
    }
  }

  LocationDTO getLocationFromCategoryMap(MenuDTO menuDTO, String categoryName) {
    LocationDTO locationDTO;
    ProductDTO productDTO;
    List<int> locIdList = new List();
    //Get product from category
    if (menuDTO != null && menuDTO.menuItems != null) {
      for (int i = 0; i < menuDTO.menuItems.length; i++) {
        ProductDTO pdto = menuDTO.menuItems[i].product;
        if (pdto.categoryName.toLowerCase() == categoryName.toLowerCase()) {
          //    print('found product ${pdto.name}');
          productDTO = pdto;
          break;
        }
      }
    }


    if (productDTO != null && menuDTO != null &&
        menuDTO.locationProductMap != null) {
      menuDTO.locationProductMap.forEach((key, value) {
        List<int> plist = value;
        if (plist != null && plist.length > 0) {
          plist.forEach((pid) {
            if (productDTO.id == pid) {
              //        print('Found locaiton id $key');
              locIdList.add(int.parse(key));
            }
          });
        }
      });
    }
    if (locIdList != null) {
      bool found = false;
      locIdList.forEach((locId) {
        menuDTO.locationIdList.forEach((element) {
          // print('Location id : ${element.locationDTO.id }');
          if (locationDTO == null && found == false && element.id == locId &&
              element.availability == true) {
            locationDTO = element;
            found = true;
          }
        });
      });
    }
    if (locationDTO != null)
      print('Found loction ${locationDTO.id} ');
    else
      print('Loction not found category $categoryName');
    return locationDTO;
  }

  //For category based
  void navigateToCatgoryListScreenForCategory(int index,
      int sectionIndex) async {
    SectionDTO sectionDTO = sectionDTOList[sectionIndex];

    if (sectionDTO != null && sectionDTO.menuDTO != null &&
        sectionDTO.menuDTO.categoryNameMap != null &&
        sectionDTO.menuDTO.categoryNameMap.length > 0) {
      List<Object> object = new List();
      var entriesList = sectionDTO.menuDTO.categoryLocationMap.entries.toList();
      List<LocationDTO> locationDTOList;
      if (entriesList != null && entriesList.length > 0)
        locationDTOList = entriesList[index].value;

      LocationDTO locationDTO;
      if (locationDTOList != null && locationDTOList.length > 0)
        locationDTO = locationDTOList[0];

      if (locationDTO == null) {
        showOutletNotAvailablePopUp(context, buildOutletNotAvailable());
        return;
      }
      var catList = sectionDTO.menuDTO.categoryNameMap.entries.toList();
      String categorName = catList[index].value;

      object.add(locationDTO.displayName ?? locationDTO.name);
      object.add(locationDTO);
      Map<int, List<ProductDTO>> cartData = cartItems[locationDTO.name +
          locationDTO.id.toString()];
      object.add(cartData);
      object.add(categorName);
      //    print('navigateToCatgoryListScreenForCategory : Category name : $categorName');
      var result = await Navigator.pushNamed(
          context, RouteConstants.newcategoryListingRoute,
          arguments: object);

      if (result != null) {
        Map<int, List<ProductDTO>> cartData = result;
        cartItems[locationDTO.name + locationDTO.id.toString()] = cartData;
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) => scroll());
    try {
      //Upgrade
      String appcastURL = globals.appcastURL;
      final cfg =
      AppcastConfiguration(url: appcastURL, supportedOS: ['android']);
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        //drawer: buildDrawer(customerName),
        body: WillPopScope(
          onWillPop: () async {
            backButtonCounter++;
            if (backButtonCounter == 2) {
              backButtonCounter = 0;
              MinimizeApp.minimizeApp();
            }
            Future.value(false);
          },
          child: isLoading
              ? (INTERNET_STATUS == true
              ? AninmatedLoader()
              : NoInternetScreen(
            function: () {
              getLocationFromGoogle();
            },
          ))
              : GestureDetector(onPanUpdate: (details) async {
            if (details.delta.dy > 0 && downSwipe == false) {
              downSwipe = true;
              //      print("Dragging in +Y direction");
              orderNotificationMap = new Map();
              //Rest the notification order index
              currentNotificationOrderIndex = 0;
              this.coordinates =
              new Coordinates(
                  this.position.latitude, this.position.longitude);
              await getLocationFromGoogle();
              Timer(Duration(seconds: 2), () {
                //      print('Updated downSwipe to false');
                downSwipe = false;
              });
            }
          },
              child: Container(
                  color: Colors.white,
                  //MainTopMenuColor
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                              flex: 8,
                              child: GestureDetector(
                                  onTap: () async {
                                    print('On Click 5...');
                                    print('Location tapped');
                                    backButtonCounter = 0;
                                    var result = await Navigator.pushNamed(
                                        context,
                                        RouteConstants.searchLocationRoute);
                                    CurrentLocationDTO currentLocationDTO =
                                        result;
                                    //  print('Returnd from search location page pincode : ${currentLocationDTO.pincode}');

                                    if (currentLocationDTO != null) {
                                      if (currentLocationDTO.subLocality !=
                                          null &&
                                          currentLocationDTO.coordinates !=
                                              null) {
                                        if (currentLocationDTO.subLocality !=
                                            this.subLocality) {
                                          this.pincode =
                                              currentLocationDTO.pincode;

                                          await getContentList(
                                              currentLocationDTO
                                                  .coordinates.latitude,
                                              currentLocationDTO.coordinates
                                                  .longitude);
                                          setState(() {
                                            this.subLocality =
                                                currentLocationDTO
                                                    .subLocality;
                                            this.pincode =
                                                currentLocationDTO.pincode;
                                            this.subAdminArea =
                                                currentLocationDTO.subAdminArea;
                                            this.adminArea =
                                                currentLocationDTO.adminArea;
                                            this.position = new Position(
                                                latitude: currentLocationDTO
                                                    .coordinates.latitude,
                                                longitude: currentLocationDTO
                                                    .coordinates.longitude);
                                            SharedPreferenceService
                                                .addStringToSF(
                                                Constants.subLocality,
                                                this.subLocality);
                                            SharedPreferenceService
                                                .addDoubleToSF(
                                                Constants.geoLocationLatitude,
                                                this.position.latitude);
                                            SharedPreferenceService
                                                .addDoubleToSF(
                                                Constants
                                                    .geoLocationLongitude,
                                                this.position.longitude);
                                          });
                                        }
                                      }
                                    }
                                  },
                                  child: Container(
                                    height: 50,
                                    margin: EdgeInsets.only(
                                        top: 40 , left: 10),
                                    //  color: Colors.yellow,
                                    child: Row(
                                        children: [
                                          Align(
                                            alignment: Alignment.topCenter,
                                            child: Container(
                                              width: 45,
                                              height: 35,
                                              child:Image.asset('images/icons/Location.png'),
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: <Widget>[
                                              //Customer name
                                              Container(
                                                key: _subLocalityKey,
                                                child: Text(subLocality != null
                                                    ? subLocality
                                                    : '',
                                                    /* allTranslations
                                                      .text('NewOutlet_Hello') +
                                                      (customerName != null
                                                          ? customerName
                                                          : ''),*/
                                                    style: const TextStyle(
                                                        color: const Color(
                                                            0xff283550),
                                                        fontWeight: FontWeight
                                                            .w600,
                                                        fontFamily: "Montserrat",
                                                        fontStyle: FontStyle
                                                            .normal,
                                                        fontSize: 15.0),
                                                    textAlign: TextAlign.left),
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Container(
                                                      margin: EdgeInsets.only(
                                                          top: 3),
                                                      child: Text(
                                                          "${subAdminArea != null
                                                              ? subAdminArea
                                                              : ''} , ${adminArea !=
                                                              null
                                                              ? adminArea
                                                              : ''}",
                                                          overflow:
                                                          TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                              color: const Color(
                                                                  0xff83888c),
                                                              fontWeight:
                                                              FontWeight.w500,
                                                              fontFamily: "Poppins",
                                                              fontStyle:
                                                              FontStyle.normal,
                                                              fontSize: 12.0),
                                                          textAlign: TextAlign
                                                              .left)),
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        top: 6,
                                                        left: 3),
                                                    child: SvgPicture.asset(
                                                      bottomDownArrowImage,
                                                      width: 8,
                                                      height: 8,
                                                      color: globals.themecolor,
                                                      placeholderBuilder: (
                                                          context) =>
                                                          Center(
                                                              child:
                                                              CircularProgressIndicator()),
                                                    ),
                                                  ),
                                                  //Down arrow image
                                                  /* Container(
                                                    padding: EdgeInsets.only(
                                                        top: 8),
                                                    child: SvgPicture.asset(
                                                      bottomDownArrowImage,
                                                      width: 8,
                                                      height: 8,
                                                      color: globals.themecolor,
                                                      placeholderBuilder: (
                                                          context) =>
                                                          Center(
                                                              child:
                                                              CircularProgressIndicator()),
                                                    ),
                                                  )*/
                                                ],
                                              )
                                            ],
                                          ),
                                        ]
                                    ),
                                  ))),
                          Expanded(
                              flex: 2,
                              child: Container(
                                // color: Colors.green,
                                  margin: EdgeInsets.only(top: 40, right: 7),
                                  child: Container(
                                      width: 39,
                                      height: 39,
                                      alignment: Alignment.topRight,
                                      child: Stack(
                                        children: <Widget>[
                                          Positioned(
                                              child: new Align(
                                                  alignment:
                                                  FractionalOffset.topRight,
                                                  child: GestureDetector(
                                                      onTap: () async {
                                                        print('On Click 6...');
                                                        var res = await Navigator
                                                            .pushNamed(
                                                            context,
                                                            RouteConstants
                                                                .newprofileRoute);
                                                        if (res == null) {
                                                          // print(
                                                          //     'get running orders called');

                                                          //                 await getRunningOrders();
                                                          setState(() {
                                                            isLoading = false;
                                                          });
                                                        }
                                                      },
                                                      child: Container(
                                                          margin:
                                                          EdgeInsets.only(
                                                              right: 5,
                                                              top: 5),
                                                          /* width: 55,
                                                        height: 55,*/
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              print('On Click 7...');
                                                              //     print('Search ontap called');
                                                              List<Object> list = new List();
                                                              list.add(sectionDTOList);
                                                              list.add(
                                                                  this.position.latitude);
                                                              list.add(
                                                                  this.position.longitude);
                                                              list.add(this.pincode);
                                                              Navigator.pushNamed(context, RouteConstants.searchNewoutletAndProducts, arguments: list);
                                                            },
                                                            child: SvgPicture.asset(
                                                                searchImage,
                                                                height: 25,
                                                                width: 25),
                                                          )
                                                      )))),
                                        ],
                                      )))),
                          //search box
                        ],
                      ),
                      // globals.enableHomeFilter == true ?
                      // Row(
                      //   //color: globals.homebacknear;
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   children: <Widget>[
                      //     /*  Expanded(
                      //       flex: 100,
                      //       child: Container(
                      //         // color: globals.homebacknear,
                      //         margin: EdgeInsets.only(
                      //             left: 16, top: 7, bottom: 7,right: 10),
                      //         height: 45,
                      //         decoration: BoxDecoration(
                      //             borderRadius:
                      //             BorderRadius.all(Radius.circular(8)),
                      //             color: const Color(0xffF2F1F1)),
                      //         child: Container(
                      //             child: Row(
                      //               mainAxisAlignment: MainAxisAlignment
                      //                   .start,
                      //               children: <Widget>[
                      //                 Expanded(
                      //                     flex: 13,
                      //                     child: Container(
                      //                         padding: EdgeInsets.only(
                      //                             left: 15),
                      //                         alignment: Alignment.centerLeft,
                      //                         child: SvgPicture.asset(
                      //                           searchImage,
                      //                           width: 15,
                      //                           height: 15,
                      //                         ))),
                      //                 Expanded(
                      //                     flex: 85,
                      //                     child: GestureDetector(
                      //                       onTap: () {
                      //                         print('On Click 7...');
                      //                         //     print('Search ontap called');
                      //                         List<Object> list = new List();
                      //                         list.add(sectionDTOList);
                      //                         list.add(
                      //                             this.position.latitude);
                      //                         list.add(
                      //                             this.position.longitude);
                      //                         list.add(this.pincode);
                      //                         // print(' lat : ${this.position
                      //                         //     .latitude} : Lng : ${this
                      //                         //     .position.longitude}');
                      //                         Navigator.pushNamed(
                      //                             context,
                      //                             RouteConstants
                      //                                 .searchNewoutletAndProducts,
                      //                             arguments: list);
                      //                       },
                      //                       child: Container(
                      //                           padding: EdgeInsets.only(
                      //                               left: 7),
                      //                           child: Text(allTranslations
                      //                               .text('NewOutlet_search'),
                      //                             style: const TextStyle(
                      //                               color: const Color(
                      //                                   0xffbdbdbd),),
                      //                           )),
                      //                     )
                      //                 )],
                      //             )),
                      //       ),
                      //     ),*/
                      //     Spacer(
                      //       flex: 2,
                      //     ),
                      //   ],
                      // ) :
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: <Widget>[
                      //     Expanded(
                      //         child:
                      //         Container(
                      //             height: 41,
                      //             margin: EdgeInsets.only(
                      //                 right: 16, left: 16, top: 24),
                      //             decoration: BoxDecoration(
                      //                 borderRadius:
                      //                 BorderRadius.all(Radius.circular(8)),
                      //                 color: const Color(0xfff3f3f2)),
                      //             child: Row(
                      //               mainAxisAlignment: MainAxisAlignment
                      //                   .center,
                      //               children: <Widget>[
                      //                 Expanded(
                      //                     flex: 15,
                      //                     child: Container(
                      //                         padding: EdgeInsets.only(
                      //                             left: 10),
                      //                         alignment: Alignment.centerLeft,
                      //                         child: SvgPicture.asset(
                      //                           searchImage,
                      //                           width: 15,
                      //                           height: 15,
                      //                         ))),
                      //                 Expanded(
                      //                   flex: 85,
                      //                   child: GestureDetector(
                      //                       onTap: () {
                      //                         print('On Click 9...');
                      //                         //    print('Search ontap called');
                      //                         List<Object> list = new List();
                      //                         list.add(sectionDTOList);
                      //                         list.add(
                      //                             this.position.latitude);
                      //                         list.add(
                      //                             this.position.longitude);
                      //                         list.add(this.pincode);
                      //                         Navigator.pushNamed(
                      //                             context,
                      //                             RouteConstants
                      //                                 .searchNewoutletAndProducts,
                      //                             arguments: list);
                      //                       },
                      //                       child: Container(
                      //                         child: Text(allTranslations
                      //                             .text('NewOutlet_search')),
                      //                       )),
                      //                 )
                      //               ],
                      //             )))
                      //
                      //   ],
                      // ),
                      if (sectionDTOList != null &&
                          sectionDTOList.length > 0)
                        Expanded(
                            child: Container(
                              color: globals.homebacknear,
                              //color: Colors.yellow,
                              child: CustomScrollView(slivers: <Widget>[
                                for (int i = 0; i <
                                    sectionDTOList.length; i++)
                                  buildSlivers(i),
                              ]),
                            ))
                      else
                        buildNoOperationWidget()

                    ],
                  ))),
        ),

        // bottomNavigationBar: isLoading == false
        //     ? buildOrderNotificationPanel()
        //     : Container(
        //   width: 0,
        //   height: 0,
        // ),
      );
    } catch (e, s) {
      print('$e   :: $s');
    }
  }


  Widget buildNoOperationWidget() {
    return Expanded(child: Container(
      //margin: EdgeInsets.only(top: 25),
      //color : Colors.blue,
        child: ListView(
          padding: EdgeInsets.only(top: 0),
          children: <Widget>[

            Container(
              margin: EdgeInsets.only(left: 62.7, right: 63, top: 25),
              height: 213.4,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              // color : Colors.yellow,
              decoration: new BoxDecoration(
                  image: new DecorationImage(
                      image: new AssetImage(noOperationImage),
                      fit: BoxFit.fill)),
            ),
            Container(
                margin: EdgeInsets.only(top: 30.5, right: 34, left: 35),
                child: Text(
                    allTranslations.text('newoutlet_nolocation_service'),
                    style: const TextStyle(
                        color: const Color(0xff383846),
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                        fontStyle: FontStyle.normal,
                        fontSize: 12.0
                    ),
                    textAlign: TextAlign.center
                )
            ),
            Center(child:

            GestureDetector(
                onTap: () async {
                  print('On Click 9...');
                  var result = await Navigator.pushNamed(
                      context,
                      RouteConstants.searchLocationRoute);
                  CurrentLocationDTO currentLocationDTO =
                      result;
                  if (currentLocationDTO != null) {
                    if (currentLocationDTO.subLocality !=
                        null &&
                        currentLocationDTO.coordinates !=
                            null) {
                      if (currentLocationDTO.subLocality !=
                          this.subLocality) {
                        await getContentList(
                            currentLocationDTO
                                .coordinates.latitude,
                            currentLocationDTO.coordinates
                                .longitude);
                        setState(() {
                          this.subLocality =
                              currentLocationDTO
                                  .subLocality;
                          this.position = new Position(
                              latitude: currentLocationDTO
                                  .coordinates.latitude,
                              longitude: currentLocationDTO
                                  .coordinates.longitude);
                          SharedPreferenceService
                              .addStringToSF(
                              Constants.subLocality,
                              this.subLocality);
                          SharedPreferenceService
                              .addDoubleToSF(
                              Constants.geoLocationLatitude,
                              this.position.latitude);
                          SharedPreferenceService
                              .addDoubleToSF(
                              Constants
                                  .geoLocationLongitude,
                              this.position.longitude);
                        });
                      }
                    }
                  }
                },
                child:
                Container(
                    width: 127,
                    height: 45,
                    margin: EdgeInsets.only(top: 36),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(8)
                        ),
                        border: Border.all(
                            color: const Color(0xfff5ae34),
                            width: 1
                        )
                    ),
                    child: Center(child: Text(
                        allTranslations.text(
                            'newoutlet_nolocation_editlocation'),
                        style: const TextStyle(
                            color: const Color(0xfff5ae34),
                            fontWeight: FontWeight.w500,
                            fontFamily: "Poppins",
                            fontStyle: FontStyle.normal,
                            fontSize: 12.0
                        ),
                        textAlign: TextAlign.center
                    ))
                )))


          ],
        )
    ));
  }

  Widget buildSlivers(int i) {
    // print(
    //     ' buildSlivers : Section dto length ${sectionDTOList
    //         .length} : section id : ${sectionDTOList[i]
    //         .id}  : Section type : ${sectionDTOList[i].sectionType}');
    if (sectionDTOList[i].sectionType != SectionType.PRODUCT_LISTING_GRID &&
        sectionDTOList[i].sectionType !=
            SectionType.PRODUCT_CATEGORY_MULTI_GRID &&
        sectionDTOList[i].sectionType !=
            SectionType.CATEGORY_THREE_GRID && sectionDTOList[i].sectionType !=
        SectionType.CATEGORY_TWO_GRID && sectionDTOList[i].sectionType !=
        SectionType.PRODUCT_CATEGORY_TWO_GRID &&
        sectionDTOList[i].sectionType !=
            SectionType.PRODUCT_CATEGORY_THREE_GRID)
      return SliverList(delegate: SliverChildListDelegate(getWidgetList(i)));
    //Multi grid heaader
    else if (sectionDTOList[i].sectionType ==
        SectionType.PRODUCT_CATEGORY_MULTI_GRID &&
        sectionDTOList[i].menuDTO != null &&
        sectionDTOList[i].menuDTO.categoryNameMap != null &&
        sectionDTOList[i].menuDTO.categoryNameMap.length > 0)
      return getMultiGridHeader(i);

    //Category three grid - used for tag aggregator only
    else if (sectionDTOList[i].sectionType ==
        SectionType.CATEGORY_THREE_GRID &&
        sectionDTOList[i].tagDtoList != null &&
        sectionDTOList[i].tagDtoList.length > 0) {
      // print(
      //     'TAG DTO length three grid : ${sectionDTOList[i].tagDtoList.length}');
      return getThreeGridHeader(i);
      //category two grid used for tag - aggregator only
    } else if (sectionDTOList[i].sectionType ==
        SectionType.CATEGORY_TWO_GRID &&
        sectionDTOList[i].tagDtoList != null &&
        sectionDTOList[i].tagDtoList.length > 0) {
      //print('TAG DTO length two grid : ${sectionDTOList[i].tagDtoList.length}');
      return getTwoGridHeader(i);
      //product category three grid used for individual customer only
    } else if (sectionDTOList[i].sectionType ==
        SectionType.PRODUCT_CATEGORY_THREE_GRID &&
        sectionDTOList[i].menuDTO != null &&
        sectionDTOList[i].menuDTO.categoryNameMap != null &&
        sectionDTOList[i].menuDTO.categoryNameMap.length > 0) {
      print(
          'MENU DTO length three grid ');
      return getProductCategoryThreeGridHeader(i);
    } else if (sectionDTOList[i].sectionType ==
        SectionType.PRODUCT_CATEGORY_TWO_GRID &&
        sectionDTOList[i].menuDTO != null &&
        sectionDTOList[i].menuDTO.categoryNameMap != null &&
        sectionDTOList[i].menuDTO.categoryNameMap.length > 0) {
      print(
          'MENU DTO length two grid :');
      return getProductCategoryTwoGridHeader(i);
    }

    else {
      List<Widget> emptyList = new List();
      emptyList.add(Container());
      return SliverList(delegate: SliverChildListDelegate(emptyList));
    }
  }

  Widget getTwoGridHeader(int sectionIndex) {
    print('Building two grid ');
    if (sectionDTOList[sectionIndex].tagDtoList != null &&
        sectionDTOList[sectionIndex].tagDtoList.length > 0) {
      return SliverToBoxAdapter(
          child: Column(
            children: <Widget>[
              Visibility(
                  visible: getHeaderVisibility(sectionDTOList[sectionIndex]),
                  child:
                  Container(
                    padding: EdgeInsets.only(
                        left: sectionDTOList[sectionIndex]
                            .headerNameLeftPadding ?? 15,
                        top: sectionDTOList[sectionIndex]
                            .headerNameTopPadding ?? 10,
                        right: sectionDTOList[sectionIndex]
                            .headerNameRightPadding ?? 0,
                        bottom: sectionDTOList[sectionIndex]
                            .headerNameBottomPadding ?? 10),
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    color: Colors.white,
                    child: Text(
                        sectionDTOList[sectionIndex].displayName != null
                            ? sectionDTOList[sectionIndex].displayName
                            : '',
                        style: TextStyle(
                            color: const Color(0xff0f0f0f),
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins",
                            fontStyle: FontStyle.normal,
                            fontSize: sectionDTOList[sectionIndex]
                                .headerFontSize ??
                                15.0),
                        textAlign: TextAlign.left),
                  )),
              sectionDTOList[sectionIndex].boundedSectionHeight == null ?
              Container(
                  child:
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio:
                        Util.getWidth(sectionDTOList[sectionIndex], context) /
                            Util.getHeight(
                                sectionDTOList[sectionIndex], context)),
                    itemBuilder: (context, index) =>
                        buildCategoryGridView(context, index, sectionIndex),
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: sectionDTOList[sectionIndex].tagDtoList
                        .length,
                  ))
                  :
              Container(
                  height: sectionDTOList[sectionIndex].boundedSectionHeight,
                  child:
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio:
                        Util.getWidth(sectionDTOList[sectionIndex], context) /
                            Util.getHeight(
                                sectionDTOList[sectionIndex], context)),
                    itemBuilder: (context, index) =>
                        buildCategoryGridView(context, index, sectionIndex),
                    shrinkWrap: false,
                    physics: ScrollPhysics(),
                    itemCount: sectionDTOList[sectionIndex].tagDtoList
                        .length,
                  ))
            ],
          ));
    } else {
      return Container();
    }
  }

  Widget getProductCategoryTwoGridHeader(int sectionIndex) {
    print('Building two grid ');
    if (sectionDTOList[sectionIndex].menuDTO != null &&
        sectionDTOList[sectionIndex].menuDTO.categoryNameMap.length > 0) {
      int itemCount = (sectionDTOList[sectionIndex].menuDTO != null &&
          sectionDTOList[sectionIndex].menuDTO.categoryNameMap != null)
          ? sectionDTOList[sectionIndex].menuDTO.categoryNameMap
          .length
          : 0;
      return SliverToBoxAdapter(
          child: Column(
            children: <Widget>[
              Visibility(
                  visible: getHeaderVisibility(sectionDTOList[sectionIndex]),
                  child:
                  Container(
                    padding: EdgeInsets.only(
                        left: sectionDTOList[sectionIndex]
                            .headerNameLeftPadding ?? 15,
                        top: sectionDTOList[sectionIndex]
                            .headerNameTopPadding ?? 10,
                        right: sectionDTOList[sectionIndex]
                            .headerNameRightPadding ?? 0,
                        bottom: sectionDTOList[sectionIndex]
                            .headerNameBottomPadding ?? 10),
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    color: Colors.white,
                    child: Text(
                        sectionDTOList[sectionIndex].displayName != null
                            ? sectionDTOList[sectionIndex].displayName
                            : '',
                        style: TextStyle(
                            color: const Color(0xff0f0f0f),
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins",
                            fontStyle: FontStyle.normal,
                            fontSize: sectionDTOList[sectionIndex]
                                .headerFontSize ??
                                15.0),
                        textAlign: TextAlign.left),
                  )),
              sectionDTOList[sectionIndex].boundedSectionHeight == null ?
              Container(
                  child:
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio:
                        Util.getWidth(sectionDTOList[sectionIndex], context) /
                            Util.getHeight(
                                sectionDTOList[sectionIndex], context)),
                    itemBuilder: (context, index) =>
                        buildProductCategoryGridView(
                            context, index, sectionIndex),
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: itemCount,
                  ))
                  :
              Container(
                  height: sectionDTOList[sectionIndex].boundedSectionHeight,
                  child:
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio:
                        Util.getWidth(sectionDTOList[sectionIndex], context) /
                            Util.getHeight(
                                sectionDTOList[sectionIndex], context)),
                    itemBuilder: (context, index) =>
                        buildProductCategoryGridView(
                            context, index, sectionIndex),
                    shrinkWrap: false,
                    physics: ScrollPhysics(),
                    itemCount: itemCount,
                  ))
            ],
          ));
    } else {
      return Container();
    }
  }

  //Multi grid header
  Widget getMultiGridHeader(int sectionIndex) {
    // print('Building getMultiGridHeader grid ');
    if (sectionDTOList[sectionIndex].menuDTO != null &&
        sectionDTOList[sectionIndex].menuDTO.categoryNameMap != null &&
        sectionDTOList[sectionIndex].menuDTO.categoryNameMap.length > 0) {
      int itemCount = (sectionDTOList[sectionIndex].menuDTO != null &&
          sectionDTOList[sectionIndex].menuDTO.categoryNameMap != null)
          ? sectionDTOList[sectionIndex].menuDTO.categoryNameMap
          .length
          : 0;
      return SliverToBoxAdapter(
          child: Column(
              children: <Widget>[
                Visibility(
                    visible: getHeaderVisibility(sectionDTOList[sectionIndex]),
                    child:
                    Container(
                      margin: EdgeInsets.only(
                          left: sectionDTOList[sectionIndex]
                              .headerNameLeftPadding ?? 15,
                          top: sectionDTOList[sectionIndex]
                              .headerNameTopPadding ?? 10,
                          right: sectionDTOList[sectionIndex]
                              .headerNameRightPadding ?? 0,
                          bottom: sectionDTOList[sectionIndex]
                              .headerNameBottomPadding ?? 10),
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      color: Colors.white,
                      child: Text(
                          sectionDTOList[sectionIndex].displayName != null
                              ? sectionDTOList[sectionIndex].displayName
                              : '',
                          style: TextStyle(
                              color: const Color(0xff0f0f0f),
                              fontWeight: FontWeight.w600,
                              fontFamily: "Poppins",
                              fontStyle: FontStyle.normal,
                              fontSize: sectionDTOList[sectionIndex]
                                  .headerFontSize ??
                                  15.0),
                          textAlign: TextAlign.left),
                    )),
                sectionDTOList[sectionIndex].boundedSectionHeight == null ?
                Container(
                    child:
                    StaggeredGridView.countBuilder(
                      crossAxisCount: sectionDTOList[sectionIndex]
                          .gridCrossaxisCount ?? 4,
                      itemCount: itemCount,
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      padding: EdgeInsets.only(top: 0),
                      mainAxisSpacing: sectionDTOList[sectionIndex]
                          .gridMainAxisSpacing ?? 5,
                      crossAxisSpacing: sectionDTOList[sectionIndex]
                          .gridCrossAxisSpacing ?? 5,
                      itemBuilder: (context, index) {
                        return _buildMultiGridProduct(
                            context, sectionIndex, index);
                      },
                      staggeredTileBuilder: (index) {
                        return StaggeredTile.fit(1);
                      },
                    ))
                    :
                Container(
                    height: sectionDTOList[sectionIndex].boundedSectionHeight,
                    child:
                    StaggeredGridView.countBuilder(
                      crossAxisCount: sectionDTOList[sectionIndex]
                          .gridCrossaxisCount ?? 4,
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      itemCount: itemCount,
                      mainAxisSpacing: sectionDTOList[sectionIndex]
                          .gridMainAxisSpacing ?? 5,
                      crossAxisSpacing: sectionDTOList[sectionIndex]
                          .gridCrossAxisSpacing ?? 5,
                      itemBuilder: (context, index) {
                        return _buildMultiGridProduct(
                            context, sectionIndex, index);
                      },
                      staggeredTileBuilder: (index) {
                        return StaggeredTile.fit(1);
                      },
                    ))
              ]));
    } else {
      return Container();
    }
  }

  bool getHeaderVisibility(SectionDTO sectionDTO) {
    if (sectionDTO.displayName != null) {
      return true;
    }
    return false;
  }

  Widget _buildMultiGridProduct(BuildContext context, int sectionIndex,
      int index) {
    SectionDTO sectionDTO = sectionDTOList[sectionIndex];

    var entryList;
    int categoryId;
    if (sectionDTO.menuDTO != null &&
        sectionDTO.menuDTO.categoryNameMap != null &&
        sectionDTO.menuDTO.categoryNameMap.length > 0) {
      entryList = sectionDTO.menuDTO.categoryNameMap.entries.toList();
      String temp = entryList[index].key;
      categoryId = int.parse(temp);
    }
    else
      return Container();

    return GestureDetector(
        onTap: () {
          print('On Click 10...');
          navigateToCatgoryListScreenForCategory(index, sectionIndex);
        },
        child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  //                   <--- left side
                  color: Colors.grey[50],
                  width: 1.5,
                ),
                bottom: BorderSide(
                  //                   <--- left side
                  color: Colors.grey[50],
                  width: 1.5,
                ),
              ),
            ),
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.start,
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                (sectionDTO.width == null) ?
                Container(
                    margin: EdgeInsets.only(top: sectionDTO.top ?? 0,
                        bottom: sectionDTO.bottom ?? 0,
                        left: sectionDTO.left ?? 0,
                        right: sectionDTO.right ?? 0),
                    height: sectionDTO.height ?? 50,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    child: Image(
                        fit: BoxFit.fill,
                        image: AdvancedNetworkImage(
                          globals.imageBaseUrl +
                              '/api/v1/onlineapp/customer/getcategoryimage/$categoryId',
                          loadedCallback: () => print('It works!'),
                          loadFailedCallback: () => print('Oh, no!'),
                          useDiskCache: true,
                          cacheRule:
                          CacheRule(maxAge: const Duration(days: 7)),
                          // loadingProgress: (double progress, _) => print(progress),
                          timeoutDuration: Duration(seconds: 30),
                          retryLimit: 3,
                          // disableMemoryCache: true,
                        ))
                )
                    :
                Container(
                    margin: EdgeInsets.only(top: sectionDTO.top ?? 0,
                        bottom: sectionDTO.bottom ?? 0,
                        left: sectionDTO.left ?? 0,
                        right: sectionDTO.right ?? 0),
                    height: sectionDTO.height ?? 50,
                    width: sectionDTO.width ?? 50,
                    child: Image(
                        fit: BoxFit.fill,
                        image: AdvancedNetworkImage(
                          globals.imageBaseUrl +
                              '/api/v1/onlineapp/customer/getcategoryimage/$categoryId',
                          loadedCallback: () => print('It works!'),
                          loadFailedCallback: () => print('Oh, no!'),
                          useDiskCache: true,
                          cacheRule:
                          CacheRule(maxAge: const Duration(days: 7)),
                          // loadingProgress: (double progress, _) => print(progress),
                          timeoutDuration: Duration(seconds: 30),
                          retryLimit: 3,
                          // disableMemoryCache: true,
                        ))
                ),
                //Category name
                Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                        entryList[index].value ?? '',
                        style: TextStyle(
                            color: const Color(0xff383846),
                            fontWeight: FontWeight.w500,
                            fontFamily: "Poppins",
                            fontStyle: FontStyle.normal,
                            fontSize: sectionDTO.itemLabelFontsize != null
                                ? sectionDTO.itemLabelFontsize.toDouble()
                                :
                            12.0
                        ),
                        textAlign: TextAlign.center
                    )
                )
              ],
            )
        ));
  }

  Widget getThreeGridHeader(int sectionIndex) {
    print('Building three grid ');
    if (sectionDTOList[sectionIndex].tagDtoList != null &&
        sectionDTOList[sectionIndex].tagDtoList.length > 0) {
      return SliverToBoxAdapter(
          child: Column(
            children: <Widget>[
              Visibility(
                  visible: getHeaderVisibility(sectionDTOList[sectionIndex]),
                  child:
                  Container(
                    padding: EdgeInsets.only(
                        left: sectionDTOList[sectionIndex]
                            .headerNameLeftPadding ?? 15,
                        top: sectionDTOList[sectionIndex]
                            .headerNameTopPadding ?? 10,
                        right: sectionDTOList[sectionIndex]
                            .headerNameRightPadding ?? 0,
                        bottom: sectionDTOList[sectionIndex]
                            .headerNameBottomPadding ?? 10),
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    color: Colors.white,
                    child: Text(
                        sectionDTOList[sectionIndex].displayName != null
                            ? sectionDTOList[sectionIndex].displayName
                            : '',
                        style: TextStyle(
                            color: const Color(0xff0f0f0f),
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins",
                            fontStyle: FontStyle.normal,
                            fontSize: sectionDTOList[sectionIndex]
                                .headerFontSize ??
                                15.0),
                        textAlign: TextAlign.left),
                  )),
              sectionDTOList[sectionIndex].boundedSectionHeight == null ?
              Container(
                  child:
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio:
                        Util.getWidth(sectionDTOList[sectionIndex], context) /
                            Util.getHeight(
                                sectionDTOList[sectionIndex], context)),
                    itemBuilder: (context, index) =>
                        buildCategoryGridView(context, index, sectionIndex),
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: sectionDTOList[sectionIndex].tagDtoList
                        .length,
                  ))
                  :
              Container(
                  height: sectionDTOList[sectionIndex].boundedSectionHeight,
                  child:
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio:
                        Util.getWidth(sectionDTOList[sectionIndex], context) /
                            Util.getHeight(
                                sectionDTOList[sectionIndex], context)),
                    itemBuilder: (context, index) =>
                        buildCategoryGridView(context, index, sectionIndex),
                    shrinkWrap: false,
                    physics: ScrollPhysics(),
                    itemCount: sectionDTOList[sectionIndex].tagDtoList
                        .length,
                  ))
            ],
          ));
    } else {
      return Container();
    }
  }

  Widget getProductCategoryThreeGridHeader(int sectionIndex) {
    print('Building three grid for product category');
    if (sectionDTOList[sectionIndex].menuDTO != null &&
        sectionDTOList[sectionIndex].menuDTO.categoryNameMap.length > 0) {
      int itemCount = (sectionDTOList[sectionIndex].menuDTO != null &&
          sectionDTOList[sectionIndex].menuDTO.categoryNameMap != null)
          ? sectionDTOList[sectionIndex].menuDTO.categoryNameMap
          .length
          : 0;
      return SliverToBoxAdapter(
          child: Column(
            children: <Widget>[
              Visibility(
                  visible: getHeaderVisibility(sectionDTOList[sectionIndex]),
                  child:
                  Container(
                    padding: EdgeInsets.only(
                        left: sectionDTOList[sectionIndex]
                            .headerNameLeftPadding ?? 15,
                        top: sectionDTOList[sectionIndex]
                            .headerNameTopPadding ?? 10,
                        right: sectionDTOList[sectionIndex]
                            .headerNameRightPadding ?? 0,
                        bottom: sectionDTOList[sectionIndex]
                            .headerNameBottomPadding ?? 10),
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    color: Colors.white,
                    child: Text(
                        sectionDTOList[sectionIndex].displayName != null
                            ? sectionDTOList[sectionIndex].displayName
                            : '',
                        style: TextStyle(
                            color: const Color(0xff0f0f0f),
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins",
                            fontStyle: FontStyle.normal,
                            fontSize: sectionDTOList[sectionIndex]
                                .headerFontSize ??
                                15.0),
                        textAlign: TextAlign.left),
                  )),
              sectionDTOList[sectionIndex].boundedSectionHeight == null ?
              Container(
                  child:
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio:
                        Util.getWidth(sectionDTOList[sectionIndex], context) /
                            Util.getHeight(
                                sectionDTOList[sectionIndex], context)),
                    itemBuilder: (context, index) =>
                        buildProductCategoryGridView(
                            context, index, sectionIndex),
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: itemCount,
                  ))
                  :
              Container(
                  height: sectionDTOList[sectionIndex].boundedSectionHeight,
                  child:
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio:
                        Util.getWidth(sectionDTOList[sectionIndex], context) /
                            Util.getHeight(
                                sectionDTOList[sectionIndex], context)),
                    itemBuilder: (context, index) =>
                        buildProductCategoryGridView(
                            context, index, sectionIndex),
                    shrinkWrap: false,
                    physics: ScrollPhysics(),
                    itemCount: itemCount,
                  ))
            ],
          ));
    } else {
      return Container();
    }
  }

  Widget getGridHeader(int sectionIndex) {
    print('Building grid ');
    if (sectionDTOList[sectionIndex].menuDTO.menuItems != null &&
        sectionDTOList[sectionIndex].menuDTO.menuItems.length > 0) {
      return SliverToBoxAdapter(
          child: Column(
            children: <Widget>[
              Visibility(
                  visible: getHeaderVisibility(sectionDTOList[sectionIndex]),
                  child:
                  Container(
                    padding: EdgeInsets.only(
                        left: sectionDTOList[sectionIndex]
                            .headerNameLeftPadding ?? 15,
                        top: sectionDTOList[sectionIndex]
                            .headerNameTopPadding ?? 10,
                        right: sectionDTOList[sectionIndex]
                            .headerNameRightPadding ?? 0,
                        bottom: sectionDTOList[sectionIndex]
                            .headerNameBottomPadding ?? 10),
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    color: Colors.white,
                    child: Text(
                        sectionDTOList[sectionIndex].displayName != null
                            ? sectionDTOList[sectionIndex].displayName
                            : '',
                        style: TextStyle(
                            color: const Color(0xff0f0f0f),
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins",
                            fontStyle: FontStyle.normal,
                            fontSize: sectionDTOList[sectionIndex]
                                .headerFontSize ??
                                15.0),
                        textAlign: TextAlign.left),
                  )),
              sectionDTOList[sectionIndex].boundedSectionHeight == null ?
              Container(
                  child:
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio:
                        Util.getWidth(sectionDTOList[sectionIndex], context) /
                            Util.getHeight(
                                sectionDTOList[sectionIndex], context)),
                    itemBuilder: (context, index) =>
                        buildGridView(context, index, sectionIndex),
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: sectionDTOList[sectionIndex].menuDTO.menuItems
                        .length,
                  ))
                  :
              Container(
                  height: sectionDTOList[sectionIndex].boundedSectionHeight,
                  child:
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio:
                        Util.getWidth(sectionDTOList[sectionIndex], context) /
                            Util.getHeight(
                                sectionDTOList[sectionIndex], context)),
                    itemBuilder: (context, index) =>
                        buildGridView(context, index, sectionIndex),
                    shrinkWrap: false,
                    physics: ScrollPhysics(),
                    itemCount: sectionDTOList[sectionIndex].menuDTO.menuItems
                        .length,
                  ))
            ],
          ));
    } else {
      return Container();
    }
  }


  List<Widget> getWidgetList(int sectionIndex) {
    Widget widget = buildSections(sectionIndex);
    List<Widget> listItems = List();
    listItems.add(widget);
    return listItems;
  }


  //Used for both two grid and thre grid layouts - for tags
  Widget buildCategoryGridView(BuildContext context, int index,
      int sectionIndex) {
    print('buildCategoryGridView called $index $sectionIndex');
    SectionDTO sectionDTO = sectionDTOList[sectionIndex];

    return GestureDetector(
        onTap: () {
          print('On Click 11...');
          print('on tap called');
          navigateToCatgoryListScreenForTags(index, sectionIndex);
        },
        child: Container(
            child: Column(
              children: <Widget>[
                //Image
                Container(
                    width: 91,
                    height: 71,
                    /* decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(39)
                        ),
                        boxShadow: [BoxShadow(
                            color: const Color(0x29000000),
                            offset: Offset(0, 3),
                            blurRadius: 6,
                            spreadRadius: 0
                        )
                        ]
                    ),*/
                    child: ClipRRect(
                      /* borderRadius: BorderRadius.all(
                            Radius.circular(39)),*/
                        child: Image(
                            fit: BoxFit.fill,
                            image: AdvancedNetworkImage(
                              globals.imageBaseUrl +
                                  sectionDTO.tagDtoList[index].iconUrl,
                              loadedCallback: () => print('It works!'),
                              loadFailedCallback: () => print('Oh, no!'),
                              useDiskCache: true,
                              cacheRule:
                              CacheRule(maxAge: const Duration(days: 7)),
                              // loadingProgress: (double progress, _) => print(progress),
                              timeoutDuration: Duration(seconds: 30),
                              retryLimit: 3,
                              // disableMemoryCache: true,
                            )))
                ),
                //Category Name
                Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                        sectionDTO.tagDtoList[index].name ?? '',
                        style: const TextStyle(
                            color: const Color(0xff383846),
                            fontWeight: FontWeight.w500,
                            fontFamily: "Poppins",
                            fontStyle: FontStyle.normal,
                            fontSize: 12.0
                        ),
                        textAlign: TextAlign.center
                    )
                )
              ],
            )
        ));
  }

  //Used for both two grid and three grid layouts - for product category
  Widget buildProductCategoryGridView(BuildContext context, int index,
      int sectionIndex) {
    print('buildProductCategoryGridView called $index $sectionIndex');
    SectionDTO sectionDTO = sectionDTOList[sectionIndex];

    var entryList;
    int categoryId;
    if (sectionDTO.menuDTO != null &&
        sectionDTO.menuDTO.categoryNameMap != null &&
        sectionDTO.menuDTO.categoryNameMap.length > 0) {
      entryList = sectionDTO.menuDTO.categoryNameMap.entries.toList();
      String temp = entryList[index].key;
      categoryId = int.parse(temp);
    }
    else
      return Container();

    return GestureDetector(
        onTap: () {
          print('On Click 12...');
          navigateToCatgoryListScreenForCategory(index, sectionIndex);
        },
        child: Container(
            child: Column(
              children: <Widget>[
                //Image
                Container(
                    width: 91,
                    height: 71,
                    /* decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(39)
                        ),
                        boxShadow: [BoxShadow(
                            color: const Color(0x29000000),
                            offset: Offset(0, 3),
                            blurRadius: 6,
                            spreadRadius: 0
                        )
                        ]
                    ),*/
                    child: ClipRRect(
                      /* borderRadius: BorderRadius.all(
                            Radius.circular(39)),*/
                        child: Image(
                            fit: BoxFit.fill,
                            image: AdvancedNetworkImage(
                              globals.imageBaseUrl +
                                  '/api/v1/onlineapp/customer/getcategoryimage/$categoryId',
                              loadedCallback: () => print('It works!'),
                              loadFailedCallback: () => print('Oh, no!'),
                              useDiskCache: true,
                              cacheRule:
                              CacheRule(maxAge: const Duration(days: 7)),
                              // loadingProgress: (double progress, _) => print(progress),
                              timeoutDuration: Duration(seconds: 30),
                              retryLimit: 3,
                              // disableMemoryCache: true,
                            )))
                ),
                //Category Name
                Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                        entryList[index].value ?? '',
                        style: const TextStyle(
                            color: const Color(0xff383846),
                            fontWeight: FontWeight.w500,
                            fontFamily: "Poppins",
                            fontStyle: FontStyle.normal,
                            fontSize: 12.0
                        ),
                        textAlign: TextAlign.center
                    )
                )
              ],
            )
        ));
  }

  Widget buildGridView(BuildContext context, int index, int sectionIndex) {
    print('buildGridView called $index $sectionIndex');
    SectionDTO sectionDTO = sectionDTOList[sectionIndex];
    MenuDTO menuDTO = sectionDTOList[sectionIndex].menuDTO;
    ProductDTO productDTO = menuDTO.menuItems[index].product;
    LocationDTO locationDTO;
    if (menuDTO.locationIdList != null && menuDTO.locationIdList.length > 0)
      locationDTO = menuDTO.locationIdList[0];
    return Container(
        margin: EdgeInsets.only(
            left: sectionDTO.left ?? 10,
            right: sectionDTO.right ?? 0,
            top: sectionDTO.top ?? 10,
            bottom: sectionDTO.bottom ?? 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
            Widget>[
          ColorFiltered(
              colorFilter: productDTO.availability != false &&
                  locationDTO != null &&
                  locationDTO.availability != false
                  ? ColorFilter.mode(
                Colors.transparent,
                BlendMode.multiply,
              )
                  : ColorFilter.mode(
                Colors.grey,
                BlendMode.saturation,
              ),
              child: GestureDetector(
                  onTap: () {
                    print('On Click 13...');
                    print('On tap called on category $index $sectionIndex');
                    navigateToCatgoryListScreenForTags(index, sectionIndex);
                  },
                  child: Container(
                      width: Util.getWidth(
                          sectionDTOList[sectionIndex], context) ??
                          163,
                      height: Util.getWidth(
                          sectionDTOList[sectionIndex], context) ??
                          280,
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.white),
                          color: const Color(0xfff7f7f7),
                          borderRadius: BorderRadius.circular(5.0)),
                      child: FittedBox(
                          fit: BoxFit.fill,
                          child: Image(
                              image: AdvancedNetworkImage(
                                globals.imageBaseUrl +
                                    '/image/product/${productDTO.id}',
                                loadedCallback: () => print('It works!'),
                                loadFailedCallback: () => print('Oh, no!'),
                                useDiskCache: true,
                                cacheRule:
                                CacheRule(maxAge: const Duration(days: 7)),
                                // loadingProgress: (double progress, _) => print(progress),
                                timeoutDuration: Duration(seconds: 30),
                                retryLimit: 3,
                                // disableMemoryCache: true,
                              )))))),
          Container(
              margin: EdgeInsets.only(top: 8),
              // color: const Color(0xfff7f7f7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                          flex: 1,
                          child: Container(
                              padding: EdgeInsets.only(top: 2.5),

                              child: Image(image: getvegOrNonveg(productDTO)))),
                      Expanded(
                          flex: 9,
                          child: Container(
                              width: Util.getWidth(
                                  sectionDTOList[sectionIndex], context) ??
                                  69,
                              margin: EdgeInsets.only(left: 5),
                              padding: EdgeInsets.only(top: 2),

                              child: Text(productDTO.name,
                                  style: const TextStyle(
                                      color: const Color(0xff283550),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Poppins",
                                      fontStyle: FontStyle.normal,
                                      fontSize: 12.0),
                                  textAlign: TextAlign.left)))
                    ],
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      width: Util.getWidth(sectionDTO, context),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            height: 15,
                            width: 33,
                            margin: EdgeInsets.only(right: 5),
                            decoration: BoxDecoration(
                              color: globals.themecolor,
                              borderRadius:
                              BorderRadius.all(Radius.circular(30)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Container(
                                  child: Text('4.9',
                                      style: const TextStyle(
                                          color: const Color(0xffffffff),
                                          fontWeight: FontWeight.w500,
                                          fontFamily: "Montserrat",
                                          fontStyle: FontStyle.normal,
                                          fontSize: 8.0),
                                      textAlign: TextAlign.left),
                                ),
                                Container(
                                  child: Icon(
                                    Icons.star,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Text(locationDTO.cusineType ?? '',
                                style: const TextStyle(
                                    color: const Color(0xff283550),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "Poppins",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 8.0),
                                textAlign: TextAlign.left),
                          ),
                        ],
                      )),
                  Container(
                      margin: EdgeInsets.only(bottom: 10),
                      width: Util.getWidth(sectionDTO, context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                              flex: 5,
                              child: Container(
                                child: Text(globals.currencySymbol +
                                    Util.formatNumber(
                                        menuDTO.menuItems[index].productPrice)),
                              )),
                          Expanded(
                              flex: 5,
                              child: productDTO.availability == true
                                  ? GestureDetector(
                                  onTap: () {
                                    print('On Click 14...');
                                    navigateToProductListPageFromProduct(
                                        index, sectionIndex, productDTO.id);
                                  },
                                  child: Container(
                                      width: 60,
                                      height: 26,
                                      child: Center(
                                          child: Text(
                                              allTranslations
                                                  .text('NewOutlet_Add'),
                                              style: const TextStyle(
                                                  color:
                                                  const Color(0xffffffff),
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: "Poppins",
                                                  fontStyle: FontStyle.normal,
                                                  fontSize: 11.0),
                                              textAlign: TextAlign.right)),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4)),
                                          color: const Color(0xff66b111))))
                                  : Container(
                                  height: 30,
                                  width: 80,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(4)),
                                      color: Colors.red),
                                  padding:
                                  EdgeInsets.only(left: 5, right: 5,),
                                  child: Center(
                                      child: Text(
                                        productDTO.nextAvailableAt ?? '',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: "Poppins",
                                            fontStyle: FontStyle.normal,
                                            fontSize: 9.0),
                                        textAlign: TextAlign.center,
                                      ))))
                        ],
                      ))
                ],
              ))
        ]));
  }

  Widget buildSections(int sectionIndex) {
    SectionDTO sectionDTO = sectionDTOList[sectionIndex];
    MenuDTO menuDTO = sectionDTOList[sectionIndex].menuDTO;
    List<GenericDTO> menuItems = menuDTO != null ? menuDTO.menuItems : null;

    // print(
    //     'Section dto top :${sectionDTO.top} bottom : ${sectionDTO
    //         .bottom} left : ${sectionDTO.left} Right : ${sectionDTO.right} ');
    // print(
    //     'Section dto bounded section height :${sectionDTO
    //         .boundedSectionHeight}  ');
    //
    // print(
    //     'Section dto Pixel Type Height :${sectionDTO
    //         .pixelTypeHeight}  Pixel Type Width : ${sectionDTO
    //         .pixelTypeWidth}   ');

    if (sectionDTO.sectionType == SectionType.RESTURANT_LISTING
        && sectionDTO.locationDtoList != null &&
        sectionDTO.locationDtoList.length > 0) {
      // print(
      //     'RESTURANT_LISTING  :sectionDTOList[_selectedSectionNumber].locationDtoList length ${sectionDTOList[sectionIndex]
      //         .locationDtoList.length}');
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Visibility(
                visible: sectionDTOList[sectionIndex].locationDtoList != null &&
                    sectionDTOList[sectionIndex].locationDtoList.length > 0,
                child:

                Visibility(
                    visible: getHeaderVisibility(sectionDTOList[sectionIndex]),
                    child: Container(
                      color: globals.homebacknear,
                      //color: Colors.yellow,
                      padding: EdgeInsets.only(
                          left: sectionDTOList[sectionIndex]
                              .headerNameLeftPadding ?? 15,
                          right: sectionDTOList[sectionIndex]
                              .headerNameRightPadding ?? 5,
                          top: sectionDTOList[sectionIndex]
                              .headerNameTopPadding ?? 10,
                          bottom: sectionDTOList[sectionIndex]
                              .headerNameBottomPadding ?? 14),
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      //color: Colors.white,
                      child: Text(
                          sectionDTOList[sectionIndex].displayName != null
                              ? sectionDTOList[sectionIndex].displayName
                              : '',
                          style: TextStyle(
                              color: const Color(0xff0f0f0f),
                              fontWeight: FontWeight.w600,
                              fontFamily: "Poppins",
                              fontStyle: FontStyle.normal,
                              fontSize: sectionDTOList[sectionIndex]
                                  .headerFontSize ?? 15.0),
                          textAlign: TextAlign.left),
                    ))),
            sectionDTO.boundedSectionHeight == null ?
            Container(
                child:
                ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 0.0),
                    physics: ScrollPhysics(),
                    scrollDirection: getScrollDirection(sectionDTO),
                    itemCount: sectionDTOList[sectionIndex].locationDtoList ==
                        null
                        ? 0
                        : sectionDTOList[sectionIndex].locationDtoList.length,
                    itemBuilder: (context, index) =>
                        _restaurantItemBuilder(
                            context, index, sectionIndex, 1)))
                :
            Container(
                height: 270,
                child:
                ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 0.0),
                    physics: ScrollPhysics(),
                    scrollDirection: getScrollDirection(sectionDTO),
                    itemCount: sectionDTOList[sectionIndex].locationDtoList ==
                        null
                        ? 0
                        : sectionDTOList[sectionIndex].locationDtoList.length,
                    itemBuilder: (context, index) =>
                        _restaurantItemBuilder(
                            context, index, sectionIndex, 2)))
          ]);
    } else if (sectionDTO.sectionType == SectionType.MEDIA &&
        sectionDTO.sectionContentList != null &&
        sectionDTO.sectionContentList.length > 0) {
      ScrollController _mediaScrollController = ScrollController();
      print(
          ' MEDIA: sectionContentList length ${sectionDTOList[sectionIndex]
              .sectionContentList.length}');
      _mediaScrollControllerMap[sectionIndex] = _mediaScrollController;
      return Visibility(
          visible: !_searchStarted,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Visibility(
                    visible: getHeaderVisibility(sectionDTOList[sectionIndex]),
                    child:
                    Container(
                        padding: EdgeInsets.only(
                            left: sectionDTOList[sectionIndex]
                                .headerNameLeftPadding ?? 15,
                            right: sectionDTOList[sectionIndex]
                                .headerNameRightPadding ?? 5,
                            top: sectionDTOList[sectionIndex]
                                .headerNameTopPadding ?? 10,
                            bottom: sectionDTOList[sectionIndex]
                                .headerNameBottomPadding ?? 14),
                        //color: Color(0xfff7f7f7),
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        child: Text(
                            sectionDTOList[sectionIndex].displayName != null
                                ? sectionDTOList[sectionIndex].displayName
                                : '',
                            style: TextStyle(
                                color: const Color(0xff000000),
                                fontWeight: FontWeight.w500,
                                fontFamily: "Roboto",
                                fontStyle: FontStyle.normal,
                                fontSize: sectionDTOList[sectionIndex]
                                    .headerFontSize ?? 15.0),
                            textAlign: TextAlign.left))),
                Container(
                  height:
                  sectionDTOList[sectionIndex].boundedSectionHeight ?? 150,
                  padding: EdgeInsets.only(
                      top: sectionDTOList[sectionIndex].top ?? 10,
                      left: sectionDTOList[sectionIndex].left ?? 15,
                      right: sectionDTOList[sectionIndex].right ?? 0,
                      bottom: sectionDTOList[sectionIndex].bottom ?? 0),
                  //color: Color(0xfff7f7f7),
                  child: ListView.builder(
                      scrollDirection: getScrollDirection(sectionDTO),
                      controller: _mediaScrollController,
                      itemCount:
                      sectionDTOList[sectionIndex].sectionContentList ==
                          null
                          ? 0
                          : sectionDTOList[sectionIndex]
                          .sectionContentList
                          .length,
                      itemBuilder: (context, index) =>
                          mediaItemBuilder(context, index, sectionIndex)),
                )
              ]));
    } else if ((sectionDTO.sectionType ==
        SectionType.PRODUCT_LISTING_NOADDBTN ||
        sectionDTO.sectionType == SectionType.PRODUCT_LISTING_ADDBTN) &&
        menuDTO != null &&
        menuItems != null &&
        menuItems.length > 0) {
      double defaultBoundedHeight = 150;
      if (sectionDTO.sectionType == SectionType.PRODUCT_LISTING_NOADDBTN)
        defaultBoundedHeight = 150;
      else if (sectionDTO.sectionType == SectionType.PRODUCT_LISTING_ADDBTN)
        defaultBoundedHeight = 275;

      print(
          ' PRODUCT: menuDTO length ${sectionDTOList[sectionIndex].menuDTO
              .menuItems.length}');
      return Visibility(
          visible: !_searchStarted && getHeaderVisibility(sectionDTO),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                        flex: 8,
                        child: Container(
                            padding: EdgeInsets.only(
                                left: sectionDTOList[sectionIndex]
                                    .headerNameLeftPadding ?? 15,
                                right: sectionDTOList[sectionIndex]
                                    .headerNameRightPadding ?? 5,
                                top: sectionDTOList[sectionIndex]
                                    .headerNameTopPadding ?? 10,
                                bottom: sectionDTOList[sectionIndex]
                                    .headerNameBottomPadding ?? 14),
                            // color: Color(0xfff7f7f7),
                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
                            child: Text(
                                sectionDTOList[sectionIndex].displayName != null
                                    ? sectionDTOList[sectionIndex].displayName
                                    : '',
                                style: TextStyle(
                                    color: const Color(0xff000000),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "Roboto",
                                    fontStyle: FontStyle.normal,
                                    fontSize: sectionDTOList[sectionIndex]
                                        .headerFontSize ?? 15.0),
                                textAlign: TextAlign.left))),
                    Expanded(
                        flex: 2,
                        child: Visibility(visible: false, child: Container(
                          // color: Color(0xfff7f7f7),
                          padding: EdgeInsets.only(top: 14),
                          child: Text(allTranslations.text('NewOutlet_ViewAll'),
                              style: const TextStyle(
                                  color: const Color(0xff909194),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Poppins",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 12.0),
                              textAlign: TextAlign.left),
                        )))
                  ],
                ),
                Container(
                  height: sectionDTOList[sectionIndex].boundedSectionHeight ??
                      defaultBoundedHeight,
                  padding: EdgeInsets.only(
                      top: sectionDTOList[sectionIndex].top ?? 10,
                      left: sectionDTOList[sectionIndex].left ?? 15,
                      right: sectionDTOList[sectionIndex].right ?? 0,
                      bottom: sectionDTOList[sectionIndex].bottom ?? 0),
                  //color: Color(0xfff7f7f7),
                  child: ListView.builder(
                      scrollDirection: getScrollDirection(sectionDTO),
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) =>
                          buildProudctList(
                              context, index, sectionIndex, sectionDTO)),
                )
              ]));
    } else if ((sectionDTO.sectionType ==
        SectionType.PRODUCT_LISTING_SINGLE_IMG) &&
        menuDTO != null &&
        menuItems != null &&
        menuItems.length > 0) {
      double defaultBoundedHeight;
      // print(
      //     ' PRODUCT: menuDTO length ${sectionDTOList[sectionIndex].menuDTO
      //         .menuItems.length}');
      return Visibility(
          visible: !_searchStarted && getHeaderVisibility(sectionDTO),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                        flex: 8,
                        child: Container(
                            padding: EdgeInsets.only(
                                left: sectionDTOList[sectionIndex]
                                    .headerNameLeftPadding ?? 15,
                                right: sectionDTOList[sectionIndex]
                                    .headerNameRightPadding ?? 5,
                                top: sectionDTOList[sectionIndex]
                                    .headerNameTopPadding ?? 10,
                                bottom: sectionDTOList[sectionIndex]
                                    .headerNameBottomPadding ?? 14),
                            // color: Color(0xfff7f7f7),
                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
                            child: Text(
                                sectionDTOList[sectionIndex].displayName != null
                                    ? sectionDTOList[sectionIndex].displayName
                                    : '',
                                style: TextStyle(
                                    color: const Color(0xff000000),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "Roboto",
                                    fontStyle: FontStyle.normal,
                                    fontSize: sectionDTOList[sectionIndex]
                                        .headerFontSize ?? 15.0),
                                textAlign: TextAlign.left))),
                    Expanded(
                        flex: 2,
                        child: Visibility(visible: false, child: Container(
                          padding: EdgeInsets.only(
                              top: sectionDTOList[sectionIndex].top ?? 15),
                          child: Text(allTranslations.text('NewOutlet_ViewAll'),
                              style: const TextStyle(
                                  color: const Color(0xff909194),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Poppins",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 12.0),
                              textAlign: TextAlign.left),
                        )))
                  ],
                ),
                sectionDTO.boundedSectionHeight == null ?
                Container(
                  padding: EdgeInsets.only(
                      top: sectionDTOList[sectionIndex].top ?? 10,
                      left: sectionDTOList[sectionIndex].left ?? 15,
                      right: sectionDTOList[sectionIndex].right ?? 0,
                      bottom: sectionDTOList[sectionIndex].bottom ?? 0),
                  //  color: Color(0xfff7f7f7),
                  child: ListView.builder(
                      scrollDirection: getScrollDirection(sectionDTO),
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      padding: EdgeInsets.only(top: 0.0),
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) =>
                          buildProudctList(
                              context, index, sectionIndex, sectionDTO)),
                )
                    :
                Container(
                  height: sectionDTO.boundedSectionHeight,
                  padding: EdgeInsets.only(
                      top: sectionDTOList[sectionIndex].top ?? 10,
                      left: sectionDTOList[sectionIndex].left ?? 15,
                      right: sectionDTOList[sectionIndex].right ?? 0,
                      bottom: sectionDTOList[sectionIndex].bottom ?? 0),
                  //  color: Color(0xfff7f7f7),
                  child: ListView.builder(
                      scrollDirection: getScrollDirection(sectionDTO),
                      shrinkWrap: false,
                      physics: ScrollPhysics(),
                      padding: EdgeInsets.only(top: 0.0),
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) =>
                          buildProudctList(
                              context, index, sectionIndex, sectionDTO)),
                )
              ]));
    } else if (sectionDTO.sectionType == SectionType.CATEGORY &&
        sectionDTO.tagDtoList != null &&
        sectionDTO.tagDtoList.length > 0) {
      return Visibility(
          visible: !_searchStarted && getHeaderVisibility(sectionDTO),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(
                      left: sectionDTOList[sectionIndex]
                          .headerNameLeftPadding ?? 15,
                      right: sectionDTOList[sectionIndex]
                          .headerNameRightPadding ?? 5,
                      top: sectionDTOList[sectionIndex]
                          .headerNameTopPadding ?? 10,
                      bottom: sectionDTOList[sectionIndex]
                          .headerNameBottomPadding ?? 14),
                  //  color: Color(0xfff7f7f7),
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: Text(
                      sectionDTOList[sectionIndex].displayName != null
                          ? sectionDTOList[sectionIndex].displayName
                          : '',
                      style: TextStyle(
                          color: const Color(0xff000000),
                          fontWeight: FontWeight.w500,
                          fontFamily: "Roboto",
                          fontStyle: FontStyle.normal,
                          fontSize: sectionDTOList[sectionIndex]
                              .headerFontSize ?? 15.0),
                      textAlign: TextAlign.left)),
              Container(
                // color: Color(0xfff7f7f7),
                height:
                sectionDTOList[sectionIndex].boundedSectionHeight ?? 100,
                padding: EdgeInsets.only(
                    left: sectionDTOList[sectionIndex].left ?? 15,
                    top: sectionDTOList[sectionIndex].top ?? 10,
                    right: sectionDTOList[sectionIndex].right ?? 0,
                    bottom: sectionDTOList[sectionIndex].bottom ?? 0),
                child: Align(
                    alignment: Alignment.center,
                    child: ListView.builder(
                        scrollDirection: getScrollDirection(sectionDTO),
                        itemCount: sectionDTOList[sectionIndex].tagDtoList ==
                            null
                            ? 0
                            : sectionDTOList[sectionIndex].tagDtoList.length,
                        itemBuilder: (context, index) =>
                            categoryItemBuilder(context, index, sectionIndex))),
              )
            ],
          ));
    } else {
      return Container(
        color: Color(0xfff7f7f7),
      );
    }
  }

  Widget buildProudctList(BuildContext context, int index, int sectionIndex,
      SectionDTO sectionDTO) {
    if (sectionDTO.sectionType == SectionType.PRODUCT_LISTING_NOADDBTN)
      return productItemHorizontalBuilderWithNOAddBtn(
          context, index, sectionIndex);
    else if (sectionDTO.sectionType == SectionType.PRODUCT_LISTING_ADDBTN)
      return productItemHorizontalBuilderWithAddBtn(
          context, index, sectionIndex);
    else if (sectionDTO.sectionType == SectionType.PRODUCT_LISTING_SINGLE_IMG)
      return productItemHorizontalBuilderSingleImage(
          context, index, sectionIndex);
  }

  Axis getScrollDirection(SectionDTO sectionDTO) {
    if (sectionDTO.displayType == DisplayType.HORIZONTAL_SLIDER)
      return Axis.horizontal;
    else
      return Axis.vertical;
  }

  //With Add button single image vertical
  Widget productItemHorizontalBuilderSingleImage(BuildContext context,
      int index, int sectionIndex) {
    SectionDTO sectionDTO = sectionDTOList[sectionIndex];
    MenuDTO menuDTO = sectionDTOList[sectionIndex].menuDTO;
    ProductDTO productDTO = menuDTO.menuItems[index].product;
    LocationDTO locationDTO;
    if (menuDTO.locationIdList != null && menuDTO.locationIdList.length > 0)
      locationDTO = menuDTO.locationIdList[0];

    return Row(children: <Widget>[
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        ColorFiltered(
            colorFilter: productDTO.availability != false &&
                locationDTO != null &&
                locationDTO.availability != false
                ? ColorFilter.mode(
              Colors.transparent,
              BlendMode.multiply,
            )
                : ColorFilter.mode(
              Colors.grey,
              BlendMode.saturation,
            ),
            child: GestureDetector(
                onTap: () {
                  print('On Click 15...');
                  // print('On tap called on category $index $sectionIndex');
                  // navigateToProductListPageFromProduct(
                  //     index, sectionIndex, productDTO.id);
                },
                child: Container(
                    width:
                    Util.getWidth(sectionDTOList[sectionIndex], context) ??
                        342,
                    height:
                    Util.getHeight(sectionDTOList[sectionIndex], context) ??
                        155,
                    //height: 69,
                    //width: 69,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.white),
                        color: Util.getRandomColor(),
                        borderRadius: BorderRadius.circular(5.0)),
                    child: FittedBox(
                        fit: BoxFit.fill,
                        child: Image(
                            image: AdvancedNetworkImage(
                              globals.imageBaseUrl +
                                  '/image/product/${productDTO.id}',
                              loadedCallback: () => print('It works!'),
                              loadFailedCallback: () => print('Oh, no!'),
                              useDiskCache: true,
                              cacheRule:
                              CacheRule(maxAge: const Duration(days: 7)),
                              // loadingProgress: (double progress, _) => print(progress),
                              timeoutDuration: Duration(seconds: 30),
                              retryLimit: 3,
                              // disableMemoryCache: true,
                            )))))),
        Container(
            margin: EdgeInsets.only(top: 8),
            // color: const Color(0xfff7f7f7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.only(top: 4),
                        child: Image(image: getvegOrNonveg(productDTO))),
                    Container(
                        width: Util.getWidth(
                            sectionDTOList[sectionIndex], context) ??
                            69,
                        margin: EdgeInsets.only(left: 5),
                        child: Text(productDTO.name,
                            style: const TextStyle(
                                color: const Color(0xff283550),
                                fontWeight: FontWeight.w500,
                                fontFamily: "Poppins",
                                fontStyle: FontStyle.normal,
                                fontSize: 12.0),
                            textAlign: TextAlign.left))
                  ],
                ),
                Container(
                    margin: EdgeInsets.only(top: 5, bottom: 5),
                    width: Util.getWidth(sectionDTO, context),
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: 15,
                          width: 33,
                          margin: EdgeInsets.only(right: 5),
                          decoration: BoxDecoration(
                            color: globals.themecolor,
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                child: Text('4.9',
                                    style: const TextStyle(
                                        color: const Color(0xffffffff),
                                        fontWeight: FontWeight.w500,
                                        fontFamily: "Montserrat",
                                        fontStyle: FontStyle.normal,
                                        fontSize: 8.0),
                                    textAlign: TextAlign.left),
                              ),
                              Container(
                                child: Icon(
                                  Icons.star,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        //Spacer(),
                        Container(
                          child: Text(productDTO.categoryName ?? '',
                              style: const TextStyle(
                                  color: const Color(0xff283550),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Poppins",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 8.0),
                              textAlign: TextAlign.left),
                        ),
                        Spacer(flex: 9),
                        productDTO.availability == true
                            ?
                        GestureDetector(
                            onTap: () {
                              print('On Click 16...');
                              navigateToProductListPageFromProduct(
                                  index, sectionIndex, productDTO.id);
                            },
                            child:
                            Container(
                                width: 66,
                                height: 26,
                                child: Center(
                                    child: Text(
                                        allTranslations.text('NewOutlet_Add'),
                                        style: const TextStyle(
                                            color: const Color(0xffffffff),
                                            fontWeight: FontWeight.w500,
                                            fontFamily: "Poppins",
                                            fontStyle: FontStyle.normal,
                                            fontSize: 11.0),
                                        textAlign: TextAlign.right)),
                                decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                                    color: const Color(0xff66b111))))
                            : Container(
                            height: 30,
                            width: 100,
                            decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.all(Radius.circular(4)),
                                color: Colors.red),
                            padding: EdgeInsets.only(left: 5, right: 5),
                            child: Center(
                                child: Text(
                                  productDTO.nextAvailableAt ?? '',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Poppins",
                                      fontStyle: FontStyle.normal,
                                      fontSize: 9.0),
                                  textAlign: TextAlign.center,
                                )))
                      ],
                    )),
                Container(
                  margin: EdgeInsets.only(bottom: 5),
                  width: Util.getWidth(sectionDTO, context),
                  child: Text(globals.currencySymbol +
                      Util.formatNumber(menuDTO.menuItems[index].productPrice)),
                ),
              ],
            ))
      ]),
    ]);
  }

  //With Add button
  Widget productItemHorizontalBuilderWithAddBtn(BuildContext context, int index,
      int sectionIndex) {
    SectionDTO sectionDTO = sectionDTOList[sectionIndex];
    MenuDTO menuDTO = sectionDTOList[sectionIndex].menuDTO;
    ProductDTO productDTO = menuDTO.menuItems[index].product;

    LocationDTO locationDTO;
    if (menuDTO.locationIdList != null && menuDTO.locationIdList.length > 0)
      locationDTO = menuDTO.locationIdList[0];

    return Row(children: <Widget>[
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        ColorFiltered(
            colorFilter: productDTO.availability != false &&
                locationDTO != null &&
                locationDTO.availability != false
                ? ColorFilter.mode(
              Colors.transparent,
              BlendMode.multiply,
            )
                : ColorFilter.mode(
              Colors.grey,
              BlendMode.saturation,
            ),
            child: GestureDetector(
                onTap: () {
                  print('On Click 17...');
                  //      print('On tap called on category $index $sectionIndex');
                  navigateToProductListPageFromProduct(
                      index, sectionIndex, productDTO.id);
                },
                child: Container(
                    width:
                    Util.getWidth(sectionDTOList[sectionIndex], context) ??
                        163,
                    height:
                    Util.getHeight(sectionDTOList[sectionIndex], context) ??
                        124,
                    //height: 69,
                    //width: 69,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.white),
                        color: Util.getRandomColor(),
                        borderRadius: BorderRadius.circular(5.0)),
                    child: FittedBox(
                        fit: BoxFit.fill,
                        child: Image(
                            image: AdvancedNetworkImage(
                              globals.imageBaseUrl +
                                  '/image/product/${productDTO.id}',
                              loadedCallback: () => print('It works!'),
                              loadFailedCallback: () => print('Oh, no!'),
                              useDiskCache: true,
                              cacheRule:
                              CacheRule(maxAge: const Duration(days: 7)),
                              // loadingProgress: (double progress, _) => print(progress),
                              timeoutDuration: Duration(seconds: 30),
                              retryLimit: 3,
                              // disableMemoryCache: true,
                            )))))),
        Container(
            margin: EdgeInsets.only(top: 8),
            // color: const Color(0xfff7f7f7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.only(top: 4),
                        child: Image(image: getvegOrNonveg(productDTO))),
                    Container(
                        width: Util.getWidth(
                            sectionDTOList[sectionIndex], context) ??
                            69,
                        margin: EdgeInsets.only(left: 5),
                        child: Text(productDTO.name,
                            style: const TextStyle(
                                color: const Color(0xff283550),
                                fontWeight: FontWeight.w500,
                                fontFamily: "Poppins",
                                fontStyle: FontStyle.normal,
                                fontSize: 12.0),
                            textAlign: TextAlign.left))
                  ],
                ),
                Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    width: Util.getWidth(sectionDTO, context),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: 15,
                          width: 33,
                          margin: EdgeInsets.only(right: 5),
                          decoration: BoxDecoration(
                            color: globals.themecolor,
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                child: Text('4.9',
                                    style: const TextStyle(
                                        color: const Color(0xffffffff),
                                        fontWeight: FontWeight.w500,
                                        fontFamily: "Montserrat",
                                        fontStyle: FontStyle.normal,
                                        fontSize: 8.0),
                                    textAlign: TextAlign.left),
                              ),
                              Container(
                                child: Icon(
                                  Icons.star,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Text(productDTO.categoryName ?? '',
                              style: const TextStyle(
                                  color: const Color(0xff283550),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Poppins",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 8.0),
                              textAlign: TextAlign.left),
                        ),
                      ],
                    )),
                Container(
                    margin: EdgeInsets.only(bottom: 10),
                    width: Util.getWidth(sectionDTO, context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                            flex: 5,
                            child: Container(
                              child: Text(globals.currencySymbol +
                                  Util.formatNumber(
                                      menuDTO.menuItems[index].productPrice)),
                            )),
                        Expanded(
                            flex: 5,
                            child: productDTO.availability == true
                                ?
                            GestureDetector(
                                onTap: () {
                                  print('On Click 18...');
                                  navigateToProductListPageFromProduct(
                                      index, sectionIndex, productDTO.id);
                                },
                                child:
                                Container(
                                    width: 60,
                                    height: 26,
                                    child: Center(
                                        child: Text(
                                            allTranslations
                                                .text('NewOutlet_Add'),
                                            style: const TextStyle(
                                                color: const Color(0xffffffff),
                                                fontWeight: FontWeight.w500,
                                                fontFamily: "Poppins",
                                                fontStyle: FontStyle.normal,
                                                fontSize: 11.0),
                                            textAlign: TextAlign.right)),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4)),
                                        color: const Color(0xff66b111))))
                                : Container(
                                height: 30,
                                width: 100,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(4)),
                                    color: Colors.red),
                                padding: EdgeInsets.only(left: 5, right: 5),
                                child: Center(
                                    child: Text(
                                      productDTO.nextAvailableAt ?? '',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: "Poppins",
                                          fontStyle: FontStyle.normal,
                                          fontSize: 9.0),
                                      textAlign: TextAlign.center,
                                    ))))
                      ],
                    ))
              ],
            ))
      ]),
    ]);
  }

//With Add no Button
  Widget productItemHorizontalBuilderWithNOAddBtn(BuildContext context,
      int index, int sectionIndex) {
    SectionDTO sectionDTO = sectionDTOList[sectionIndex];
    MenuDTO menuDTO = sectionDTOList[sectionIndex].menuDTO;
    ProductDTO productDTO = menuDTO.menuItems[index].product;
    LocationDTO locationDTO;
    if (menuDTO.locationIdList != null && menuDTO.locationIdList.length > 0)
      locationDTO = menuDTO.locationIdList[0];

    return Row(children: <Widget>[
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        ColorFiltered(
            colorFilter: productDTO.availability != false &&
                locationDTO != null &&
                locationDTO.availability != false
                ? ColorFilter.mode(
              Colors.transparent,
              BlendMode.multiply,
            )
                : ColorFilter.mode(
              Colors.grey,
              BlendMode.saturation,
            ),
            child: GestureDetector(
                onTap: () {
                  print('On Click 19...');
                  // print('On tap called on category $index $sectionIndex');
                  // navigateToProductListPageFromProduct(
                  //     index, sectionIndex, productDTO.id);
                },
                child: Container(
                    width:
                    Util.getWidth(sectionDTOList[sectionIndex], context) ??
                        148,
                    height:
                    Util.getHeight(sectionDTOList[sectionIndex], context) ??
                        73,
                    //height: 69,
                    //width: 69,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.white),
                        color: Util.getRandomColor(),
                        borderRadius: BorderRadius.circular(5.0)),
                    child: FittedBox(
                        fit: BoxFit.fill,
                        child: Image(
                            image: AdvancedNetworkImage(
                              globals.imageBaseUrl +
                                  '/image/product/${productDTO.id}',
                              loadedCallback: () => print('It works!'),
                              loadFailedCallback: () => print('Oh, no!'),
                              useDiskCache: true,
                              cacheRule:
                              CacheRule(maxAge: const Duration(days: 7)),
                              // loadingProgress: (double progress, _) => print(progress),
                              timeoutDuration: Duration(seconds: 30),
                              retryLimit: 3,
                              // disableMemoryCache: true,
                            )))))),
        Container(
            margin: EdgeInsets.only(top: 8),
            //color: const Color(0xfff7f7f7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[

                    Container(
                        padding: EdgeInsets.only(top: 2.5),
                        child: Image(image: getvegOrNonveg(productDTO))),
                    Container(
                        width: Util.getWidth(
                            sectionDTOList[sectionIndex], context) ??
                            69,
                        margin: EdgeInsets.only(left: 5),
                        child: Text(productDTO.name,
                            style: const TextStyle(
                                color: const Color(0xff283550),
                                fontWeight: FontWeight.w500,
                                fontFamily: "Poppins",
                                fontStyle: FontStyle.normal,
                                fontSize: 10.0),
                            textAlign: TextAlign.left))
                  ],
                ),
                //Rating
                Container(
                    margin: EdgeInsets.only(top: 5),
                    width: Util.getWidth(sectionDTO, context),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                            flex: 10,
                            child: Container(
                              child: Text('4.9',
                                  style: const TextStyle(
                                      color: const Color(0xff283550),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Montserrat",
                                      fontStyle: FontStyle.normal,
                                      fontSize: 8.0),
                                  textAlign: TextAlign.left),
                            )),
                        Expanded(
                            flex: 40,
                            child: RatingBarIndicator(
                              rating: 4.75,
                              itemBuilder: (context, index) =>
                                  Icon(
                                    Icons.star,
                                    color: globals.themecolor,
                                  ),
                              itemCount: 5,
                              itemSize: 6.0,
                              direction: Axis.horizontal,
                            )),
                        //Product price
                        Expanded(
                            flex: 45,
                            child: Container(
                                child: Text(
                                    globals.currencySymbol +
                                        Util.formatNumber(menuDTO
                                            .menuItems[index].productPrice),
                                    overflow: TextOverflow.clip,
                                    style: const TextStyle(
                                        color: const Color(0xff283550),
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "Poppins",
                                        fontStyle: FontStyle.normal,
                                        fontSize: 10.0),
                                    textAlign: TextAlign.right)))
                      ],
                    ))
              ],
            ))
      ]),
      Container(
        width: 10,
      )
    ]);
  }


  AssetImage getvegOrNonveg(ProductDTO productDTO) {
    return productDTO.foodType == FoodType.VEG ? vegiconImage : nonvegiconImage;
  }

  Widget categoryItemBuilder(BuildContext context, int index,
      int sectionIndex) {
    return Row(children: <Widget>[
      Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
        GestureDetector(
            onTap: () {
              print('On Click 20...');
              // print('On tap called on category ${sectionDTOList[index].id}');
              // print('On tap called on category ${sectionDTOList[index].name}');
              // print('On tap called on category $sectionIndex');
              //More than one outlet case we need to filter only the outlets
              if (sectionDTOList[sectionIndex].locationDtoList != null &&
                  sectionDTOList[sectionIndex].locationDtoList.length > 1) {
                filterOutletByCategory(index, sectionIndex);
              } else {
                navigateToCatgoryListScreenForTags(index, sectionIndex);
              }
            },
            child: Container(
              width: Util.getWidth(sectionDTOList[sectionIndex], context) ?? 69,
              height: Util.getHeight(sectionDTOList[sectionIndex], context) ??
                  69,
              //height: 69,
              //width: 69,
              decoration: BoxDecoration(
                border: Border.all(width: 1.5, color: Colors.grey[200]),
                color: Util.getRandomColor(),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[200],
                    offset: const Offset(
                      3.0,
                      3.0,
                    ),
                    blurRadius: 5.0,
                    spreadRadius: 5.0,
                  ), ////BoxShadow
                  BoxShadow(
                    color: Colors.white,
                    offset: const Offset(0.0, 0.0),
                    blurRadius: 0.0,
                    spreadRadius: 0.0,
                  ),
                ],
                image: new DecorationImage(
                  image: NetworkImage(
                      '${globals.imageBaseUrl}${sectionDTOList[sectionIndex]
                          .tagDtoList[index].iconUrl}'),
                  fit: BoxFit.cover,
                ),
                //borderRadius: BorderRadius.circular(5.0)
              ),
            )),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(top: 8),
            child: Text(sectionDTOList[sectionIndex].tagDtoList[index].name,
                style: const TextStyle(
                  color: const Color(0xff000000),
                  fontWeight: FontWeight.bold,
                  fontFamily: "Roboto",
                  fontStyle: FontStyle.normal,
                  fontSize: 11.0,
                )),
          ),
        )
      ]),
      Container(
        width: 20,
      )
    ]);
  }

  Widget mediaItemBuilder(BuildContext context, int index, int sectionIndex) {
    print('mediaItemBuilder index $index : Section index $sectionIndex');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width:
              Util.getWidth(sectionDTOList[sectionIndex], context) ?? 287,
              height:
              Util.getHeight(sectionDTOList[sectionIndex], context) ?? 137,

              // margin: EdgeInsets.only(l),
              decoration: BoxDecoration(
                  color: getRandomColor(),
                  borderRadius: BorderRadius.circular(5.0)),
              child:
              GestureDetector(
                  onTap: () {
                    print('On Click 21...');
                    // _selectedCategory = categoryList[index];
                    //videoList = _selectedCategory.videoList;
                    setState(() {});
                  },
                  child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                      child: FittedBox(
                          fit: BoxFit.fill,
                          child: Image(
                              image: AdvancedNetworkImage(
                                globals.imageBaseUrl +
                                    sectionDTOList[sectionIndex]
                                        .sectionContentList[index]
                                        .contentUrl,
                                loadedCallback: () => print('It works!'),
                                loadFailedCallback: () => print('Oh, no!'),
                                useDiskCache: true,
                                cacheRule:
                                CacheRule(maxAge: const Duration(days: 7)),
                                // loadingProgress: (double progress, _) => print(progress),
                                timeoutDuration: Duration(seconds: 30),
                                retryLimit: 3,
                                // disableMemoryCache: true,
                              ))))),
            ),
            Container(
              width: 20,
            )
          ],
        ),
      ],
    );
  }


  Widget _restaurantItemBuilder(BuildContext context, int index,
      int sectionIndex, int enter) {
    print('restaurantItemBuilder index $index : width : ${sectionDTOList[sectionIndex].width} : Height ${sectionDTOList[sectionIndex].height}');
    //Horizonatal slider item builder for outlets lising
    if (sectionDTOList[sectionIndex].displayType ==
        DisplayType.HORIZONTAL_SLIDER) {
      print('EnterOnScroll   $enter');
      return GestureDetector(
        onTap: () {
          print('On Click 2...');
          navigateToProductListPage(index, sectionIndex);
          backButtonCounter = 0;
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 7,
          //shadowColor: Colors.grey.shade200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: Colors.grey.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ColorFiltered(
                colorFilter: sectionDTOList[sectionIndex]
                    .locationDtoList[index]
                    .availability !=
                    false
                    ? ColorFilter.mode(
                  Colors.transparent,
                  BlendMode.multiply,
                )
                    : ColorFilter.mode(
                  Colors.grey.shade50,
                  BlendMode.saturation,
                ),
                child: Container(
                  height: 150,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width / 2,
                  margin: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: const Color(0xff7c94b6),
                    image: new DecorationImage(
                      image: AdvancedNetworkImage(
                        globals.imageBaseUrl +
                            '/api/v1/onlineapp/customer/getoutletimage/${sectionDTOList[sectionIndex]
                                .locationDtoList[index]
                                .id}',
                        loadedCallback: () =>
                            print('It works!'),
                        loadFailedCallback: () =>
                            print('Oh, no!'),
                        useDiskCache: true,
                        cacheRule: CacheRule(
                            maxAge: const Duration(
                                days: 7)),
                        // loadingProgress: (double progress, _) => print(progress),
                        timeoutDuration:
                        Duration(seconds: 30),
                        retryLimit: 3,
                        // disableMemoryCache: true,
                      ),
                      //NetworkImage(''),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(
                      color: Colors.grey,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(5.0, 1.0, 0.0, 0.0),
                child: Text(
                  sectionDTOList[sectionIndex]
                      .locationDtoList[index]
                      .displayName ==
                      null
                      ? ' '
                      : sectionDTOList[sectionIndex]
                      .locationDtoList[index]
                      .displayName,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                      color: const Color(0xff283550),
                      fontWeight: FontWeight.w600,
                      fontFamily: "Poppins",
                      fontStyle: FontStyle.normal,
                      fontSize: 14.0),
                  textAlign: TextAlign.left,
                ),
                //Text(categories[index]['text'],overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(5.0, 3.0, 0.0, 0.0),
                child: Text(
                  sectionDTOList[sectionIndex]
                      .locationDtoList[index]
                      .cusineType ==
                      null
                      ? ' '
                      : sectionDTOList[sectionIndex]
                      .locationDtoList[index]
                      .cusineType,
                  style: const TextStyle(
                      color: const Color(0xff283550),
                      fontWeight: FontWeight.w500,
                      fontFamily: "Montserrat",
                      fontStyle: FontStyle.normal,
                      fontSize: 12.0),
                  textAlign: TextAlign.left,
                ),
                //Text('Approx Max 20 Min',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal),),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(5.0, 3.0, 0.0, 0.0),
                child: Text(
                  (globals
                      .enableOutletDeliveryTime == true
                      ? Util.getDeliveryTime(
                      sectionDTOList[sectionIndex]
                          .locationDtoList[index]
                          .deliveryTimeInMins)
                      : ''),

                  style: const TextStyle(
                      color: const Color(0xff8b92a0),
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins",
                      fontStyle: FontStyle.normal,
                      fontSize: 10.0),
                  textAlign: TextAlign.left,
                ),
              ),
              //Text('North Indian',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal),),),
              Container(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      5.0, 3.0, 0.0, 0.0),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.shade300,
                              offset: const Offset(1.0, 1.0),
                              blurRadius: 4.0,
                              spreadRadius: 0.5)
                        ],
                        gradient: LinearGradient(colors: [
                          Colors.deepOrange,
                          Colors.deepOrange.shade300

                        ])),
                    child: Text(
                        getHighestDiscount(
                            sectionDTOList[sectionIndex]
                                .locationDtoList[index]),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight
                                .w700,
                            fontFamily: "Poppins",
                            fontStyle: FontStyle
                                .normal,
                            fontSize: 10.0),
                        textAlign: TextAlign
                            .left),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Container(
        //   child: Column(
        //     children: [
        //       Container(
        //           padding: EdgeInsets.only(
        //               right: sectionDTOList[sectionIndex].right ?? 5,
        //               left: sectionDTOList[sectionIndex].left ?? 15,
        //               top: sectionDTOList[sectionIndex].top ?? 15,
        //               bottom:
        //               sectionDTOList[sectionIndex].bottom ?? 5),
        //           color: Colors.white,
        //           child: ColorFiltered(
        //               colorFilter: sectionDTOList[sectionIndex]
        //                   .locationDtoList[index]
        //                   .availability !=
        //                   false
        //                   ? ColorFilter.mode(
        //                 Colors.transparent,
        //                 BlendMode.multiply,
        //               )
        //                   : ColorFilter.mode(
        //                 Colors.grey,
        //                 BlendMode.saturation,
        //               ),
        //               child: Container(
        //                   child: Align(
        //                       alignment: Alignment.centerLeft,
        //                       child: Container(
        //                           width: Util.getWidth(
        //                               sectionDTOList[sectionIndex],
        //                               context) ??
        //                               90,
        //                           height: Util.getHeight(
        //                               sectionDTOList[sectionIndex],
        //                               context) ??
        //                               75,
        //                           color: getRandomColor(),
        //                           child: ClipRRect(
        //                               borderRadius: BorderRadius.all(
        //                                   Radius.circular(7)),
        //                               child: FittedBox(
        //                                   fit: BoxFit.fill, child: Image(
        //                                   image: AdvancedNetworkImage(
        //                                     globals.imageBaseUrl +
        //                                         '/api/v1/onlineapp/customer/getoutletimage/${sectionDTOList[sectionIndex]
        //                                             .locationDtoList[index]
        //                                             .id}',
        //                                     loadedCallback: () =>
        //                                         print('It works!'),
        //                                     loadFailedCallback: () =>
        //                                         print('Oh, no!'),
        //                                     useDiskCache: true,
        //                                     cacheRule: CacheRule(
        //                                         maxAge: const Duration(
        //                                             days: 7)),
        //                                     // loadingProgress: (double progress, _) => print(progress),
        //                                     timeoutDuration:
        //                                     Duration(seconds: 30),
        //                                     retryLimit: 3,
        //                                     // disableMemoryCache: true,
        //                                   ))))
        //
        //                       ))),)
        //       ),
        //       Container(
        //           margin: EdgeInsets.only(
        //               left: 10, bottom: 2),
        //           child: Text(
        //             sectionDTOList[sectionIndex]
        //                 .locationDtoList[index]
        //                 .displayName ==
        //                 null
        //                 ? ' '
        //                 : sectionDTOList[sectionIndex]
        //                 .locationDtoList[index]
        //                 .displayName,
        //             overflow: TextOverflow.clip,
        //             style: const TextStyle(
        //                 color: const Color(0xff283550),
        //                 fontWeight: FontWeight.w600,
        //                 fontFamily: "Poppins",
        //                 fontStyle: FontStyle.normal,
        //                 fontSize: 12.0),
        //             textAlign: TextAlign.left,
        //           ))
        //     ],
        //   ),
        // ),
      );
    } else {
      //Vertical slider
      // return GestureDetector(
      //   onTap: () {
      //     print('ok on Click1...');
      //     navigateToProductListPage(index, sectionIndex);
      //     backButtonCounter = 0;
      //   },
      //   child: Card(
      //       clipBehavior: Clip.antiAlias,
      //       elevation: 7,
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(10),
      //         side: BorderSide(
      //           color: Colors.grey.withOpacity(0.5),
      //           width: 1,
      //         ),
      //       ),
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: <Widget>[
      //         Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 Padding(
      //                   padding: const EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 0.0),
      //                   child: Text(
      //                       sectionDTOList[sectionIndex]
      //                           .locationDtoList[index]
      //                           .displayName ==
      //                           null
      //                           ? ''
      //                           : sectionDTOList[sectionIndex]
      //                           .locationDtoList[index]
      //                           .displayName,
      //                     overflow: TextOverflow.ellipsis,
      //                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      //                   ),
      //                 ),
      //                 Padding(
      //                   padding: const EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 0.0),
      //                   child: Text(
      //                     sectionDTOList[sectionIndex]
      //                         .locationDtoList[index]
      //                         .description ==
      //                         null
      //                         ? ' '
      //                         : sectionDTOList[sectionIndex]
      //                         .locationDtoList[index]
      //                         .description + (globals
      //                         .enableOutletDeliveryTime == true
      //                         ?
      //                     ' | ' + Util.getDeliveryTime(
      //                         sectionDTOList[sectionIndex]
      //                             .locationDtoList[index]
      //                             .deliveryTimeInMins)
      //                         : ''),
      //                     overflow: TextOverflow.ellipsis,
      //                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
      //                   ),
      //                 ),
      //               ],
      //             ),
      //             Column(
      //               crossAxisAlignment: CrossAxisAlignment.end,
      //               children: [
      //                 Padding(
      //                   padding: const EdgeInsets.fromLTRB(0.0, 5.0, 5.0, 0.0),
      //                   child: Container(
      //                     padding: const EdgeInsets.all(5),
      //                     decoration: BoxDecoration(
      //                       borderRadius: BorderRadius.circular(5),
      //                       boxShadow: [
      //                         BoxShadow(
      //                             color: Colors.grey.shade400,
      //                             offset: const Offset(2.0, 2.0),
      //                             blurRadius: 5.0,
      //                             spreadRadius: 1.0)
      //                       ],
      //                       color : Colors.deepOrange,
      //
      //                     ),
      //                     child: Text(
      //                       '* 4.5',
      //                       overflow: TextOverflow.ellipsis,
      //                       style: TextStyle(
      //                           fontSize: 15,
      //                           fontWeight: FontWeight.bold,
      //                           color: Colors.white),
      //                     ),
      //                   ),
      //                 ),
      //                 Padding(
      //                   padding: const EdgeInsets.fromLTRB(0.0, 5.0, 5.0, 0.0),
      //                   child: Text(
      //                     '3.2 KM',
      //                     overflow: TextOverflow.ellipsis,
      //                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ],
      //         ),
      //         Stack(
      //             children: [
      //               // image in screen
      //               Container(
      //                 height: 150,
      //                 width: MediaQuery.of(context).size.width,
      //                 margin: EdgeInsets.all(5.0),
      //                 decoration: BoxDecoration(
      //                   color: const Color(0xff7c94b6),
      //                   image:  DecorationImage(
      //                     image: AdvancedNetworkImage(
      //                       globals.imageBaseUrl +
      //                           '/api/v1/onlineapp/customer/getoutletimage/${sectionDTOList[sectionIndex]
      //                               .locationDtoList[index].id}',),
      //                     fit: BoxFit.cover,
      //                   ),
      //                   border: Border.all(
      //                     color: Colors.grey,
      //                     width: 2,
      //                   ),
      //                   borderRadius: BorderRadius.circular(10),
      //                 ),
      //               ),
      //               // 20% off button
      //               Padding(
      //                 padding: const EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 0.0),
      //                 child: Container(
      //                   padding: const EdgeInsets.all(5),
      //                   decoration: BoxDecoration(
      //                       borderRadius: BorderRadius.circular(5),
      //                       boxShadow: [
      //                         BoxShadow(
      //                             color: Colors.grey.shade400,
      //                             offset: const Offset(2.0, 2.0),
      //                             blurRadius: 5.0,
      //                             spreadRadius: 1.0)
      //                       ],
      //                       gradient: LinearGradient(colors: [
      //                         Colors.deepOrange,
      //                         Colors.deepOrange.shade200
      //                       ])),
      //                   child: Text(
      //                     '20% Off',
      //                     overflow: TextOverflow.ellipsis,
      //                     style: TextStyle(
      //                         fontSize: 15,
      //                         fontWeight: FontWeight.bold,
      //                         color: Colors.white),
      //                   ),
      //                 ),
      //               ),
      //             ]
      //         ),
      //
      //         Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             Padding(
      //               padding: const EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 0.0),
      //               child: Text(
      //                 'North Indian',
      //                 overflow: TextOverflow.ellipsis,
      //                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
      //               ),
      //             ),
      //             Padding(
      //               padding: const EdgeInsets.fromLTRB(0.0, 5.0, 5.0, 0.0),
      //               child: Text(
      //                 '350 INR 2',
      //                 overflow: TextOverflow.ellipsis,
      //                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
      //               ),
      //             ),
      //           ],
      //         ),
      //         Padding(
      //           padding: const EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 0.0),
      //           child: Text(
      //             'Banasankari',
      //             overflow: TextOverflow.ellipsis,
      //             style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
      //           ),
      //         ),
      //         Padding(
      //           padding: const EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 0.0),
      //           child: Container(
      //             padding: const EdgeInsets.all(5),
      //             decoration: BoxDecoration(
      //                 borderRadius: BorderRadius.circular(5),
      //                 boxShadow: [
      //                   BoxShadow(
      //                       color: Colors.grey.shade400,
      //                       offset: const Offset(2.0, 2.0),
      //                       blurRadius: 5.0,
      //                       spreadRadius: 1.0)
      //                 ],
      //                 gradient: LinearGradient(colors: [
      //                   Colors.deepOrange,
      //                   Colors.deepOrange.shade200
      //                 ])),
      //             child: Text(
      //               '20 % OFF On All Order',
      //               overflow: TextOverflow.ellipsis,
      //               style: TextStyle(
      //                   fontSize: 15,
      //                   fontWeight: FontWeight.bold,
      //                   color: Colors.white),
      //             ),
      //           ),
      //         ),
      //       ],
      //     ),
      //
      //
      //
      //     /*  child: Container(
      //     *//*      color: Colors.white,
      //           padding: EdgeInsets.only(
      //               right: sectionDTOList[sectionIndex].right ?? 5,
      //               left: sectionDTOList[sectionIndex].left ?? 15,
      //               top: sectionDTOList[sectionIndex].top ?? 15,
      //               bottom: sectionDTOList[sectionIndex].bottom ?? 5),*//*
      //           child: Row(
      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //               children: [
      //                 Column(
      //                     crossAxisAlignment: CrossAxisAlignment.start,
      //                     children: [
      //                       Padding(
      //                           padding: const EdgeInsets.fromLTRB(
      //                               5.0, 5.0, 0.0, 0.0),
      //                           child: Text(
      //                             sectionDTOList[sectionIndex]
      //                                 .locationDtoList[index]
      //                                 .displayName ==
      //                                 null
      //                                 ? ''
      //                                 : sectionDTOList[sectionIndex]
      //                                 .locationDtoList[index]
      //                                 .displayName,
      //                             overflow: TextOverflow.ellipsis,
      //                             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      //                       *//*    style: const TextStyle(
      //                                 color: const Color(0xff283550),
      //                                 fontWeight: FontWeight.w600,
      //                                 fontFamily: "Poppins",
      //                                 fontStyle: FontStyle.normal,
      //                                 fontSize: 12.0),*//*
      //                           )),
      //                       //style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      //                       // ),
      //                     ]),
      //                 Padding(
      //                     padding: const EdgeInsets.fromLTRB(
      //                         5.0, 5.0, 0.0, 0.0),
      //                     child: Text(
      //                       sectionDTOList[sectionIndex]
      //                           .locationDtoList[index]
      //                           .description ==
      //                           null
      //                           ? ' '
      //                           : sectionDTOList[sectionIndex]
      //                           .locationDtoList[index]
      //                           .description + (globals
      //                           .enableOutletDeliveryTime == true
      //                           ?
      //                       ' | ' + Util.getDeliveryTime(
      //                           sectionDTOList[sectionIndex]
      //                               .locationDtoList[index]
      //                               .deliveryTimeInMins)
      //                           : ''),
      //                       overflow: TextOverflow.ellipsis,
      //                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
      //                       *//*style: const TextStyle(
      //                           color: const Color(0xff8b92a0),
      //                           fontWeight: FontWeight.w500,
      //                           fontFamily: "Poppins",
      //                           fontStyle: FontStyle.normal,
      //                           fontSize: 10.0),
      //                       textAlign: TextAlign.left,*//*
      //                     )),
      //                 Stack(
      //                     children: [
      //                       // image in screen
      //                       Container(
      //                         height: 150,
      //                         width: MediaQuery
      //                             .of(context)
      //                             .size
      //                             .width,
      //                         margin: EdgeInsets.all(5.0),
      //                         decoration: BoxDecoration(
      //                           color: const Color(0xff7c94b6),
      //                           image: DecorationImage(
      //                             image: AdvancedNetworkImage(
      //                               globals.imageBaseUrl +
      //                                   '/api/v1/onlineapp/customer/getoutletimage/${sectionDTOList[sectionIndex]
      //                                       .locationDtoList[index].id}',),
      //                             fit: BoxFit.cover,
      //                           ),
      //                           border: Border.all(
      //                             color: Colors.grey,
      //                             width: 2,
      //                           ),
      //                           borderRadius: BorderRadius.circular(10),
      //                         ),
      //                       ),
      //                       // 20% off button
      //                       Padding(
      //                         padding: const EdgeInsets.fromLTRB(
      //                             5.0, 5.0, 0.0, 0.0),
      //                         child: Container(
      //                           padding: const EdgeInsets.all(5),
      //                           decoration: BoxDecoration(
      //                               borderRadius: BorderRadius.circular(5),
      //                               boxShadow: [
      //                                 BoxShadow(
      //                                     color: Colors.grey.shade400,
      //                                     offset: const Offset(2.0, 2.0),
      //                                     blurRadius: 5.0,
      //                                     spreadRadius: 1.0)
      //                               ],
      //                               gradient: LinearGradient(colors: [
      //                                 Colors.deepOrange,
      //                                 Colors.deepOrange.shade200
      //                               ])),
      //                           child: Text(
      //                             getHighestDiscount(
      //                                 sectionDTOList[sectionIndex]
      //                                     .locationDtoList[index]),
      //                             overflow: TextOverflow.ellipsis,
      //                             style: TextStyle(
      //                                 fontSize: 15,
      //                                 fontWeight: FontWeight.bold,
      //                                 color: Colors.white),
      //                           ),
      //                         ),
      //                       ),
      //                     ]
      //                 ),
      //               ]))*/
      //     /*  'Approx Max 20 Min',
      //                     overflow: TextOverflow.ellipsis,
      //                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),*/
      //   ),
      // );
      print('ankur Logger...');
      // print('${sectionDTOList[sectionIndex].locationDtoList[index].couponList[0]
      // .name}');
      return GestureDetector(
        onTap: () {
          print('click1');
          navigateToProductListPage(index, sectionIndex);
          backButtonCounter = 0;
        },
        child: Container(
          padding: EdgeInsets.only(
              right: sectionDTOList[sectionIndex].right ?? 5,
              left: sectionDTOList[sectionIndex].left ?? 12,
              top: sectionDTOList[sectionIndex].top ?? 15,
              bottom: sectionDTOList[sectionIndex].bottom ?? 5),
          color: Colors.grey[250],
          child: Card(
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            elevation: 7,
            //shadowColor: Colors.grey.shade200,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Colors.grey.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              5.0, 8.0, 0.0, 0.0),
                          child: Text(
                            sectionDTOList[sectionIndex]
                                .locationDtoList[index]
                                .displayName ==
                                null
                                ? ' '
                                : sectionDTOList[sectionIndex]
                                .locationDtoList[index]
                                .displayName,
                            overflow: TextOverflow.clip,
                            style: const TextStyle(
                                color: const Color(0xff283550),
                                fontWeight: FontWeight.w600,
                                fontFamily: "Poppins",
                                fontStyle: FontStyle.normal,
                                fontSize: 16.0),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Visibility(
                          visible: sectionDTOList[sectionIndex]
                              .locationDtoList[index]
                              .description !=
                              null &&
                              sectionDTOList[sectionIndex]
                                  .locationDtoList[index]
                                  .description
                                  .isNotEmpty,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                5.0, 5.0, 0.0, 0.0),
                            child: Text(
                              (globals
                                  .enableOutletDeliveryTime == true
                                  ? Util.getDeliveryTime(
                                  sectionDTOList[sectionIndex]
                                      .locationDtoList[index]
                                      .deliveryTimeInMins)
                                  : ''),

                              style: const TextStyle(
                                  color: const Color(0xff8b92a0),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Poppins",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 10.0),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ],
                    ), Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Visibility(
                          visible: globals.enableRating == true,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                0.0, 5.0, 5.0, 0.0),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey.shade300,
                                      offset: const Offset(2.0, 2.0),
                                      blurRadius: 5.0,
                                      spreadRadius: 1.0)
                                ],
                                color: globals.themecolor,

                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(
                                        right: 5),
                                    child: Text('4.9',
                                        style: const TextStyle(
                                            color:
                                            const Color(0xffffffff),
                                            fontWeight: FontWeight
                                                .w500,
                                            fontFamily: "Montserrat",
                                            fontStyle: FontStyle
                                                .normal,
                                            fontSize: 8.0),
                                        textAlign: TextAlign.left),
                                  ),
                                  Container(
                                    child: Icon(
                                      Icons.star,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              0.0, 5.0, 5.0, 0.0),
                          child: Text(
                            '3.2 KM',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10, fontWeight:FontWeight
                                .w500,
                              fontFamily: "Montserrat",
                              fontStyle: FontStyle
                                  .normal,),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Stack(
                    children: [
                      ColorFiltered(
                        colorFilter: sectionDTOList[sectionIndex]
                            .locationDtoList[index]
                            .availability !=
                            false
                            ? ColorFilter.mode(
                          Colors.transparent,
                          BlendMode.multiply,
                        )
                            : ColorFilter.mode(
                          Colors.grey,
                          BlendMode.saturation,
                        ),
                        child: Container(
                          height: 150,
                          // width: Util.getWidth(
                          //     sectionDTOList[sectionIndex],
                          //     context) ?? MediaQuery
                          //     .of(context)
                          //     .size
                          //     .width,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          margin: EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            color: const Color(0xff7c94b6),
                            image: DecorationImage(
                              image:
                              NetworkImage(globals.imageBaseUrl +
                                  '/api/v1/onlineapp/customer/getoutletimage/${sectionDTOList[sectionIndex]
                                      .locationDtoList[index].id}'),

                              fit: BoxFit.cover,
                            ),
                            border: Border.all(
                              color: Colors.grey,
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: sectionDTOList[sectionIndex]
                            .locationDtoList[index]
                            .highestDiscountPercentage !=
                            null,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                              10.0, 10.0, 0.0, 0.0),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey.shade400,
                                      offset: const Offset(1.0, 1.0),
                                      blurRadius: 4.0,
                                      spreadRadius: 0.5)
                                ],
                                gradient: LinearGradient(colors: [
                                  Colors.deepOrange,
                                  Colors.deepOrange.shade300
                                ])),
                            child: Text(
                                getHighestDiscount(
                                    sectionDTOList[sectionIndex]
                                        .locationDtoList[index]),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight
                                        .w700,
                                    fontFamily: "Poppins",
                                    fontStyle: FontStyle
                                        .normal,
                                    fontSize: 10.0),
                                textAlign: TextAlign
                                    .left),
                          ),
                        ),
                      ),
                    ]
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Visibility(
                      visible: sectionDTOList[sectionIndex]
                          .locationDtoList[index]
                          .cusineType !=
                          null &&
                          sectionDTOList[sectionIndex]
                              .locationDtoList[index]
                              .cusineType
                              .isNotEmpty,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(5.0, 2.0, 0.0, 0.0),
                        child: Text(
                          sectionDTOList[sectionIndex]
                              .locationDtoList[index]
                              .cusineType ==
                              null
                              ? ' '
                              : sectionDTOList[sectionIndex]
                              .locationDtoList[index]
                              .cusineType,
                          style: const TextStyle(
                              color: const Color(0xff283550),
                              fontWeight: FontWeight.w500,
                              fontFamily: "Montserrat",
                              fontStyle: FontStyle.normal,
                              fontSize: 15.0),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 2.0, 5.0, 0.0),
                      child: Text(
                        '350 INR',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight:FontWeight
                                .w500,
                            fontFamily: "Montserrat",
                            fontStyle: FontStyle
                                .normal),
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: sectionDTOList[sectionIndex]
                      .locationDtoList[index]
                      .description !=
                      null &&
                      sectionDTOList[sectionIndex]
                          .locationDtoList[index]
                          .description
                          .isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5.0, 2.0, 0.0, 6.0),
                    child: Text(
                      sectionDTOList[sectionIndex]
                          .locationDtoList[index]
                          .description ==
                          null
                          ? ' ' : sectionDTOList[sectionIndex]
                          .locationDtoList[index]
                          .description,
                      style: const TextStyle(
                          color: const Color(0xff8b92a0),
                          fontWeight: FontWeight.w500,
                          fontFamily: "Poppins",
                          fontStyle: FontStyle.normal,
                          fontSize: 11.0),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Visibility(
                  visible: sectionDTOList[sectionIndex]
                      .locationDtoList[index].couponList !=
                      null && sectionDTOList[sectionIndex]
                      .locationDtoList[index].couponList.length >
                      0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade400,
                                offset: const Offset(1.0, 1.0),
                                blurRadius: 4.0,
                                spreadRadius: 0.5)
                          ],
                          gradient: LinearGradient(colors: [
                            Colors.deepOrange,
                            Colors.deepOrange.shade300
                          ])),
                      child: // Text(sectionDTOList[sectionIndex]
                      //     .locationDtoList[index].couponList[0].code,
                      Text(getSlidingCouponText(
                          sectionDTOList[sectionIndex]
                              .locationDtoList[index]),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight
                                .w500,
                            fontFamily: "Montserrat",
                            fontStyle: FontStyle
                                .normal,
                            fontSize: 10.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  String getHighestDiscount(LocationDTO locationDTO) {
    String str = '';
    if (locationDTO.highestDiscountPercentage != null) {
      List<String> sarr = locationDTO.highestDiscountPercentage.toString()
          .split('.');
      str += sarr[0];
      str += ' % OFF';
    }
    return str;
  }

  String getSlidingCouponText(LocationDTO locationDTO) {
    String str = ' ';
    if (locationDTO.couponList != null && locationDTO.couponList.length > 0) {
      locationDTO.couponList.forEach((element) {
        str += element.code + ' | ';
      });
      str = str.substring(0, str.length - 3);
    }
    return str;
  }


  String getCustomerFirstLetter() {
    String firstLetter = '';
    if (customerName != null && customerName.isNotEmpty) {
      firstLetter = customerName[0];
    }
    return firstLetter;
  }

  Widget buildOrderNotificationPanel() {
    print('buildOrderNotificationPanel called');
    if (orderNotificationMap != null && orderNotificationMap.length > 0) {
      print('orderNotificationMap ${orderNotificationMap.length }');
      return GestureDetector(
          onTap: () async {
            print('On Click 3...');
            if (_selectedOnlineAppCustomerOrderDTO != null) {
              print('Order selected called');
              List<Object> argsList = new List();
              argsList.add(_selectedOnlineAppCustomerOrderDTO);
              bool toHome = true;
              argsList.add(toHome);
              orderNotificationMap[_selectedOnlineAppCustomerOrderDTO
                  .orderId
                  .toString()] =
                  _selectedOnlineAppCustomerOrderDTO;
              print('Before navigator $context ');
              var res = await Navigator.pushNamed(
                  context, RouteConstants.trackYourOrderRoute,
                  arguments: argsList);
              if (res == null) {
                // await getRunningOrders();
                print('Back from cancel order');
                setState(() {
                  isLoading = false;
                });
              }
            }
          },
          child: Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            height: 76,
            decoration: BoxDecoration(
                color: const Color(0xff283550),
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25), topLeft: Radius.circular(25))

            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Stack(children: <Widget>[

                    Container(
                        child: Center(
                            child:
                            Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(16)
                                    ),
                                    boxShadow: [BoxShadow(
                                        color: const Color(0x17000000),
                                        offset: Offset(0, 3),
                                        blurRadius: 6,
                                        spreadRadius: 0
                                    )
                                    ],
                                    color: const Color(0xff66b111)
                                )
                            ))),
                    Center(
                        child:
                        Opacity(
                          opacity: 0.10000000149011612,
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(28)
                                ),
                                color: const Color(0xffffffff)
                            ),

                          ),
                        )),
                    Center(child:
                    Container(
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                        )
                    ))
                  ],),
                ),
                Expanded(
                    flex: 6,
                    child: GestureDetector(onPanUpdate: (details) {
                      print('On pan updated called');
                      if (orderNotificatonSwiped == false) {
                        orderNotificatonSwiped = true;
                        Timer(Duration(milliseconds: 500), () {
                          print('Updated orderNotificatonSwiped to false');
                          orderNotificatonSwiped = false;
                        });

                        if (details.delta.dx > 0) {
                          print("Dragging in +X direction");
                          if (currentNotificationOrderIndex > 0 &&
                              currentNotificationOrderIndex <
                                  orderNotificationMap.length)
                            setState(() {
                              currentNotificationOrderIndex--;
                            });
                        }
                        else {
                          print("Dragging in -X direction");
                          if (currentNotificationOrderIndex >= 0 &&
                              currentNotificationOrderIndex <
                                  orderNotificationMap.length - 1) {
                            setState(() {
                              currentNotificationOrderIndex++;
                            });
                          }
                        }
                      }
                    },
                        child:
                        Container(
                            color: Color(0xff283550),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                    getOrderStatusMesage(),
                                    style: const TextStyle(
                                        color: const Color(0xffffffff),
                                        fontWeight: FontWeight.w500,
                                        fontFamily: "Poppins",
                                        fontStyle: FontStyle.normal,
                                        fontSize: 11.0
                                    ),
                                    textAlign: TextAlign.left
                                ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    for(int i = 0; i < (orderNotificationMap
                                        .length < 10
                                        ? orderNotificationMap.length
                                        : 10); i++)
                                      Opacity(
                                        opacity: currentNotificationOrderIndex ==
                                            i
                                            ? 0.4000000059604645
                                            : 0.15000000596046448,
                                        child: Container(

                                            width: 6,
                                            height: 6,
                                            margin: EdgeInsets.only(
                                                right: 9, top: 5),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(19)
                                                ),
                                                color: const Color(0xffffffff)
                                            )
                                        ),
                                      )
                                  ],
                                ),

                              ],
                            )
                        ))),
                Expanded(
                    flex: 2,
                    child:
                    Container(
                      child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white
                      ),

                    ))
              ],
            ),
          ));
    } else {
      Container(
        height: 0,
        width: 0,
      );
    }
  }

  String getOrderingString(String s, String locationName) {
    s = sprintf(s, [locationName]);
    return s;
  }

  String getOrderStatusMesage() {
    String message = '';
    var list = orderNotificationMap.entries.toList();
    OnlineAppCustomerOrderDTO onlineAppCustomerOrderDTO = list[currentNotificationOrderIndex]
        .value;
    if (onlineAppCustomerOrderDTO == null)
      return '';
    _selectedOnlineAppCustomerOrderDTO = onlineAppCustomerOrderDTO;
    String locationName = _selectedOnlineAppCustomerOrderDTO.locationDTO
        .displayName ?? _selectedOnlineAppCustomerOrderDTO.locationDTO.name;
    print('getOrderStatusMesage : ${onlineAppCustomerOrderDTO.orderStatus
        .toString()}');
    switch (onlineAppCustomerOrderDTO.orderStatus) {
      case OnlineOrderStatus.CREATED :
        return getOrderingString(allTranslations.text(
            'newoutlet_ordernotification_order_placed'), locationName);

      case OnlineOrderStatus.ACKNOWLEDGED :
        return getOrderingString(allTranslations.text(
            'newoutlet_ordernotification_order_acknowledged'), locationName);

      case OnlineOrderStatus.ACCEPTED :
        return getOrderingString(allTranslations.text(
            'newoutlet_ordernotification_order_accepted'), locationName);

      case OnlineOrderStatus.READY :
        return getOrderingString(allTranslations.text(
            'newoutlet_ordernotification_order_ready'), locationName);

      case OnlineOrderStatus.DISPATCH:
        return getOrderingString(allTranslations.text(
            'newoutlet_ordernotification_order_dispatch'), locationName);

      case OnlineOrderStatus.DELIVERED:
        return getOrderingString(allTranslations.text(
            'newoutlet_ordernotification_order_delivered'), locationName);

      case OnlineOrderStatus.CANCELLED:
        return getOrderingString(allTranslations.text(
            'newoutlet_ordernotification_order_cancelled'), locationName);

      case OnlineOrderStatus.NOT_DELIVERED:
        return getOrderingString(allTranslations.text(
            'newoutlet_ordernotification_order_notdelivered'), locationName);
    }
    if (onlineAppCustomerOrderDTO != null &&
        onlineAppCustomerOrderDTO.riderStatus != null) {
      if (onlineAppCustomerOrderDTO.riderStatus ==
          DeliveryPersonRiderStatus.REACHED_DESTINATION
              .toString()
              .split('.')
              .last) {
        return getOrderingString(allTranslations.text(
            'newoutlet_ordernotification_order_reacheddestination'),
            locationName);
      }
    }
    return message;
  }


  Widget showOutletNotAvailablePopUp(BuildContext context, Widget widget) {
    Navigator.push(
      context,
      PopupLayout(
        top: 150,
        left: 18,
        right: 18,
        bottom: 125,
        child: PopupContent(
            content: Container(
              child: widget,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
            )),
      ),
    );
  }

  Widget buildOutletNotAvailable() {
    return Container(
        child: Column(
          children: <Widget>[
            //Image
            Container(
              margin: EdgeInsets.only(left: 62.7, right: 63, top: 25),
              height: 153,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              // color : Colors.yellow,
              decoration: new BoxDecoration(
                  image: new DecorationImage(
                      image: new AssetImage(noOutletImage),
                      fit: BoxFit.fill)),
            ),
            Container(
                margin: EdgeInsets.only(left: 20, right: 20, top: 22),
                child: Text(
                    allTranslations.text('Newoutlet_popup_outletnovailable'),
                    style: const TextStyle(
                        color: const Color(0xff283550),
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins",
                        fontStyle: FontStyle.normal,
                        fontSize: 13.0
                    ),
                    textAlign: TextAlign.center
                )
            ),
            Container(
              margin: EdgeInsets.only(left: 20, right: 20, top: 14),
              child: Text(
                  allTranslations.text(
                      'Newoutlet_popup_outnotavailable_checkbacklater'),
                  style: const TextStyle(
                      color: const Color(0xfffc9631),
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins",
                      fontStyle: FontStyle.normal,
                      fontSize: 16.0
                  ),
                  textAlign: TextAlign.center
              ),
            ),
            GestureDetector(
                onTap: () {
                  print('On Click 4...');
                  // new NewOutlet( notifyParent: refresh );
                  Navigator.of(context).pop();
                },
                child:
                Container(
                    margin: EdgeInsets.only(left: 75, right: 74, top: 24),
                    width: 137,
                    height: 50,
                    child: Center(
                        child: Text(
                            allTranslations.text(
                                'Newoutlet_popup_outnotavailable_close'),
                            style: const TextStyle(
                                color: const Color(0xff383846),
                                fontWeight: FontWeight.w500,
                                fontFamily: "Poppins",
                                fontStyle: FontStyle.normal,
                                fontSize: 15.0
                            ),
                            textAlign: TextAlign.center
                        )
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(29)
                        ),
                        border: Border.all(
                            color: const Color(0xff383846),
                            width: 1
                        )
                    )
                ))
          ],
        )
    );
  }
  Future<List<Address>> _getAddress(double lat, double lang) async {
    final coordinates = new Coordinates(lat, lang);
    List<Address> add =
    await Geocoder.local.findAddressesFromCoordinates(coordinates);
    // for (var i = 0; i < add.length; i++) {
    if (adminArea != null)
      adminArea = add[0].adminArea;
    else
      adminArea = add[0].countryName;
    subAdminArea = add[0].subAdminArea;
    return add;
  }
  void SharedPref() async {
    String Subadmin = await SharedPreferenceService.getValuesStringSF(Constants.subAdminArea);
    print("sublocality pranav  ${Subadmin}");
  }
}
