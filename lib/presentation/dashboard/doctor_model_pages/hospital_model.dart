class Hospital {
  final String id;
  final String name;
  final String city;
  final String state;
  final String zipCode;
  final String image;
  final double rating;
  final List<dynamic> topPriorityHospital;

  Hospital({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.image,
    required this.rating,
    required this.topPriorityHospital,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['_id'],
      name: json['hospital_name'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zip_code'].toString(),
      image: json['image'],
      rating: _parseRating(json['rating']),
      topPriorityHospital: json['top_priority_hospital'],
    );
  }

  static double _parseRating(dynamic rating) {
    if (rating is int) {
      return rating.toDouble();
    } else if (rating is double) {
      return rating;
    } else if (rating is String) {
      return double.tryParse(rating) ?? 0.0;
    } else {
      throw Exception("Invalid rating format");
    }
  }
}


class hospitalProfileReviewModel {
  final String hospitalProfileReviewName;
  final String hospitalProfileReviewDate;
  final String hospitalProfileReviewImage;
  hospitalProfileReviewModel(
      {required this.hospitalProfileReviewName,
      required this.hospitalProfileReviewDate,
      required this.hospitalProfileReviewImage});
}

class hospitalDoctorListModel {
  final String hospitalDoctorListId;
  final String hospitalDoctorListName;
  final String hospitalDoctorListHospital;
  final String hospitalDoctorListImage;
  final String hospitalDoctorListSpecialistCategory;
  final String hospitalDoctorListRating;
  final String hospitalDoctorListTotalReview;
  hospitalDoctorListModel(
      {required this.hospitalDoctorListId,
      required this.hospitalDoctorListName,
      required this.hospitalDoctorListHospital,
      required this.hospitalDoctorListTotalReview,
      required this.hospitalDoctorListSpecialistCategory,
      required this.hospitalDoctorListRating,
      required this.hospitalDoctorListImage});
}





class HospitalType {
  final String id;
  final String name;


  HospitalType({
    required this.id,
    required this.name,

  });

  factory HospitalType.fromJson(Map<String, dynamic> json) {
    return HospitalType(
      id: json['_id'],
      name: json['hospital_name'],
    );
  }
}


class HospitalAppointData {
  final String id;
  final String name;

  HospitalAppointData({
    required this.id,
    required this.name,
  });

  factory HospitalAppointData.fromJson(Map<String, dynamic> json) {
    return HospitalAppointData(
      id: json['hospital'],
      name: json['hospital_name'],
    );
  }
}