import 'package:get/get.dart';
import '../pages/splash_page.dart';
import '../auth/views/login_page.dart';
import '../auth/views/register_page.dart';
import '../pages/home_page.dart';
import '../list-pages/views/list_page.dart';
import '../list-pages/views/category_list_page.dart';
import '../product/views/product_detail_page.dart';
import '../table/views/table_page.dart';
import '../profile/views/profile_page.dart';
import '../auth/bindings/auth_binding.dart';
import '../list-pages/bindings/list_binding.dart';
import '../list-pages/bindings/category_list_binding.dart';
import '../navbar/bindings/navbar_binding.dart';

abstract class Routes {
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const HOME = _Paths.HOME;
  static const CATEGORY_LIST = _Paths.CATEGORY_LIST;
  static const LIST = _Paths.LIST;
  static const PRODUCT_DETAIL = _Paths.PRODUCT_DETAIL;
}

abstract class _Paths {
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const HOME = '/home';
  static const CATEGORY_LIST = '/category-list';
  static const LIST = '/list';
  static const PRODUCT_DETAIL = '/product-detail';
}

class AppPages {
  static const INITIAL = '/splash';

  static final routes = [
    GetPage(
      name: '/splash',
      page: () => const SplashPage(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => RegisterPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomePage(),
      binding: NavbarBinding(),
    ),
    GetPage(
      name: _Paths.CATEGORY_LIST,
      page: () => const CategoryListPage(),
      binding: CategoryListBinding(),
    ),
    GetPage(
      name: _Paths.LIST,
      page: () => const ListPage(),
      binding: ListBinding(),
    ),
    GetPage(
      name: _Paths.PRODUCT_DETAIL, 
      page: () => const ProductDetailPage(),
      binding: BindingsBuilder(() {
        // ProductDetailController is created with Get.put in the page itself
        // to ensure NavigationStackManager is already available
      }),
    ),
  ];
}
