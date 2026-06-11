class Contact {
  const Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.createdByUserId,
    required this.companyId,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String createdByUserId;
  final String companyId;
}
