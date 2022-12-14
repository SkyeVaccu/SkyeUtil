import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///handle the orientation fault
class FlutterScreenUtilConfiguration {
  ///reset the init Screen Size
  ///@param context : the root context
  static void initScreenSize(BuildContext context) {
    //get the orientation of the device
    var orientation = MediaQuery.of(context).orientation;
    //get the width
    var width = MediaQuery.of(context).size.width;
    //get the height
    var height = MediaQuery.of(context).size.height;
    //judge the type of the device
    var isPortrait = orientation == Orientation.portrait;
    var relativeWidth = isPortrait ? width : height;
    Size? currentSize;
    //mobile device
    if (relativeWidth <= 480) {
      currentSize = isPortrait ? const Size(1080, 2340) : const Size(2340, 1080);
    }
    //tablet device
    else if (480 < relativeWidth && relativeWidth <= 900) {
      currentSize = isPortrait ? const Size(1620, 2160) : const Size(2160, 1620);
    }
    //desktop device
    else if (relativeWidth > 900) {
      currentSize = isPortrait ? const Size(1080, 1920) : const Size(1920, 1080);
    }
    ScreenUtil.init(
      context,
      splitScreenMode: true,
      minTextAdapt: true,
      designSize: currentSize!,
    );
  }
}
