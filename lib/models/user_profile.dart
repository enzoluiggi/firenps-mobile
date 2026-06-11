class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.companyName,
    required this.businessSegment,
    required this.companyId,
    required this.role,
  });

  final String id;
  final String fullName;
  final String email;
  final String companyName;
  final String businessSegment;
  final String companyId;
  final String role;

  UserProfile copyWith({
    String? fullName,
    String? companyName,
    String? businessSegment,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      companyName: companyName ?? this.companyName,
      businessSegment: businessSegment ?? this.businessSegment,
      companyId: companyId,
      role: role,
    );
  }
}
