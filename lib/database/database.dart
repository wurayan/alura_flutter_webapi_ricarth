import 'dart:math';

import 'package:flutter_webapi_first_course/helpers/phrases.dart';
import 'package:uuid/uuid.dart';

import '../models/journal.dart';


//Esse arquivo é irrelevante, ele era o placeholder que gerava eventos aleatórios para teste e portanto não é mais útil
Map<String, Journal> generateRandomDatabase({
  required int maxGap, // Tamanho máximo da janela de tempo
  required int amount, // Entradas geradas
}) {
  Random rng = Random();

  Map<String, Journal> map = {};

  for (int i = 0; i < amount; i++) {
    int timeGap = rng.nextInt(maxGap - 1); // Define uma distância do hoje
    DateTime date = DateTime.now().subtract(
      Duration(days: timeGap),
    ); // Gera um dia

    String id = const Uuid().v1();

    map[id] = Journal(
      id: id,
      content: getRandomPhrase(),
      createdAt: date,
      updatedAt: date,
      userId: 2
    );
  }
  return map;
}
