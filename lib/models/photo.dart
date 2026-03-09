class InspectionPhoto {
  final int id;
  final int claimId;
  final String imageUrl;
  final String timestamp;
  final String gpsLocation;
  final String photoType;

  InspectionPhoto({
    required this.id,
    required this.claimId,
    required this.imageUrl,
    required this.timestamp,
    required this.gpsLocation,
    required this.photoType,
  });

  factory InspectionPhoto.fromJson(Map<String, dynamic> json) =>
      InspectionPhoto(
        id: json['id'] as int? ?? 0,
        claimId: json['claim_id'] as int? ?? 0,
        imageUrl: json['image_url'] as String? ?? '',
        timestamp: json['timestamp'] as String? ?? '',
        gpsLocation: json['gps_location'] as String? ?? '',
        photoType: json['photo_type'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'claim_id': claimId,
        'image_url': imageUrl,
        'timestamp': timestamp,
        'gps_location': gpsLocation,
        'photo_type': photoType,
      };
}
