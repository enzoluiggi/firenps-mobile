import 'package:flutter/material.dart';

import '../models/company.dart';
import '../models/contact.dart';
import '../models/nps_response.dart';
import '../models/survey.dart';
import '../models/user_profile.dart';
import 'local_database.dart';

class NpsMetrics {
  const NpsMetrics({
    required this.total,
    required this.promoters,
    required this.neutrals,
    required this.detractors,
    required this.score,
  });

  final int total;
  final int promoters;
  final int neutrals;
  final int detractors;
  final double score;

  double get promoterRate => total == 0 ? 0 : (promoters / total) * 100;
  double get neutralRate => total == 0 ? 0 : (neutrals / total) * 100;
  double get detractorRate => total == 0 ? 0 : (detractors / total) * 100;

  String get zone {
    if (score >= 75) {
      return 'Excelencia';
    }
    if (score >= 50) {
      return 'Qualidade';
    }
    if (score >= 0) {
      return 'Aperfeicoamento';
    }
    return 'Critica';
  }
}

class FireNpsController extends ChangeNotifier {
  FireNpsController() {
    _seed();
    ready = _loadLocalAuthData();
  }

  final LocalDatabase _localDatabase = LocalDatabase();
  final List<Company> _companies = [];
  final List<UserProfile> _users = [];
  final List<Contact> _contacts = [];
  final List<Survey> _surveys = [];
  final List<NpsResponse> _responses = [];
  final Map<String, String> _passwordsByEmail = {};

  UserProfile? _currentUser;
  String? authMessage;
  late final Future<void> ready;
  bool isLoadingAuthData = true;

  bool get isAuthenticated => _currentUser != null;
  UserProfile? get currentUser => _currentUser;
  List<Survey> get companySurveys =>
      _surveys.where((item) => item.companyId == currentCompanyId).toList();
  List<Contact> get companyContacts =>
      _contacts.where((item) => item.companyId == currentCompanyId).toList();
  List<UserProfile> get companyUsers =>
      _users.where((item) => item.companyId == currentCompanyId).toList();

  List<NpsResponse> get companyResponses {
    final surveyIds = companySurveys.map((survey) => survey.id).toSet();
    return _responses
        .where((item) => surveyIds.contains(item.surveyId))
        .toList();
  }

  String get currentCompanyId => _currentUser?.companyId ?? '';

  bool get canManageCompany {
    const roles = {'admin', 'gestor', 'analista'};
    return roles.contains(_currentUser?.role);
  }

