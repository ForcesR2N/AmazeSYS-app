import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'auth/controllers/auth_controller.dart';
import 'core/services/navigation_stack_manager.dart';
import 'company/services/company_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await Get.putAsync(() async => NavigationStackManager());
  
  // Initialize AuthController globally for auto-login functionality
  Get.put(AuthController(), permanent: true);
  
  // Initialize entity services globally
  Get.put(CompanyService(), permanent: true);
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Amazesys App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
