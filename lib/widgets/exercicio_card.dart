import 'package:flutter/material.dart';

import '../models/exercicio.dart';

class ExercicioCard extends StatelessWidget {
  final Exercicio exercicio;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExercicioCard({
    super.key,
    required this.exercicio,
    required this.onEdit,
    required this.onDelete,
  });

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
    return Card(
      color: _corDoTreino(exercicio.treino),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 92,
                height: 92,
                color: Colors.blue.shade50,
                child: exercicio.fotoFile != null
                    ? Image.file(exercicio.fotoFile!, fit: BoxFit.cover)
                    : const Icon(
                        Icons.image_not_supported,
                        size: 44,
                        color: Colors.blueGrey,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercicio.nome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${exercicio.series} séries × ${exercicio.repeticoes} repetições',
                  ),
                  const SizedBox(height: 6),
                  Text(
                    exercicio.treino,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
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
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'Editar exercício',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Excluir exercício',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
