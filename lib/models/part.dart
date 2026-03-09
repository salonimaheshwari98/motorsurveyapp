class PartItem {
  final int id;
  final int claimId;
  String partName;
  int quantity;
  double rate;
  double amount;
  String materialType;
  double depreciationPercent;
  double approvedAmount;
  bool accepted;

  PartItem({
    required this.id,
    required this.claimId,
    required this.partName,
    required this.quantity,
    required this.rate,
    required this.amount,
    required this.materialType,
    this.depreciationPercent = 0.0,
    this.approvedAmount = 0.0,
    this.accepted = false,
  });

  factory PartItem.fromJson(Map<String, dynamic> json) => PartItem(
        id: json['id'] as int? ?? 0,
        claimId: json['claim_id'] as int? ?? 0,
        partName: json['part_name'] as String? ?? '',
        quantity: json['quantity'] as int? ?? 1,
        rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        materialType: json['material_type'] as String? ?? '',
        depreciationPercent:
            (json['depreciation_percent'] as num?)?.toDouble() ?? 0.0,
        approvedAmount:
            (json['approved_amount'] as num?)?.toDouble() ?? 0.0,
        accepted: json['accepted'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'claim_id': claimId,
        'part_name': partName,
        'quantity': quantity,
        'rate': rate,
        'amount': amount,
        'material_type': materialType,
        'depreciation_percent': depreciationPercent,
        'approved_amount': approvedAmount,
        'accepted': accepted,
      };
}
