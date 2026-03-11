/// Modelo de datos para representar un usuario de la API RandomUser
class User {
  final String gender;
  final Name name;
  final String email;
  final String phone;
  final Picture picture;
  final Dob dob;
  final Location location;

  User({
    required this.gender,
    required this.name,
    required this.email,
    required this.phone,
    required this.picture,
    required this.dob,
    required this.location,
  });

  /// Crea una instancia de User desde un JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      gender: json['gender'] ?? '',
      name: Name.fromJson(json['name'] ?? {}),
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      picture: Picture.fromJson(json['picture'] ?? {}),
      dob: Dob.fromJson(json['dob'] ?? {}),
      location: Location.fromJson(json['location'] ?? {}),
    );
  }
}

/// Modelo para el nombre del usuario
class Name {
  final String title;
  final String first;
  final String last;

  Name({required this.title, required this.first, required this.last});

  factory Name.fromJson(Map<String, dynamic> json) {
    return Name(
      title: json['title'] ?? '',
      first: json['first'] ?? '',
      last: json['last'] ?? '',
    );
  }

  /// Retorna el nombre completo del usuario
  String get fullName => '$first $last';
}

/// Modelo para las fotos del usuario
class Picture {
  final String large;
  final String medium;
  final String thumbnail;

  Picture({required this.large, required this.medium, required this.thumbnail});

  factory Picture.fromJson(Map<String, dynamic> json) {
    return Picture(
      large: json['large'] ?? '',
      medium: json['medium'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
    );
  }
}

/// Modelo para la fecha de nacimiento y edad
class Dob {
  final String date;
  final int age;

  Dob({required this.date, required this.age});

  factory Dob.fromJson(Map<String, dynamic> json) {
    return Dob(date: json['date'] ?? '', age: json['age'] ?? 0);
  }
}

/// Modelo para la ubicación del usuario
class Location {
  final String city;
  final String country;

  Location({required this.city, required this.country});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(city: json['city'] ?? '', country: json['country'] ?? '');
  }
}
