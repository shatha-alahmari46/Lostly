import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String name;
  final String status;
  final String time;
  final String category;
  final String location;
  final String date;
  final String itemColor;
  final String brand;
  final String description;
  final String imageUrl;
  final String userId;
  final DateTime? createdAt;

  const PostModel({
    required this.id,
    required this.name,
    required this.status,
    required this.time,
    required this.category,
    required this.location,
    required this.date,
    required this.itemColor,
    required this.brand,
    required this.description,
    required this.imageUrl,
    required this.userId,
    this.createdAt,
  });

  // =========================
  // From JSON
  // =========================

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Lost',
      time: json['time']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Others',
      location: json['location']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      itemColor: json['itemColor']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      createdAt: _parseDate(json['createdAt']),
    );
  }

  // =========================
  // To JSON
  // =========================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'time': time,
      'category': category,
      'location': location,
      'date': date,
      'itemColor': itemColor,
      'brand': brand,
      'description': description,
      'imageUrl': imageUrl,
      'userId': userId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // =========================
  // Convert to Firestore data
  // =========================

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'time': time,
      'category': category,
      'location': location,
      'date': date,
      'itemColor': itemColor,
      'brand': brand,
      'description': description,
      'imageUrl': imageUrl,
      'userId': userId,
      'createdAt': createdAt,
    };
  }

  // =========================
  // Copy
  // =========================

  PostModel copyWith({
    String? id,
    String? name,
    String? status,
    String? time,
    String? category,
    String? location,
    String? date,
    String? itemColor,
    String? brand,
    String? description,
    String? imageUrl,
    String? userId,
    DateTime? createdAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      time: time ?? this.time,
      category: category ?? this.category,
      location: location ?? this.location,
      date: date ?? this.date,
      itemColor: itemColor ?? this.itemColor,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // =========================
  // Helper
  // =========================

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}