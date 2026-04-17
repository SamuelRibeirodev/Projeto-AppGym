import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/exercicio.dart';

class ExercicioService {
  static const String _fileName = 'exercicios.json';

  Future<Directory> _appDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  Future<File> _storageFile() async {
    final dir = await _appDirectory();
    return File(path.join(dir.path, _fileName));
  }

  Future<List<Exercicio>> loadExercicios() async {
    final file = await _storageFile();
    if (await file.exists()) {
      final content = await file.readAsString();
      try {
        final List<dynamic> data = jsonDecode(content) as List<dynamic>;
        return data
            .map((item) => Exercicio.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  Future<void> saveExercicios(List<Exercicio> exercicios) async {
    final file = await _storageFile();
    final jsonData = exercicios.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonData));
  }

  Future<String?> saveImage(File imageFile) async {
    final dir = await _appDirectory();
    final filename =
        '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
    final savedFile = File(path.join(dir.path, filename));
    await imageFile.copy(savedFile.path);
    return savedFile.path;
  }

  Future<void> deleteImage(String? imagePath) async {
    if (imagePath != null && await File(imagePath).exists()) {
      await File(imagePath).delete();
    }
  }
}
