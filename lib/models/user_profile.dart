/// User profile data models

class UserProfile {
  final String name;
  final int age;
  final String phone;
  final String email;
  final String bloodGroup;
  final String emergencyContact;
  final String bloodDonorNo;
  final bool hasMedicalAllergies;
  final String? allergiesDetails;

  UserProfile({
    required this.name,
    required this.age,
    required this.phone,
    required this.email,
    required this.bloodGroup,
    required this.emergencyContact,
    required this.bloodDonorNo,
    this.hasMedicalAllergies = false,
    this.allergiesDetails,
  });

  // Dummy data for Arun
  factory UserProfile.dummy() {
    return UserProfile(
      name: 'Arun',
      age: 20,
      phone: '9876543210',
      email: 'msarunsanjeev@gmail.com',
      bloodGroup: 'O+ve',
      emergencyContact: '9786546329',
      bloodDonorNo: '890765789',
      hasMedicalAllergies: false,
      allergiesDetails: null,
    );
  }
}

class DriverProfile {
  final String name;
  final String email;
  final String phone;
  final String driverId;
  final String licenseNo;
  final String vehicleType;
  final String vehiclePlate;
  final String vehicleModel;

  DriverProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.driverId,
    required this.licenseNo,
    required this.vehicleType,
    required this.vehiclePlate,
    required this.vehicleModel,
  });

  // Dummy data for Kishore
  factory DriverProfile.dummy() {
    return DriverProfile(
      name: 'Kishore',
      email: 'kishore@gmail.com',
      phone: '8756330012',
      driverId: '307',
      licenseNo: 'TN 28 20250004442',
      vehicleType: '4 Wheeler',
      vehiclePlate: 'TN 28 AB 8797',
      vehicleModel: '2022',
    );
  }
}

class HospitalProfile {
  final String name;
  final String email;
  final String address;
  final int icuCount;
  final int bedCount;
  final int doctorsAvailable;

  HospitalProfile({
    required this.name,
    required this.email,
    required this.address,
    required this.icuCount,
    required this.bedCount,
    required this.doctorsAvailable,
  });

  // Dummy data for Saveetha Medical Center
  factory HospitalProfile.dummy() {
    return HospitalProfile(
      name: 'Saveetha Medical Center',
      email: 'saveethamedical@gmail.com',
      address: 'Saveetha Nagar, Thandalam, Chennai, Tamil Nadu 602105',
      icuCount: 25,
      bedCount: 200,
      doctorsAvailable: 80,
    );
  }
}
