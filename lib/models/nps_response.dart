enum NpsClassification { promoter, neutral, detractor }

class NpsResponse {
  const NpsResponse({
    required this.id,
    required this.surveyId,
    required this.contactName,
    required this.email,
    required this.comment,
    required this.score,
    required this.region,
    required this.state,
    required this.createdAt,
  });

  final String id;
  final String surveyId;
  final String contactName;
  final String email;
  final String comment;
  final int score;
  final String region;
  final String state;
  final DateTime createdAt;

  NpsClassification get classification {
    if (score >= 9) {
      return NpsClassification.promoter;
    }
    if (score >= 7) {
      return NpsClassification.neutral;
    }
    return NpsClassification.detractor;
  }
}
