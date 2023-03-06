// ignore_for_file: avoid_print

import 'dart:math';

asyncStudy(){
  esperandoFuncoesAssincronas();
}

void execucaoNormal(){
  print("\nExecução Normal");
  print("01");
  print("02");
  print("03");
  print("04");
  print("05");
}

void assincronismoBasico(){
  print("\nAssincronismo Básico");
  print("01");
  print("02");
  //o metodo delayed recebe uma duração e uma função a ser executada
  //quando o tempo acabar. Ele não interrompe o código quando atinge o 
  //print03, seguindo o código e printando o 03 após 2 segundos passados
  Future.delayed(const Duration(seconds: 2), () {
    print("03");
  });
  print("04");
  print("05");
}

void usandoFuncoesAssincronas(){
  print("\nUsando funções assíncronas");
  print("A");
  print("B");
  //print(getRandomInt(3)); // Instance of Future<int>
  getRandomInt(3).then((value) {
    print("O número aleatório é $value.");
    // E se eu quiser que as coisas só aconteçam depois?
  });
  print("C");
  print("D");
}

void esperandoFuncoesAssincronas() async {
  print("A");
  print("B");
  int number = await getRandomInt(4);
  print("O outro número aleatório é $number.");
  print("C");
  print("D");
}

Future<int> getRandomInt(int time) async {
  //o uso do await faz com que o código se interrompa até que
  //a operação aconteça, diferente do delayed utilizado no print02
  await Future.delayed(Duration(seconds:time));

  Random rng = Random();

  return rng.nextInt(10);
}