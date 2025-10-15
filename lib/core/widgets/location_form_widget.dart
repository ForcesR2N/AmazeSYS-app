import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import 'base_form_page.dart';

/// Controller for location form widget
class LocationFormController extends GetxController {
  final LocationService _locationService = Get.find<LocationService>();

  // Selected location objects
  final Rx<Province?> selectedProvince = Rx<Province?>(null);
  final Rx<District?> selectedDistrict = Rx<District?>(null);
  final Rx<Subdistrict?> selectedSubdistrict = Rx<Subdistrict?>(null);
  final Rx<Ward?> selectedWard = Rx<Ward?>(null);
  final Rx<Zipcode?> selectedZipcode = Rx<Zipcode?>(null);

  // Cached lists for current selections
  final RxList<District> _districts = <District>[].obs;
  final RxList<Subdistrict> _subdistricts = <Subdistrict>[].obs;
  final RxList<Ward> _wards = <Ward>[].obs;
  final RxList<Zipcode> _zipcodes = <Zipcode>[].obs;

  /// Search provinces with filter
  Future<List<Province>> searchProvinces(String filter) async {
    try {
      final provinces = await _locationService.getProvinces();
      if (filter.isEmpty) return provinces;

      return provinces
          .where((p) => p.name.toLowerCase().contains(filter.toLowerCase()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Search districts with filter
  Future<List<District>> searchDistricts(String filter) async {
    if (selectedProvince.value == null) return [];

    try {
      final districts = await _locationService.getDistrictsByProvince(
        selectedProvince.value!.id,
      );
      _districts.value = districts;

      if (filter.isEmpty) return districts;

      return districts
          .where((d) => d.name.toLowerCase().contains(filter.toLowerCase()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Search subdistricts with filter
  Future<List<Subdistrict>> searchSubdistricts(String filter) async {
    if (selectedDistrict.value == null) return [];

    try {
      final subdistricts = await _locationService.getSubdistrictsByDistrict(
        selectedDistrict.value!.id,
      );
      _subdistricts.value = subdistricts;

      if (filter.isEmpty) return subdistricts;

      return subdistricts
          .where((s) => s.name.toLowerCase().contains(filter.toLowerCase()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Search wards with filter
  Future<List<Ward>> searchWards(String filter) async {
    if (selectedSubdistrict.value == null) return [];

    try {
      final wards = await _locationService.getWardsBySubdistrict(
        selectedSubdistrict.value!.id,
      );
      _wards.value = wards;

      if (filter.isEmpty) return wards;

      return wards
          .where((w) => w.name.toLowerCase().contains(filter.toLowerCase()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Search zipcodes with filter
  Future<List<Zipcode>> searchZipcodes(String filter) async {
    if (selectedWard.value == null) return [];

    try {
      final zipcodes = await _locationService.getZipcodesByWard(
        selectedWard.value!.id,
      );
      _zipcodes.value = zipcodes;

      if (filter.isEmpty) return zipcodes;

      return zipcodes
          .where((z) => z.code.toLowerCase().contains(filter.toLowerCase()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Handle province selection - resets child selections
  void onProvinceChanged(Province? province) {
    selectedProvince.value = province;
    selectedDistrict.value = null;
    selectedSubdistrict.value = null;
    selectedWard.value = null;
    selectedZipcode.value = null;
    _districts.clear();
    _subdistricts.clear();
    _wards.clear();
    _zipcodes.clear();
  }

  /// Handle district selection - resets child selections
  void onDistrictChanged(District? district) {
    selectedDistrict.value = district;
    selectedSubdistrict.value = null;
    selectedWard.value = null;
    selectedZipcode.value = null;
    _subdistricts.clear();
    _wards.clear();
    _zipcodes.clear();
  }

  /// Handle subdistrict selection - resets child selections
  void onSubdistrictChanged(Subdistrict? subdistrict) {
    selectedSubdistrict.value = subdistrict;
    selectedWard.value = null;
    selectedZipcode.value = null;
    _wards.clear();
    _zipcodes.clear();
  }

  /// Handle ward selection - resets child selections
  void onWardChanged(Ward? ward) {
    selectedWard.value = ward;
    selectedZipcode.value = null;
    _zipcodes.clear();
  }

  /// Handle zipcode selection
  void onZipcodeChanged(Zipcode? zipcode) {
    selectedZipcode.value = zipcode;
  }

  /// Load existing location data for edit mode - OPTIMIZED with parallel API calls
  Future<void> loadExistingLocation({
    String? provinceId,
    String? districtId,
    String? subdistrictId,
    String? wardId,
    String? zipcodeId,
  }) async {
    try {
      // Early return if no location data
      if (provinceId == null) return;

      // Build list of futures to execute in parallel
      final List<Future<dynamic>> futures = [];

      // 1. Always fetch provinces
      futures.add(_locationService.getProvinces());

      // 2. Fetch districts if provinceId exists
      if (districtId != null) {
        futures.add(_locationService.getDistrictsByProvince(provinceId));
      } else {
        futures.add(Future.value(<District>[]));
      }

      // 3. Fetch subdistricts if districtId exists
      if (subdistrictId != null && districtId != null) {
        futures.add(_locationService.getSubdistrictsByDistrict(districtId));
      } else {
        futures.add(Future.value(<Subdistrict>[]));
      }

      // 4. Fetch wards if subdistrictId exists
      if (wardId != null && subdistrictId != null) {
        futures.add(_locationService.getWardsBySubdistrict(subdistrictId));
      } else {
        futures.add(Future.value(<Ward>[]));
      }

      // 5. Fetch zipcodes if wardId exists
      if (zipcodeId != null && wardId != null) {
        futures.add(_locationService.getZipcodesByWard(wardId));
      } else {
        futures.add(Future.value(<Zipcode>[]));
      }

      // Execute all API calls in parallel - THIS IS THE KEY OPTIMIZATION!
      final results = await Future.wait(futures);

      // Extract results
      final provinces = results[0] as List<Province>;
      final districts = results[1] as List<District>;
      final subdistricts = results[2] as List<Subdistrict>;
      final wards = results[3] as List<Ward>;
      final zipcodes = results[4] as List<Zipcode>;

      // Now populate the selections
      // 1. Set province
      final province = provinces.firstWhereOrNull((p) => p.id == provinceId);
      if (province != null) {
        selectedProvince.value = province;

        // 2. Set district
        if (districtId != null && districts.isNotEmpty) {
          final district = districts.firstWhereOrNull((d) => d.id == districtId);
          if (district != null) {
            selectedDistrict.value = district;
            _districts.value = districts;

            // 3. Set subdistrict
            if (subdistrictId != null && subdistricts.isNotEmpty) {
              final subdistrict = subdistricts.firstWhereOrNull(
                (s) => s.id == subdistrictId,
              );
              if (subdistrict != null) {
                selectedSubdistrict.value = subdistrict;
                _subdistricts.value = subdistricts;

                // 4. Set ward
                if (wardId != null && wards.isNotEmpty) {
                  final ward = wards.firstWhereOrNull((w) => w.id == wardId);
                  if (ward != null) {
                    selectedWard.value = ward;
                    _wards.value = wards;

                    // 5. Set zipcode
                    if (zipcodeId != null && zipcodes.isNotEmpty) {
                      final zipcode = zipcodes.firstWhereOrNull(
                        (z) => z.id == zipcodeId,
                      );
                      if (zipcode != null) {
                        selectedZipcode.value = zipcode;
                        _zipcodes.value = zipcodes;
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print('⚠️ Error loading existing location: $e');
      // Silent fail - don't block form from opening
    }
  }

  /// Get location data as Map
  Map<String, String?> getLocationData() {
    return {
      'province_id': selectedProvince.value?.id,
      'district_id': selectedDistrict.value?.id,
      'subdistrict_id': selectedSubdistrict.value?.id,
      'ward_id': selectedWard.value?.id,
      'zipcode_id': selectedZipcode.value?.id,
    };
  }

  /// Reset all selections
  void reset() {
    selectedProvince.value = null;
    selectedDistrict.value = null;
    selectedSubdistrict.value = null;
    selectedWard.value = null;
    selectedZipcode.value = null;
    _districts.clear();
    _subdistricts.clear();
    _wards.clear();
    _zipcodes.clear();
  }
}

/// Reusable location form widget with cascading dropdowns
class LocationFormWidget extends StatelessWidget {
  final String tag;

  const LocationFormWidget({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LocationFormController>(tag: tag);

    return Column(
      children: [
        // Province Field
        CustomFormField(
          label: 'Province',
          child: Obx(
            () => DropdownSearch<Province>(
              items:
                  (filter, infiniteScrollProps) =>
                      controller.searchProvinces(filter),
              itemAsString: (Province province) => province.name,
              selectedItem: controller.selectedProvince.value,
              onChanged: controller.onProvinceChanged,
              compareFn:
                  (Province? item1, Province? item2) => item1?.id == item2?.id,
              decoratorProps: DropDownDecoratorProps(
                decoration: buildInputDecoration(
                  hintText: 'Type to search province...',
                  prefixIcon: Icons.map,
                ),
              ),
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: 'Search province...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
                emptyBuilder:
                    (context, searchEntry) => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Text('No provinces found'),
                      ),
                    ),
                loadingBuilder:
                    (context, searchEntry) => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: CircularProgressIndicator(),
                      ),
                    ),
              ),
            ),
          ),
        ),

        // District Field
        CustomFormField(
          label: 'District',
          child: Obx(
            () => DropdownSearch<District>(
              enabled: controller.selectedProvince.value != null,
              items:
                  (filter, infiniteScrollProps) =>
                      controller.searchDistricts(filter),
              itemAsString: (District district) => district.name,
              selectedItem: controller.selectedDistrict.value,
              onChanged: controller.onDistrictChanged,
              compareFn:
                  (District? item1, District? item2) => item1?.id == item2?.id,
              decoratorProps: DropDownDecoratorProps(
                decoration: buildInputDecoration(
                  hintText:
                      controller.selectedProvince.value == null
                          ? 'Select province first'
                          : 'Type to search district...',
                  prefixIcon: Icons.location_city,
                ),
              ),
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: 'Search district...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
                emptyBuilder:
                    (context, searchEntry) => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Text('No districts found'),
                      ),
                    ),
                loadingBuilder:
                    (context, searchEntry) => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: CircularProgressIndicator(),
                      ),
                    ),
              ),
            ),
          ),
        ),

        // Subdistrict Field
        CustomFormField(
          label: 'Subdistrict',
          child: Obx(
            () => DropdownSearch<Subdistrict>(
              enabled: controller.selectedDistrict.value != null,
              items:
                  (filter, infiniteScrollProps) =>
                      controller.searchSubdistricts(filter),
              itemAsString: (Subdistrict subdistrict) => subdistrict.name,
              selectedItem: controller.selectedSubdistrict.value,
              onChanged: controller.onSubdistrictChanged,
              compareFn:
                  (Subdistrict? item1, Subdistrict? item2) =>
                      item1?.id == item2?.id,
              decoratorProps: DropDownDecoratorProps(
                decoration: buildInputDecoration(
                  hintText:
                      controller.selectedDistrict.value == null
                          ? 'Select district first'
                          : 'Type to search subdistrict...',
                  prefixIcon: Icons.location_on_outlined,
                ),
              ),
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: 'Search subdistrict...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
                emptyBuilder:
                    (context, searchEntry) => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Text('No subdistricts found'),
                      ),
                    ),
                loadingBuilder:
                    (context, searchEntry) => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: CircularProgressIndicator(),
                      ),
                    ),
              ),
            ),
          ),
        ),

        // Ward Field
        CustomFormField(
          label: 'Ward/Village',
          child: Obx(
            () => DropdownSearch<Ward>(
              enabled: controller.selectedSubdistrict.value != null,
              items:
                  (filter, infiniteScrollProps) =>
                      controller.searchWards(filter),
              itemAsString: (Ward ward) => ward.name,
              selectedItem: controller.selectedWard.value,
              onChanged: controller.onWardChanged,
              compareFn: (Ward? item1, Ward? item2) => item1?.id == item2?.id,
              decoratorProps: DropDownDecoratorProps(
                decoration: buildInputDecoration(
                  hintText:
                      controller.selectedSubdistrict.value == null
                          ? 'Select subdistrict first'
                          : 'Type to search ward...',
                  prefixIcon: Icons.home_work_outlined,
                ),
              ),
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: 'Search ward...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
                emptyBuilder:
                    (context, searchEntry) => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Text('No wards found'),
                      ),
                    ),
                loadingBuilder:
                    (context, searchEntry) => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: CircularProgressIndicator(),
                      ),
                    ),
              ),
            ),
          ),
        ),

        // Zipcode Field
        CustomFormField(
          label: 'Postal Code',
          child: Obx(
            () => DropdownSearch<Zipcode>(
              enabled: controller.selectedWard.value != null,
              items:
                  (filter, infiniteScrollProps) =>
                      controller.searchZipcodes(filter),
              itemAsString: (Zipcode zipcode) => zipcode.code,
              selectedItem: controller.selectedZipcode.value,
              onChanged: controller.onZipcodeChanged,
              compareFn:
                  (Zipcode? item1, Zipcode? item2) => item1?.id == item2?.id,
              decoratorProps: DropDownDecoratorProps(
                decoration: buildInputDecoration(
                  hintText:
                      controller.selectedWard.value == null
                          ? 'Select ward first'
                          : 'Type to search postal code...',
                  prefixIcon: Icons.local_post_office,
                ),
              ),
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: 'Search postal code...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
                emptyBuilder:
                    (context, searchEntry) => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Text('No postal codes found'),
                      ),
                    ),
                loadingBuilder:
                    (context, searchEntry) => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: CircularProgressIndicator(),
                      ),
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
