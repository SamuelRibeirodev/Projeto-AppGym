import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/exercicio.dart';
import '../services/exercicio_service.dart';

class ExercicioForm extends StatefulWidget {
  final Exercicio? exercicioParaEditar;
  final Function(Exercicio) onSave;

  const ExercicioForm({
    super.key,
    this.exercicioParaEditar,
    required this.onSave,
  });

  @override
  State<ExercicioForm> createState() => _ExercicioFormState();
}

class _ExercicioFormState extends State<ExercicioForm> {
  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final seriesController = TextEditingController();
  final repeticoesController = TextEditingController();
  final observacaoController = TextEditingController();
  final treinoController = TextEditingController(text: 'Treino A');
  final ImagePicker _picker = ImagePicker();
  final ExercicioService _service = ExercicioService();

  String? selectedFotoPath;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.exercicioParaEditar != null) {
      isEditing = true;
      final exercicio = widget.exercicioParaEditar!;
      nomeController.text = exercicio.nome;
      seriesController.text = exercicio.series.toString();
      repeticoesController.text = exercicio.repeticoes.toString();
      treinoController.text = exercicio.treino;
      observacaoController.text = exercicio.observacao ?? '';
      selectedFotoPath = exercicio.fotoPath;
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    seriesController.dispose();
    repeticoesController.dispose();
    observacaoController.dispose();
    treinoController.dispose();
    super.dispose();
  }

  Future<String?> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );
    if (pickedFile == null) return null;

    final savedPath = await _service.saveImage(File(pickedFile.path));
    return savedPath;
  }

  void _saveExercicio() {
    if (formKey.currentState?.validate() ?? false) {
      final exercicio = Exercicio(
        nome: nomeController.text.trim(),
        series: int.parse(seriesController.text.trim()),
        repeticoes: int.parse(repeticoesController.text.trim()),
        treino: treinoController.text.trim(),
        observacao: observacaoController.text.trim().isEmpty
            ? null
            : observacaoController.text.trim(),
        fotoPath: selectedFotoPath,
        criadoEm: isEditing ? widget.exercicioParaEditar!.criadoEm : null,
      );
      widget.onSave(exercicio);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Editar Exercício' : 'Adicionar Exercício',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: ['Treino A', 'Treino B', 'Treino C'].map((treino) {
                  return ChoiceChip(
                    label: Text(treino),
                    selected: treinoController.text == treino,
                    onSelected: (_) {
                      setState(() {
                        treinoController.text = treino;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: treinoController,
                decoration: const InputDecoration(
                  labelText: 'Treino / grupo',
                  hintText: 'Treino A, Treino B ou outro',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o grupo do treino';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do exercício',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome do exercício';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: seriesController,
                      decoration: const InputDecoration(
                        labelText: 'Séries',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || int.tryParse(value) == null) {
                          return 'Informe número válido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: repeticoesController,
                      decoration: const InputDecoration(
                        labelText: 'Repetições',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || int.tryParse(value) == null) {
                          return 'Informe número válido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: observacaoController,
                decoration: const InputDecoration(
                  labelText: 'Observação (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        final pickedPath = await _pickImage(
                          ImageSource.gallery,
                        );
                        if (pickedPath != null) {
                          setState(() {
                            selectedFotoPath = pickedPath;
                          });
                        }
                      },
                      icon: const Icon(Icons.photo),
                      label: const Text('Galeria'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        final pickedPath = await _pickImage(ImageSource.camera);
                        if (pickedPath != null) {
                          setState(() {
                            selectedFotoPath = pickedPath;
                          });
                        }
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Câmera'),
                    ),
                  ),
                ],
              ),
              if (selectedFotoPath != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(selectedFotoPath!),
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _saveExercicio,
                child: Text(
                  isEditing ? 'Salvar alterações' : 'Salvar exercício',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
