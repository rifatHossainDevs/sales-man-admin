import '../models/territory_model.dart';

class MockTerritoriesData {
  static List<DistrictModel> getDistricts() {
    return [
      const DistrictModel(
        id: 'dist_dhaka',
        name: 'Dhaka',
        code: '12',
        retailersCount: 214,
      ),
      const DistrictModel(
        id: 'dist_gazipur',
        name: 'Gazipur',
        code: '13',
        retailersCount: 96,
      ),
      const DistrictModel(
        id: 'dist_narayanganj',
        name: 'Narayanganj',
        code: '14',
        retailersCount: 74,
      ),
      const DistrictModel(
        id: 'dist_narsingdi',
        name: 'Narsingdi',
        code: '15',
        retailersCount: 41,
      ),
      const DistrictModel(
        id: 'dist_manikganj',
        name: 'Manikganj',
        code: '16',
        retailersCount: 28,
      ),
      const DistrictModel(
        id: 'dist_munshiganj',
        name: 'Munshiganj',
        code: '17',
        retailersCount: 19,
      ),
    ];
  }

  static List<SubDistrictModel> getSubDistricts() {
    return [
      // Dhaka sub-districts
      const SubDistrictModel(
        id: 'sub_mirpur',
        districtId: 'dist_dhaka',
        name: 'Mirpur',
        code: '101',
        retailersCount: 112,
      ),
      const SubDistrictModel(
        id: 'sub_uttara',
        districtId: 'dist_dhaka',
        name: 'Uttara',
        code: '102',
        retailersCount: 64,
      ),
      const SubDistrictModel(
        id: 'sub_dhanmondi',
        districtId: 'dist_dhaka',
        name: 'Dhanmondi',
        code: '103',
        retailersCount: 48,
      ),
      const SubDistrictModel(
        id: 'sub_mohammadpur',
        districtId: 'dist_dhaka',
        name: 'Mohammadpur',
        code: '104',
        retailersCount: 39,
      ),
      const SubDistrictModel(
        id: 'sub_gulshan',
        districtId: 'dist_dhaka',
        name: 'Gulshan',
        code: '105',
        retailersCount: 35,
      ),
      const SubDistrictModel(
        id: 'sub_tejgaon',
        districtId: 'dist_dhaka',
        name: 'Tejgaon',
        code: '106',
        retailersCount: 22,
      ),
      const SubDistrictModel(
        id: 'sub_motijheel',
        districtId: 'dist_dhaka',
        name: 'Motijheel',
        code: '107',
        retailersCount: 18,
      ),

      // Gazipur sub-districts
      const SubDistrictModel(
        id: 'sub_gz_sadar',
        districtId: 'dist_gazipur',
        name: 'Gazipur Sadar',
        code: '111',
        retailersCount: 45,
      ),
      const SubDistrictModel(
        id: 'sub_gz_tongi',
        districtId: 'dist_gazipur',
        name: 'Tongi',
        code: '112',
        retailersCount: 32,
      ),
      const SubDistrictModel(
        id: 'sub_gz_kaliakair',
        districtId: 'dist_gazipur',
        name: 'Kaliakair',
        code: '113',
        retailersCount: 19,
      ),

      // Narayanganj sub-districts
      const SubDistrictModel(
        id: 'sub_ng_sadar',
        districtId: 'dist_narayanganj',
        name: 'Narayanganj Sadar',
        code: '121',
        retailersCount: 40,
      ),
      const SubDistrictModel(
        id: 'sub_ng_bandar',
        districtId: 'dist_narayanganj',
        name: 'Bandar',
        code: '122',
        retailersCount: 20,
      ),
      const SubDistrictModel(
        id: 'sub_ng_rupganj',
        districtId: 'dist_narayanganj',
        name: 'Rupganj',
        code: '123',
        retailersCount: 14,
      ),

      // Narsingdi sub-districts
      const SubDistrictModel(
        id: 'sub_ns_sadar',
        districtId: 'dist_narsingdi',
        name: 'Narsingdi Sadar',
        code: '131',
        retailersCount: 25,
      ),
      const SubDistrictModel(
        id: 'sub_ns_shibpur',
        districtId: 'dist_narsingdi',
        name: 'Shibpur',
        code: '132',
        retailersCount: 16,
      ),

      // Manikganj sub-districts
      const SubDistrictModel(
        id: 'sub_mg_sadar',
        districtId: 'dist_manikganj',
        name: 'Manikganj Sadar',
        code: '141',
        retailersCount: 28,
      ),

      // Munshiganj sub-districts
      const SubDistrictModel(
        id: 'sub_mn_sadar',
        districtId: 'dist_munshiganj',
        name: 'Munshiganj Sadar',
        code: '151',
        retailersCount: 19,
      ),
    ];
  }

