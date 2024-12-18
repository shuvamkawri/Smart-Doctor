class treatmentCategoryModel {
  final String treatmentCategoryName;
  final String treatmentCategoryIcon;
  final String treatmentCategoryId;
  treatmentCategoryModel({
    required this.treatmentCategoryName,
    required this.treatmentCategoryIcon,
    required this.treatmentCategoryId,
  });
}

class treatmentHospitalListModel {
  final String treatmentHospitalListName;
  final String treatmentHospitalListLocation;
  final String treatmentHospitalListImage;
  treatmentHospitalListModel(
      {required this.treatmentHospitalListName,
        required this.treatmentHospitalListLocation,
        required this.treatmentHospitalListImage});
}

class treatmentHospitalProfileReviewModel {
  final String treatmentHospitalProfileReviewName;
  final String treatmentHospitalProfileReviewDate;
  final String treatmentHospitalProfileReviewImage;
  treatmentHospitalProfileReviewModel(
      {required this.treatmentHospitalProfileReviewName,
        required this.treatmentHospitalProfileReviewDate,
        required this.treatmentHospitalProfileReviewImage});
}

class treatmentHospitalDoctorListModel {
  final String treatmentHospitalDoctorListName;
  final String treatmentHospitalDoctorListHospital;
  final String treatmentHospitalDoctorListImage;
  treatmentHospitalDoctorListModel(
      {required this.treatmentHospitalDoctorListName,
        required this.treatmentHospitalDoctorListHospital,
        required this.treatmentHospitalDoctorListImage});
}

class TreatmentHospital {
  final String id;
  final String name;
  final String city;
  final String state;
  final String zipCode;
  final String image;

  TreatmentHospital({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.image,
  });

  factory TreatmentHospital.fromJson(Map<String, dynamic> json) {
    return TreatmentHospital(
      id: json['_id'],
      name: json['hospital_name'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zip_code'].toString(),
      image: json['image'],
    );
  }
}

class TreatmentType {
  final String id;
  final String name;

  TreatmentType({
    required this.id,
    required this.name,
  });

  factory TreatmentType.fromJson(Map<String, dynamic> json) {
    return TreatmentType(
      id: json['_id'],
      name: json['category'],
    );
  }
}

class TreatmentCategory {
  final String id;
  final String category;
  final String?
  parentName;

  TreatmentCategory({
    required this.id,
    required this.category,
    this.parentName,
  });

  factory TreatmentCategory.fromJson(Map<String, dynamic> json) {
    return TreatmentCategory(
      id: json['_id'],
      category: json['category'],
      parentName: json['parent_name'],
    );
  }
}

class TreatmentSubCategory extends TreatmentCategory {
  final String subCategoryListName;
  final String subCategoryListId;
  bool isSelected; // Define isSelected here

  TreatmentSubCategory({
    required this.subCategoryListId,
    String? parentName,
    required this.subCategoryListName,
    required this.isSelected, // Initialize isSelected in the constructor
  }) : super(id: subCategoryListId, category: subCategoryListName, parentName: parentName);

  factory TreatmentSubCategory.fromJson(Map<String, dynamic> json) {
    return TreatmentSubCategory(
      subCategoryListId: json['_id'],
      parentName: json['parent_name'],
      subCategoryListName: json['sub_category'],
      isSelected: false, // Default value for isSelected
    );
  }
}