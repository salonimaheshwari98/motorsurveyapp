class Claim {
  final int id;
  final String claimNumber;
  final String policyNumber;
  final String insurer;
  final String insuredName;
  final String phone;
  final String vehicleNumber;
  final String vehicleModel;
  final int manufactureYear;
  final DateTime accidentDate;
  final String accidentLocation;
  final String status;

  Claim({
    required this.id,
    required this.claimNumber,
    required this.policyNumber,
    required this.insurer,
    required this.insuredName,
    required this.phone,
    required this.vehicleNumber,
    required this.vehicleModel,
    required this.manufactureYear,
    required this.accidentDate,
    required this.accidentLocation,
    required this.status,
  });

  factory Claim.fromJson(Map<String, dynamic> json) => Claim(
        id: json['id'] as int,
        claimNumber: json['claim_number'] as String? ?? '',
        policyNumber: json['policy_number'] as String? ?? '',
        insurer: json['insurer'] as String? ?? '',
        insuredName: json['insured_name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        vehicleNumber: json['vehicle_number'] as String? ?? '',
        vehicleModel: json['vehicle_model'] as String? ?? '',
        manufactureYear: json['manufacture_year'] as int? ?? 0,
        accidentDate: DateTime.tryParse(json['accident_date'] ?? '') ?? DateTime.now(),
        accidentLocation: json['accident_location'] as String? ?? '',
        status: json['status'] as String? ?? 'pending',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'claim_number': claimNumber,
        'policy_number': policyNumber,
        'insurer': insurer,
        'insured_name': insuredName,
        'phone': phone,
        'vehicle_number': vehicleNumber,
        'vehicle_model': vehicleModel,
        'manufacture_year': manufactureYear,
        'accident_date': accidentDate.toIso8601String().split('T').first,
        'accident_location': accidentLocation,
        'status': status,
      };
}
