import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'auth/controllers/auth_controller.dart';
import 'core/services/navigation_stack_manager.dart';
import 'core/services/location_service.dart';
import 'company/services/company_service.dart';
import 'core/storage/token_storage.dart';
import 'core/api/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TokenStorage.instance.initialize();
  ApiClient.instance.initialize();

  // Initialize services
  await Get.putAsync(() async => NavigationStackManager());
  Get.put(AuthController(), permanent: true);

  // Initialize core services globally
  Get.put(LocationService(), permanent: true);

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
