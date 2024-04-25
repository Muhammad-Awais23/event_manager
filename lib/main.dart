import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'shared/routes.dart';

void main()async {
 WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

   FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {        FlutterNativeSplash.remove();
    return  ScreenUtilInit(      designSize: const Size(360,690),
      child: MaterialApp(
  
         theme: ThemeData(
          textTheme: const TextTheme(
        bodyMedium: TextStyle(
          fontFamily: 'Ubuntu',
        ),)),
        
        
        debugShowCheckedModeBanner:false ,
        
          initialRoute: RouteHelper.initRoute,
                routes: RouteHelper.routes(context),
      ),
    );
  }
}
