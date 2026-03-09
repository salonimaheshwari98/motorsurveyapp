class Assessment {
  final int id;
  final int claimId;
  String inspectionNotes;
  double liability;
  String recommendation;
  double finalAmount;

  Assessment({
    required this.id,
    required this.claimId,
    this.inspectionNotes = '',
    this.liability = 0,
    this.recommendation = '',
    this.finalAmount = 0,
  });

  factory Assessment.fromJson(Map<String, dynamic> json) => Assessment(
        id: json['id'] as int? ?? 0,
        claimId: json['claim_id'] as int? ?? 0,
        inspectionNotes: json['inspection_notes'] as String? ?? '',
        liability: (json['liability'] as num?)?.toDouble() ?? 0.0,
        recommendation: json['recommendation'] as String? ?? '',
        finalAmount: (json['final_amount'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'claim_id': claimId,
        'inspection_notes': inspectionNotes,
        'liability': liability,
        'recommendation': recommendation,
        'final_amount': finalAmount,
      };
}
