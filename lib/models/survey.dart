class Survey {
  const Survey({
    required this.id,
    required this.title,
    required this.description,
    required this.question,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.companyId,
    required this.createdByUserId,
  });

  final String id;
  final String title;
  final String description;
  final String question;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String companyId;
  final String createdByUserId;

  String get publicLink => 'https://firenps.app/publico/$id';

  Survey copyWith({
    String? title,
    String? description,
    String? question,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return Survey(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      question: question ?? this.question,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      companyId: companyId,
      createdByUserId: createdByUserId,
    );
  }
}
