import '../../../../../../domain/common_fuction_api.dart';

class DoctorHomeCategoryModel {
  final String doctorCategoryName;
  final String doctorCategoryIcon;
  final String doctorCategoryNavigate;
  final String type;

  DoctorHomeCategoryModel({
    required this.doctorCategoryName,
    required this.doctorCategoryIcon,
    required this.doctorCategoryNavigate,
    required this.type,
  });

  factory DoctorHomeCategoryModel.fromJson(Map<String, dynamic> json) {
    return DoctorHomeCategoryModel(
      doctorCategoryName: json['title'],
      doctorCategoryIcon: imageUrlBase + json['images'],
      doctorCategoryNavigate: json['url'],
      type: json['type'],
    );
  }
}