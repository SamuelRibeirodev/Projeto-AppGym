import 'dart:io';

class Exercicio {
  final String nome;
  final int series;
  final int repeticoes;
  final String treino;
  final String? observacao;
  final String? fotoPath;
  final DateTime criadoEm;

  Exercicio({
    required this.nome,
    required this.series,
    required this.repeticoes,
    required this.treino,
    this.observacao,
    this.fotoPath,
    DateTime? criadoEm,
  }) : criadoEm = criadoEm ?? DateTime.now();

  File? get fotoFile => fotoPath == null ? null : File(fotoPath!);

  factory Exercicio.fromJson(Map<String, dynamic> json) {
    return Exercicio(
      nome: json['nome'] as String,
      series: json['series'] as int,
      repeticoes: json['repeticoes'] as int,
      treino: json['treino'] as String,
      observacao: json['observacao'] as String?,
      fotoPath: json['fotoPath'] as String?,
      criadoEm: DateTime.parse(json['criadoEm'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'series': series,
      'repeticoes': repeticoes,
      'treino': treino,
      'observacao': observacao,
      'fotoPath': fotoPath,
      'criadoEm': criadoEm.toIso8601String(),
    };
  }

  Exercicio copyWith({
    String? nome,
    int? series,
    int? repeticoes,
    String? treino,
    String? observacao,
    String? fotoPath,
    DateTime? criadoEm,
  }) {
    return Exercicio(
      nome: nome ?? this.nome,
      series: series ?? this.series,
      repeticoes: repeticoes ?? this.repeticoes,
      treino: treino ?? this.treino,
      observacao: observacao ?? this.observacao,
      fotoPath: fotoPath ?? this.fotoPath,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }
}
