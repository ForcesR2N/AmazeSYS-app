import 'package:amazesys_app/pages/home_page.dart';
import 'package:get/get.dart';
import '../splash/views/splash_page.dart';
import '../auth/views/login_page.dart';
import '../auth/views/register_page.dart';
import '../list-pages/views/list_page.dart';
import '../list-pages/views/category_list_page.dart';
import '../product/views/product_detail_page.dart';
import '../profile/views/profile_page.dart';
import '../company/views/company_form_page.dart';
import '../branch/views/branch_form_page.dart';
import '../warehouse/views/warehouse_form_page.dart';
import '../favorites/views/favorites_page.dart';
import '../auth/bindings/auth_binding.dart';
import '../splash/bindings/splash_binding.dart';
import '../list-pages/bindings/list_binding.dart';
import '../list-pages/bindings/category_list_binding.dart';
import '../navbar/bindings/navbar_binding.dart';
import '../company/bindings/company_form_binding.dart';
import '../branch/bindings/branch_form_binding.dart';
import '../warehouse/bindings/warehouse_form_binding.dart';
import '../favorites/bindings/favorites_binding.dart';
import '../pages/bindings/home_binding.dart';

abstract class Routes {
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const HOME = _Paths.HOME;
  static const CATEGORY_LIST = _Paths.CATEGORY_LIST;
  static const LIST = _Paths.LIST;
  static const PRODUCT_DETAIL = _Paths.PRODUCT_DETAIL;
  static const COMPANY_FORM = _Paths.COMPANY_FORM;
  static const BRANCH_FORM = _Paths.BRANCH_FORM;
  static const WAREHOUSE_FORM = _Paths.WAREHOUSE_FORM;
  static const FAVORITES = _Paths.FAVORITES;
}

abstract class _Paths {
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const HOME = '/home';
  static const CATEGORY_LIST = '/category-list';
  static const LIST = '/list';
  static const PRODUCT_DETAIL = '/product-detail';
  static const COMPANY_FORM = '/company-form';
  static const BRANCH_FORM = '/branch-form';
  static const WAREHOUSE_FORM = '/warehouse-form';
  static const FAVORITES = '/favorites';
}

class AppPages {
  static const INITIAL = '/splash';

  static final routes = [
    GetPage(
      name: '/splash',
      page: () => const SplashPage(),
      binding: SplashBinding(),
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
      bindings: [
        NavbarBinding(),
        HomeBinding(),
      ],
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
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: _Paths.COMPANY_FORM,
      page: () => const CompanyFormPage(),
      binding: CompanyFormBinding(),
    ),
    GetPage(
      name: _Paths.BRANCH_FORM,
      page: () => const BranchFormPage(),
      binding: BranchFormBinding(),
    ),
    GetPage(
      name: _Paths.WAREHOUSE_FORM,
      page: () => const WarehouseFormPage(),
      binding: WarehouseFormBinding(),
    ),
    GetPage(
      name: _Paths.FAVORITES,
      page: () => const FavoritesPage(),
      binding: FavoritesBinding(),
    ),
  ];
}
