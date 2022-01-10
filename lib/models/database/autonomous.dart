import 'package:mister/models/database/account.dart';

class AutonomousLocation {
  AutonomousLocation({
    required this.address,
    this.latitude,
    this.longitude,
  });

  String address;
  double? latitude;
  double? longitude;
}

class AutonomousSocialNetworks {
  AutonomousSocialNetworks({
    this.facebook,
    this.instagram,
  });

  String? facebook;
  String? instagram;
}

class Autonomous extends Account {
  Autonomous({
    String? id,
    String? profession,
    this.email,
    this.name,
    this.phone,
    this.avatarUrl,
    this.bannerUrl,
    this.location,
    this.socialNetworks,
  }) : super(id, profession);

  String? email;
  String? name;
  String? phone;
  String? avatarUrl;
  String? bannerUrl;
  AutonomousLocation? location;
  AutonomousSocialNetworks? socialNetworks;

  set userUID(String id) {
    this.id = id;
  }

  set latitude(double latitude) {
    location?.latitude = latitude;
  }

  set longitude(double longitude) {
    location?.longitude = longitude;
  }

  Map<String, dynamic> convertToDatabaseWithRequiredData() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'profession': profession,
      'location': {
        'address': location?.address,
      },
    };
  }

  factory Autonomous.convertFromDatabase(Map<String, dynamic> data) {
    return Autonomous(
      email: data['email'],
      name: data['name'],
      phone: data['phone'],
      profession: data['profession'],
      avatarUrl: data['avatarUrl'],
      bannerUrl: data['bannerUrl'],
      location: AutonomousLocation(
        address: data['location']['address'],
        latitude: data['location']?['latitude'],
        longitude: data['location']?['longitude'],
      ),
      socialNetworks: AutonomousSocialNetworks(
        facebook: data['socialNetworks']?['facebook'],
        instagram: data['socialNetworks']?['instagram'],
      ),
    );
  }

  factory Autonomous.convertFromQuickSearchFromDatabase(
    Map<String, dynamic> data,
  ) {
    return Autonomous(
      name: data['name'],
      profession: data['profession'],
      avatarUrl: data['avatarUrl'],
    );
  }
}
