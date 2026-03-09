class SurveyDocument {
  final int id;
  final int claimId;
  final String documentType;
  final String fileUrl;

  SurveyDocument({
    required this.id,
    required this.claimId,
    required this.documentType,
    required this.fileUrl,
  });

  factory SurveyDocument.fromJson(Map<String, dynamic> json) =>
      SurveyDocument(
        id: json['id'] as int? ?? 0,
        claimId: json['claim_id'] as int? ?? 0,
        documentType: json['document_type'] as String? ?? '',
        fileUrl: json['file_url'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'claim_id': claimId,
        'document_type': documentType,
        'file_url': fileUrl,
      };
}
