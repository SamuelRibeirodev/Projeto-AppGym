import 'package:flutter/material.dart';

import '../models/exercicio.dart';
import '../services/exercicio_service.dart';
import '../widgets/exercicio_card.dart';
import '../widgets/exercicio_form.dart';

class ExercicioTela extends StatefulWidget {
  const ExercicioTela({super.key});

  @override
  State<ExercicioTela> createState() => _ExercicioTelaState();
}

class _ExercicioTelaState extends State<ExercicioTela> {
  final List<Exercicio> _exercicios = [];
  final ExercicioService _service = ExercicioService();
  int _selectedPageIndex = 0;
  String _filtroTreino = 'Todos';

  List<String> get _treinosParaFiltro {
    final treinos = ['Todos', 'Treino A', 'Treino B', 'Treino C'];
    for (final treino in _exercicios.map((e) => e.treino)) {
      if (!treinos.contains(treino)) {
        treinos.add(treino);
      }
    }
    return treinos;
  }

  @override
  void initState() {
    super.initState();
    _loadExercicios();
  }

  Future<void> _loadExercicios() async {
    final exercicios = await _service.loadExercicios();
    setState(() {
      _exercicios
        ..clear()
        ..addAll(exercicios);
    });
  }

  Future<void> _saveExercicios() async {
    await _service.saveExercicios(_exercicios);
  }

  Future<void> _showExercicioForm({Exercicio? exercicioParaEditar}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return ExercicioForm(
          exercicioParaEditar: exercicioParaEditar,
          onSave: (exercicio) async {
            if (exercicioParaEditar != null) {
              // Editando exercício existente
              final index = _exercicios.indexOf(exercicioParaEditar);
              if (index != -1) {
                setState(() {
                  _exercicios[index] = exercicio;
                });
              }
            } else {
              // Adicionando novo exercício
              setState(() {
                _exercicios.insert(0, exercicio);
              });
            }
            await _saveExercicios();
            if (!mounted) return;
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  exercicioParaEditar != null
                      ? 'Exercício atualizado!'
                      : 'Exercício adicionado!',
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteExercicio(Exercicio exercicio) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir "${exercicio.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _exercicios.remove(exercicio);
      });
      await _service.deleteImage(exercicio.fotoPath);
      await _saveExercicios();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Exercício excluído!')));
    }
  }

  Widget _buildTreinosTab(List<Exercicio> filteredExercicios) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seus exercícios',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Adicione exercícios com repetições, séries e foto para acompanhar seu treino.',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _treinosParaFiltro.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final treino = _treinosParaFiltro[index];
              return ChoiceChip(
                label: Text(treino),
                selected: _filtroTreino == treino,
                onSelected: (_) {
                  setState(() {
                    _filtroTreino = treino;
                  });
                },
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: filteredExercicios.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.fitness_center,
                        size: 64,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _exercicios.isEmpty
                            ? 'Nenhum exercício cadastrado ainda.'
                            : 'Nenhum exercício encontrado para "$_filtroTreino".',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Use o botão + para adicionar um exercício.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: filteredExercicios.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final exercicio = filteredExercicios[index];
                    return ExercicioCard(
                      exercicio: exercicio,
                      onEdit: () =>
                          _showExercicioForm(exercicioParaEditar: exercicio),
                      onDelete: () => _deleteExercicio(exercicio),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHistoricoTab() {
    final historico = [..._exercicios]
      ..sort((a, b) => b.criadoEm.compareTo(a.criadoEm));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Histórico',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Veja seus exercícios salvos em ordem de criação.',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: historico.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.history, size: 64, color: Colors.blueGrey),
                      SizedBox(height: 12),
                      Text(
                        'Ainda não há histórico de exercícios.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: historico.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final exercicio = historico[index];
                    return Card(
                      color: _corDoTreino(exercicio.treino),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    exercicio.nome,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${exercicio.criadoEm.day}/${exercicio.criadoEm.month}/${exercicio.criadoEm.year}',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${exercicio.series} séries × ${exercicio.repeticoes} repetições',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              exercicio.treino,
                              style: const TextStyle(color: Colors.black54),
                            ),
                            if (exercicio.observacao != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                exercicio.observacao!,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Color _corDoTreino(String treino) {
    switch (treino) {
      case 'Treino A':
        return Colors.blue.shade100;
      case 'Treino B':
        return Colors.indigo.shade100;
      case 'Treino C':
        return Colors.teal.shade100;
      default:
        return Colors.blueGrey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredExercicios = _filtroTreino == 'Todos'
        ? _exercicios
        : _exercicios.where((e) => e.treino == _filtroTreino).toList();

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: const Text('Meu Treino'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
      ),
      floatingActionButton: _selectedPageIndex == 0
          ? FloatingActionButton(
              onPressed: () => _showExercicioForm(),
              tooltip: 'Adicionar novo exercício',
              child: const Icon(Icons.add),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _selectedPageIndex == 0
            ? _buildTreinosTab(filteredExercicios)
            : _buildHistoricoTab(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPageIndex,
        selectedItemColor: Colors.blue.shade800,
        onTap: (index) {
          setState(() {
            _selectedPageIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Treinos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Histórico',
          ),
        ],
      ),
    );
  }
}
