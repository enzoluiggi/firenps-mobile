import 'package:flutter/material.dart';

import '../../data/fire_nps_controller.dart';
import '../../models/survey.dart';
import '../../widgets/app_shell_widgets.dart';

class PublicSurveyScreen extends StatefulWidget {
  const PublicSurveyScreen({
    super.key,
    required this.controller,
    required this.survey,
  });

  final FireNpsController controller;
  final Survey survey;

  @override
  State<PublicSurveyScreen> createState() => _PublicSurveyScreenState();
}

class _PublicSurveyScreenState extends State<PublicSurveyScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final commentController = TextEditingController();
  final regionController = TextEditingController(text: 'Sudeste');
  final stateController = TextEditingController(text: 'SP');
  int score = 10;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    commentController.dispose();
    regionController.dispose();
    stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resposta publica')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FireCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.survey.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(widget.survey.question),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(11, (index) {
                    final isSelected = score == index;
                    return ChoiceChip(
                      label: Text('$index'),
                      selected: isSelected,
                      onSelected: (_) => setState(() => score = index),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Comentario'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: regionController,
                        decoration: const InputDecoration(labelText: 'Regiao'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: stateController,
                        decoration: const InputDecoration(labelText: 'Estado'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      widget.controller.submitSurveyResponse(
                        survey: widget.survey,
                        name: nameController.text,
                        email: emailController.text,
                        comment: commentController.text,
                        score: score,
                        region: regionController.text,
                        state: stateController.text,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Resposta enviada com sucesso.'),
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                    child: const Text('Enviar resposta'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