  Future<void> login({required String email, required String password}) async {
    await ready;

    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password.trim();
    UserProfile? user;
    for (final item in _users) {
      if (item.email.toLowerCase() == normalizedEmail) {
        user = item;
        break;
      }
    }

    // A senha digitada e comparada com a senha salva no SQLite para este e-mail.
    if (user == null ||
        _passwordsByEmail[normalizedEmail] != normalizedPassword) {
      authMessage = 'Nao foi possivel entrar. Verifique e-mail e senha.';
      notifyListeners();
      return;
    }

    _currentUser = user;
    authMessage = 'Sessao iniciada com sucesso.';
    notifyListeners();
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    String? companyName,
    String? segment,
  }) async {
    await ready;

    final normalizedName = fullName.trim();
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password.trim();
    final normalizedCompanyName = (companyName ?? '$normalizedName Company')
        .trim();
    final normalizedSegment = (segment ?? 'Nao informado').trim();

    final emailAlreadyExists = _users.any(
      (item) => item.email.toLowerCase() == normalizedEmail,
    );

    if (normalizedName.isEmpty ||
        normalizedEmail.isEmpty ||
        normalizedPassword.length < 4) {
      authMessage = 'Preencha os campos obrigatorios e use uma senha valida.';
      notifyListeners();
      return;
    }

    if (emailAlreadyExists) {
      authMessage = 'Ja existe uma conta cadastrada com este e-mail.';
      notifyListeners();
      return;
    }

    final company = Company(
      id: 'company-${_companies.length + 1}',
      name: normalizedCompanyName,
      segment: normalizedSegment.isEmpty ? 'Nao informado' : normalizedSegment,
    );
    _companies.add(company);

    final newUser = UserProfile(
      id: 'user-${_users.length + 1}',
      fullName: normalizedName,
      email: normalizedEmail,
      companyName: company.name,
      businessSegment: company.segment,
      companyId: company.id,
      role: 'client',
    );

    _users.add(newUser);
    _passwordsByEmail[normalizedEmail] = normalizedPassword;

    // Depois de cadastrar em memoria, tambem gravamos no SQLite para nao perder
    // o login quando o app for fechado ou o aparelho for reiniciado.
    await _localDatabase.saveCompanyAndUser(
      company: company,
      user: newUser,
      password: normalizedPassword,
    );

    _currentUser = newUser;
    authMessage = 'Cadastro concluido. Perfil e empresa foram criados.';
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    authMessage = 'Sessao encerrada.';
    notifyListeners();
  }

  Future<void> updateProfile({
    required String fullName,
    required String companyName,
    required String segment,
  }) async {
    await ready;

    if (_currentUser == null) {
      return;
    }

    final updatedUser = _currentUser!.copyWith(
      fullName: fullName.trim(),
      companyName: companyName.trim(),
      businessSegment: segment.trim(),
    );

    final userIndex = _users.indexWhere((item) => item.id == updatedUser.id);
    if (userIndex != -1) {
      _users[userIndex] = updatedUser;
    }

    final companyIndex = _companies.indexWhere(
      (item) => item.id == updatedUser.companyId,
    );
    final updatedCompany = Company(
      id: updatedUser.companyId,
      name: companyName.trim(),
      segment: segment.trim(),
    );

    if (companyIndex != -1) {
      _companies[companyIndex] = updatedCompany;
    }

    _currentUser = updatedUser;
    await _localDatabase.updateCompanyAndUser(
      company: updatedCompany,
      user: updatedUser,
    );
    notifyListeners();
  }

  Future<void> _loadLocalAuthData() async {
    isLoadingAuthData = true;
    notifyListeners();

    // Na primeira execucao, os usuarios demonstrativos sao copiados para o banco.
    // Nas proximas execucoes, o app apenas le o que ja esta salvo no aparelho.
    await _localDatabase.bootstrapIfEmpty(
      companies: _companies,
      users: _users,
      defaultPassword: '1234',
    );

    final authData = await _localDatabase.loadAuthData();
    _companies
      ..clear()
      ..addAll(authData.companies);
    _users
      ..clear()
      ..addAll(authData.users);
    _passwordsByEmail
      ..clear()
      ..addAll(authData.passwordsByEmail);

    _ensureLorenGuardSurvey();

    isLoadingAuthData = false;
    notifyListeners();
  }

  void _ensureLorenGuardSurvey() {
    const surveyId = 'survey-lorenguard-experiencia-cliente';
    UserProfile? lorenGuardUser;
    for (final user in _users) {
      if (user.email.toLowerCase() == 'lorenguard02@gmail.com') {
        lorenGuardUser = user;
        break;
      }
    }

    if (lorenGuardUser == null) {
      return;
    }

    final alreadyCreated = _surveys.any((survey) => survey.id == surveyId);
    if (!alreadyCreated) {
      // Esta pesquisa e criada para o usuario cadastrado no SQLite. O companyId
      // faz com que ela apareca apenas para usuarios da mesma empresa.
      _surveys.add(
        Survey(
          id: surveyId,
          title: 'Pesquisa de Satisfacao e Experiencia do Cliente',
          description:
              'Avaliacao estruturada para medir satisfacao, qualidade do atendimento, facilidade de uso e chance de recomendacao.',
          question:
              'De 0 a 10, qual a probabilidade de voce recomendar nossos servicos para outra pessoa?',
          startDate: DateTime(2026, 6, 1),
          endDate: DateTime(2026, 7, 31),
          isActive: true,
          companyId: lorenGuardUser.companyId,
          createdByUserId: lorenGuardUser.id,
        ),
      );
    }

    _ensureLorenGuardContactsAndResponses(
      user: lorenGuardUser,
      surveyId: surveyId,
    );
  }

  void _ensureLorenGuardContactsAndResponses({
    required UserProfile user,
    required String surveyId,
  }) {
    final alreadySeeded = _responses.any(
      (response) => response.surveyId == surveyId,
    );
    if (alreadySeeded) {
      return;
    }

    // Estes contatos simulam clientes reais para que o painel e os relatorios
    // tenham dados variados logo apos o login do usuario informado.
    final contacts = [
      Contact(
        id: 'contact-lorenguard-1',
        name: 'Bruna Almeida',
        email: 'bruna.almeida@cliente.com',
        phone: '(11) 98811-1001',
        createdByUserId: user.id,
        companyId: user.companyId,
      ),
      Contact(
        id: 'contact-lorenguard-2',
        name: 'Rafael Gomes',
        email: 'rafael.gomes@cliente.com',
        phone: '(21) 97722-2002',
        createdByUserId: user.id,
        companyId: user.companyId,
      ),
      Contact(
        id: 'contact-lorenguard-3',
        name: 'Camila Fernandes',
        email: 'camila.fernandes@cliente.com',
        phone: '(31) 96633-3003',
        createdByUserId: user.id,
        companyId: user.companyId,
      ),
      Contact(
        id: 'contact-lorenguard-4',
        name: 'Thiago Ribeiro',
        email: 'thiago.ribeiro@cliente.com',
        phone: '(41) 95544-4004',
        createdByUserId: user.id,
        companyId: user.companyId,
      ),
      Contact(
        id: 'contact-lorenguard-5',
        name: 'Juliana Castro',
        email: 'juliana.castro@cliente.com',
        phone: '(51) 94455-5005',
        createdByUserId: user.id,
        companyId: user.companyId,
      ),
      Contact(
        id: 'contact-lorenguard-6',
        name: 'Marcos Oliveira',
        email: 'marcos.oliveira@cliente.com',
        phone: '(61) 93366-6006',
        createdByUserId: user.id,
        companyId: user.companyId,
      ),
      Contact(
        id: 'contact-lorenguard-7',
        name: 'Patricia Lima',
        email: 'patricia.lima@cliente.com',
        phone: '(71) 92277-7007',
        createdByUserId: user.id,
        companyId: user.companyId,
      ),
      Contact(
        id: 'contact-lorenguard-8',
        name: 'Eduardo Santos',
        email: 'eduardo.santos@cliente.com',
        phone: '(81) 91188-8008',
        createdByUserId: user.id,
        companyId: user.companyId,
      ),
      Contact(
        id: 'contact-lorenguard-9',
        name: 'Fernanda Rocha',
        email: 'fernanda.rocha@cliente.com',
        phone: '(85) 90099-9009',
        createdByUserId: user.id,
        companyId: user.companyId,
      ),
      Contact(
        id: 'contact-lorenguard-10',
        name: 'Lucas Martins',
        email: 'lucas.martins@cliente.com',
        phone: '(92) 98910-1010',
        createdByUserId: user.id,
        companyId: user.companyId,
      ),
      Contact(
        id: 'contact-lorenguard-11',
        name: 'Aline Souza',
        email: 'aline.souza@cliente.com',
        phone: '(27) 97821-1111',
        createdByUserId: user.id,
        companyId: user.companyId,
      ),
      Contact(
        id: 'contact-lorenguard-12',
        name: 'Henrique Moreira',
        email: 'henrique.moreira@cliente.com',
        phone: '(48) 96732-1212',
        createdByUserId: user.id,
        companyId: user.companyId,
      ),
    ];

    for (final contact in contacts) {
      final exists = _contacts.any((item) => item.id == contact.id);
      if (!exists) {
        _contacts.add(contact);
      }
    }

    // As notas foram distribuidas entre promotores, neutros e detratores para
    // demonstrar os calculos de NPS e deixar os graficos mais interessantes.
    _responses.addAll([
      NpsResponse(
        id: 'response-lorenguard-1',
        surveyId: surveyId,
        contactName: 'Bruna Almeida',
        email: 'bruna.almeida@cliente.com',
        comment: 'Atendimento rapido, equipe educada e solucao clara.',
        score: 10,
        region: 'Sudeste',
        state: 'SP',
        createdAt: DateTime(2026, 6, 3),
      ),
      NpsResponse(
        id: 'response-lorenguard-2',
        surveyId: surveyId,
        contactName: 'Rafael Gomes',
        email: 'rafael.gomes@cliente.com',
        comment: 'Gostei do servico, mas o primeiro contato demorou um pouco.',
        score: 8,
        region: 'Sudeste',
        state: 'RJ',
        createdAt: DateTime(2026, 6, 5),
      ),
      NpsResponse(
        id: 'response-lorenguard-3',
        surveyId: surveyId,
        contactName: 'Camila Fernandes',
        email: 'camila.fernandes@cliente.com',
        comment: 'Experiencia excelente do inicio ao fim.',
        score: 9,
        region: 'Sudeste',
        state: 'MG',
        createdAt: DateTime(2026, 6, 7),
      ),
      NpsResponse(
        id: 'response-lorenguard-4',
        surveyId: surveyId,
        contactName: 'Thiago Ribeiro',
        email: 'thiago.ribeiro@cliente.com',
        comment: 'O resultado foi bom, porem faltou acompanhamento posterior.',
        score: 7,
        region: 'Sul',
        state: 'PR',
        createdAt: DateTime(2026, 6, 9),
      ),
      NpsResponse(
        id: 'response-lorenguard-5',
        surveyId: surveyId,
        contactName: 'Juliana Castro',
        email: 'juliana.castro@cliente.com',
        comment:
            'Achei o processo confuso e precisei pedir ajuda varias vezes.',
        score: 5,
        region: 'Sul',
        state: 'RS',
        createdAt: DateTime(2026, 6, 11),
      ),
      NpsResponse(
        id: 'response-lorenguard-6',
        surveyId: surveyId,
        contactName: 'Marcos Oliveira',
        email: 'marcos.oliveira@cliente.com',
        comment: 'Funcionalidade boa, suporte prestativo e entrega no prazo.',
        score: 9,
        region: 'Centro-Oeste',
        state: 'DF',
        createdAt: DateTime(2026, 6, 13),
      ),
      NpsResponse(
        id: 'response-lorenguard-7',
        surveyId: surveyId,
        contactName: 'Patricia Lima',
        email: 'patricia.lima@cliente.com',
        comment: 'Indicaria para outras pessoas pelo cuidado no atendimento.',
        score: 10,
        region: 'Nordeste',
        state: 'BA',
        createdAt: DateTime(2026, 6, 15),
      ),
      NpsResponse(
        id: 'response-lorenguard-8',
        surveyId: surveyId,
        contactName: 'Eduardo Santos',
        email: 'eduardo.santos@cliente.com',
        comment: 'Atendeu minha necessidade, mas poderia ser mais simples.',
        score: 7,
        region: 'Nordeste',
        state: 'PE',
        createdAt: DateTime(2026, 6, 17),
      ),
      NpsResponse(
        id: 'response-lorenguard-9',
        surveyId: surveyId,
        contactName: 'Fernanda Rocha',
        email: 'fernanda.rocha@cliente.com',
        comment: 'Tive dificuldade para entender as etapas do atendimento.',
        score: 4,
        region: 'Nordeste',
        state: 'CE',
        createdAt: DateTime(2026, 6, 19),
      ),
      NpsResponse(
        id: 'response-lorenguard-10',
        surveyId: surveyId,
        contactName: 'Lucas Martins',
        email: 'lucas.martins@cliente.com',
        comment: 'Muito satisfeito, voltaria a contratar sem duvidas.',
        score: 10,
        region: 'Norte',
        state: 'AM',
        createdAt: DateTime(2026, 6, 21),
      ),
      NpsResponse(
        id: 'response-lorenguard-11',
        surveyId: surveyId,
        contactName: 'Aline Souza',
        email: 'aline.souza@cliente.com',
        comment: 'A entrega foi correta, mas a comunicacao pode melhorar.',
        score: 6,
        region: 'Sudeste',
        state: 'ES',
        createdAt: DateTime(2026, 6, 23),
      ),
      NpsResponse(
        id: 'response-lorenguard-12',
        surveyId: surveyId,
        contactName: 'Henrique Moreira',
        email: 'henrique.moreira@cliente.com',
        comment: 'Equipe organizada, retorno rapido e bom acompanhamento.',
        score: 9,
        region: 'Sul',
        state: 'SC',
        createdAt: DateTime(2026, 6, 25),
      ),
    ]);
  }

  void addContact({
    required String name,
    required String email,
    required String phone,
  }) {
    if (_currentUser == null || name.trim().isEmpty) {
      return;
    }

    _contacts.add(
      Contact(
        id: 'contact-${_contacts.length + 1}',
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        createdByUserId: _currentUser!.id,
        companyId: _currentUser!.companyId,
      ),
    );
    notifyListeners();
  }

  void addSurvey({
    required String title,
    required String description,
    required String question,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (_currentUser == null ||
        title.trim().isEmpty ||
        question.trim().isEmpty) {
      return;
    }

    _surveys.add(
      Survey(
        id: 'survey-${_surveys.length + 1}',
        title: title.trim(),
        description: description.trim(),
        question: question.trim(),
        startDate: startDate,
        endDate: endDate,
        isActive: true,
        companyId: _currentUser!.companyId,
        createdByUserId: _currentUser!.id,
      ),
    );
    notifyListeners();
  }

  void toggleSurvey(Survey survey) {
    final index = _surveys.indexWhere((item) => item.id == survey.id);
    if (index == -1) {
      return;
    }

    _surveys[index] = survey.copyWith(isActive: !survey.isActive);
    notifyListeners();
  }

  void submitSurveyResponse({
    required Survey survey,
    required String name,
    required String email,
    required String comment,
    required int score,
    required String region,
    required String state,
  }) {
    if (score < 0 || score > 10 || name.trim().isEmpty) {
      return;
    }

    _responses.add(
      NpsResponse(
        id: 'response-${_responses.length + 1}',
        surveyId: survey.id,
        contactName: name.trim(),
        email: email.trim(),
        comment: comment.trim(),
        score: score,
        region: region.trim(),
        state: state.trim(),
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  NpsMetrics metricsForSurvey(String? surveyId, DateTimeRange? range) {
    final filtered = filteredResponses(surveyId, range);
    final promoters = filtered
        .where((item) => item.classification == NpsClassification.promoter)
        .length;
    final neutrals = filtered
        .where((item) => item.classification == NpsClassification.neutral)
        .length;
    final detractors = filtered
        .where((item) => item.classification == NpsClassification.detractor)
        .length;
    final total = filtered.length;
    final score = total == 0 ? 0.0 : ((promoters - detractors) / total) * 100;

    return NpsMetrics(
      total: total,
      promoters: promoters,
      neutrals: neutrals,
      detractors: detractors,
      score: score,
    );
  }

  Map<int, int> distributionForSurvey(String? surveyId, DateTimeRange? range) {
    final distribution = {for (var score = 0; score <= 10; score++) score: 0};
    for (final response in filteredResponses(surveyId, range)) {
      distribution[response.score] = distribution[response.score]! + 1;
    }
    return distribution;
  }

  List<NpsResponse> filteredResponses(String? surveyId, DateTimeRange? range) {
    return companyResponses.where((response) {
      final matchesSurvey = surveyId == null || response.surveyId == surveyId;
      final matchesRange =
          range == null ||
          (response.createdAt.isAfter(
                range.start.subtract(const Duration(days: 1)),
              ) &&
              response.createdAt.isBefore(
                range.end.add(const Duration(days: 1)),
              ));
      return matchesSurvey && matchesRange;
    }).toList();
  }

  String exportResponsesAsCsv(String? surveyId, DateTimeRange? range) {
    final buffer = StringBuffer();
    buffer.writeln(
      'pesquisa,respondente,email,nota,feedback,regiao,estado,data',
    );

    final surveysById = {
      for (final survey in companySurveys) survey.id: survey,
    };
    for (final response in filteredResponses(surveyId, range)) {
      final survey = surveysById[response.surveyId];
      buffer.writeln(
        '${survey?.title ?? 'Pesquisa'},'
        '${response.contactName},'
        '${response.email},'
        '${response.score},'
        '${response.comment.replaceAll(',', ';')},'
        '${response.region},'
        '${response.state},'
        '${response.createdAt.toIso8601String()}',
      );
    }
    return buffer.toString();
  }

  void _seed() {
    final company = Company(
      id: 'company-1',
      name: 'TechSolutions Ltda',
      segment: 'Servicos B2B',
    );
    _companies.add(company);

    final admin = UserProfile(
      id: 'user-1',
      fullName: 'Carlos Silva',
      email: 'carlos@techsolutions.com',
      companyName: company.name,
      businessSegment: company.segment,
      companyId: company.id,
      role: 'admin',
    );
    final analyst = UserProfile(
      id: 'user-2',
      fullName: 'Marina Costa',
      email: 'marina@techsolutions.com',
      companyName: company.name,
      businessSegment: company.segment,
      companyId: company.id,
      role: 'analista',
    );
    _users.addAll([admin, analyst]);

    _contacts.addAll([
      Contact(
        id: 'contact-1',
        name: 'Ana Martins',
        email: 'ana@cliente.com',
        phone: '(11) 99999-1122',
        createdByUserId: admin.id,
        companyId: company.id,
      ),
      Contact(
        id: 'contact-2',
        name: 'Pedro Lima',
        email: 'pedro@cliente.com',
        phone: '(21) 97777-2211',
        createdByUserId: analyst.id,
        companyId: company.id,
      ),
    ]);

    _surveys.add(
      Survey(
        id: 'survey-1',
        title: 'Pesquisa de Satisfacao Q1 2026',
        description: 'Medicao de satisfacao dos clientes',
        question:
            'De 0 a 10, quanto voce indicaria a TechSolutions para um colega?',
        startDate: DateTime(2026, 4, 1),
        endDate: DateTime(2026, 4, 30),
        isActive: true,
        companyId: company.id,
        createdByUserId: admin.id,
      ),
    );

    _responses.addAll([
      NpsResponse(
        id: 'response-1',
        surveyId: 'survey-1',
        contactName: 'Ana Martins',
        email: 'ana@cliente.com',
        comment: 'Atendimento rapido e simples.',
        score: 10,
        region: 'Sudeste',
        state: 'SP',
        createdAt: DateTime(2026, 4, 4),
      ),
      NpsResponse(
        id: 'response-2',
        surveyId: 'survey-1',
        contactName: 'Pedro Lima',
        email: 'pedro@cliente.com',
        comment: 'Produto bom, mas ainda tem alguns ajustes.',
        score: 8,
        region: 'Sudeste',
        state: 'RJ',
        createdAt: DateTime(2026, 4, 8),
      ),
      NpsResponse(
        id: 'response-3',
        surveyId: 'survey-1',
        contactName: 'Juliana Prado',
        email: 'juliana@cliente.com',
        comment: 'Demorou para responder uma solicitacao.',
        score: 4,
        region: 'Sul',
        state: 'SC',
        createdAt: DateTime(2026, 4, 12),
      ),
      NpsResponse(
        id: 'response-4',
        surveyId: 'survey-1',
        contactName: 'Fernando Alves',
        email: 'fernando@cliente.com',
        comment: 'Boa experiencia geral.',
        score: 9,
        region: 'Nordeste',
        state: 'PE',
        createdAt: DateTime(2026, 4, 14),
      ),
      NpsResponse(
        id: 'response-5',
        surveyId: 'survey-1',
        contactName: 'Luiza Nunes',
        email: 'luiza@cliente.com',
        comment: 'Esperava mais personalizacao.',
        score: 6,
        region: 'Centro-Oeste',
        state: 'GO',
        createdAt: DateTime(2026, 4, 15),
      ),
      NpsResponse(
        id: 'response-6',
        surveyId: 'survey-1',
        contactName: 'Camila Reis',
        email: 'camila@cliente.com',
        comment: 'Voltaria a contratar.',
        score: 9,
        region: 'Sudeste',
        state: 'MG',
        createdAt: DateTime(2026, 4, 15),
      ),
      NpsResponse(
        id: 'response-7',
        surveyId: 'survey-1',
        contactName: 'Guilherme Mota',
        email: 'guilherme@cliente.com',
        comment: 'A implantacao foi tranquila.',
        score: 10,
        region: 'Sul',
        state: 'PR',
        createdAt: DateTime(2026, 4, 16),
      ),
      NpsResponse(
        id: 'response-8',
        surveyId: 'survey-1',
        contactName: 'Renata Melo',
        email: 'renata@cliente.com',
        comment: 'Equipe educada, mas faltou acompanhamento.',
        score: 5,
        region: 'Norte',
        state: 'AM',
        createdAt: DateTime(2026, 4, 16),
      ),
      NpsResponse(
        id: 'response-9',
        surveyId: 'survey-1',
        contactName: 'Diego Rocha',
        email: 'diego@cliente.com',
        comment: 'Foi tudo dentro do esperado.',
        score: 7,
        region: 'Sudeste',
        state: 'SP',
        createdAt: DateTime(2026, 4, 16),
      ),
      NpsResponse(
        id: 'response-10',
        surveyId: 'survey-1',
        contactName: 'Beatriz Faria',
        email: 'beatriz@cliente.com',
        comment: 'Gostei bastante do suporte.',
        score: 10,
        region: 'Sudeste',
        state: 'ES',
        createdAt: DateTime(2026, 4, 16),
      ),
    ]);
  }
}