  static List<AreaModel> getAreas() {
    return [
      // Mirpur Areas
      const AreaModel(
        id: 'area_1',
        subDistrictId: 'sub_mirpur',
        name: 'Mirpur-1',
        code: '1001',
        retailersCount: 12,
        assignedSalesman: 'Tariqul Islam',
        assignedSalesmanId: 'sm_1',
      ),
      const AreaModel(
        id: 'area_2',
        subDistrictId: 'sub_mirpur',
        name: 'Mirpur-2',
        code: '1002',
        retailersCount: 15,
        assignedSalesman: 'Tariqul Islam',
        assignedSalesmanId: 'sm_1',
      ),
      const AreaModel(
        id: 'area_3',
        subDistrictId: 'sub_mirpur',
        name: 'Mirpur-10',
        code: '1003',
        retailersCount: 31,
        assignedSalesman: 'Tariqul Islam',
        assignedSalesmanId: 'sm_1',
      ),
      const AreaModel(
        id: 'area_4',
        subDistrictId: 'sub_mirpur',
        name: 'Mirpur-11',
        code: '1004',
        retailersCount: 18,
        assignedSalesman: 'Rafiqul Islam',
        assignedSalesmanId: 'sm_2',
      ),
      const AreaModel(
        id: 'area_5',
        subDistrictId: 'sub_mirpur',
        name: 'Mirpur-12',
        code: '1005',
        retailersCount: 14,
        assignedSalesman: 'Rafiqul Islam',
        assignedSalesmanId: 'sm_2',
      ),
      const AreaModel(
        id: 'area_6',
        subDistrictId: 'sub_mirpur',
        name: 'Pallabi',
        code: '1006',
        retailersCount: 11,
        assignedSalesman: 'Rafiqul Islam',
        assignedSalesmanId: 'sm_2',
      ),
      const AreaModel(
        id: 'area_7',
        subDistrictId: 'sub_mirpur',
        name: 'Kafrul',
        code: '1007',
        retailersCount: 7,
        assignedSalesman: 'Kamrul Hasan',
        assignedSalesmanId: 'sm_3',
      ),
      const AreaModel(
        id: 'area_8',
        subDistrictId: 'sub_mirpur',
        name: 'Shewrapara',
        code: '1008',
        retailersCount: 4,
        assignedSalesman: 'Kamrul Hasan',
        assignedSalesmanId: 'sm_3',
      ),

      // Uttara Areas
      const AreaModel(
        id: 'area_9',
        subDistrictId: 'sub_uttara',
        name: 'Sector 3',
        code: '1011',
        retailersCount: 18,
        assignedSalesman: 'Tanvir Ahmed',
        assignedSalesmanId: 'sm_4',
      ),
      const AreaModel(
        id: 'area_10',
        subDistrictId: 'sub_uttara',
        name: 'Sector 7',
        code: '1012',
        retailersCount: 24,
        assignedSalesman: 'Tanvir Ahmed',
        assignedSalesmanId: 'sm_4',
      ),
      const AreaModel(
        id: 'area_11',
        subDistrictId: 'sub_uttara',
        name: 'Sector 11',
        code: '1013',
        retailersCount: 22,
        assignedSalesman: 'Tanvir Ahmed',
        assignedSalesmanId: 'sm_4',
      ),

      // Dhanmondi Areas
      const AreaModel(
        id: 'area_12',
        subDistrictId: 'sub_dhanmondi',
        name: 'Dhanmondi 27',
        code: '1021',
        retailersCount: 26,
        assignedSalesman: 'Mahmudul Hasan',
        assignedSalesmanId: 'sm_5',
      ),
      const AreaModel(
        id: 'area_13',
        subDistrictId: 'sub_dhanmondi',
        name: 'Dhanmondi 32',
        code: '1022',
        retailersCount: 22,
        assignedSalesman: 'Mahmudul Hasan',
        assignedSalesmanId: 'sm_5',
      ),

      // Mohammadpur Areas
      const AreaModel(
        id: 'area_14',
        subDistrictId: 'sub_mohammadpur',
        name: 'Town Hall',
        code: '1031',
        retailersCount: 21,
        assignedSalesman: 'Tariqul Islam',
        assignedSalesmanId: 'sm_1',
      ),
      const AreaModel(
        id: 'area_15',
        subDistrictId: 'sub_mohammadpur',
        name: 'Japan Garden City',
        code: '1032',
        retailersCount: 18,
        assignedSalesman: 'Tariqul Islam',
        assignedSalesmanId: 'sm_1',
      ),
    ];
  }
}
