import 'package:flutter/material.dart';
import 'package:flutter_webapi_first_course/models/journal.dart';
import 'package:flutter_webapi_first_course/services/journal_service.dart';

import '../../helpers/weekday.dart';

class AddJournalScreen extends StatelessWidget {
  final Journal journal;
  final bool isEditing;
  AddJournalScreen({super.key, required this.journal, required this.isEditing});

  final TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //se já tiver conteudo no joutnal, ele substitui o contentcontroller
    //pelo conteudo, caso não tenha, a string seguirá vazia para o restante
    //do código até ela ser preenchida
    _contentController.text = journal.content;
    return Scaffold(
      appBar: AppBar(
        title: Text(WeekDay(journal.createdAt).toString()),
        actions: [
          IconButton(
              onPressed: () {
                registerJournal(context);
              },
              icon: const Icon(Icons.check))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: _contentController,
          keyboardType: TextInputType.multiline,
          style: const TextStyle(fontSize: 24),
          expands: true,
          maxLines: null,
          minLines: null,
        ),
      ),
    );
  }

  registerJournal(BuildContext context) {
    String content = _contentController.text;
    //substitui o conteudo vazio que criamos pro journal de exemplo
    //pelo conteudo que recebemos do widget em que estamos
    journal.content = content;
    JournalService service = JournalService();
    //anteriormente essa função era async, porém nã ose recomenda usar
    //build context com async pq não há garantia de que quando a função
    //tiver finalizado o contaxto vai ser o mesmo, por isso alteramos para
    //um .then ao final do service, assim podemos esperar que a função
    //termine de executar antes de usar o navigator
    if (isEditing) {
      service.register(journal).then((value) {
      Navigator.pop(context, value);});
    }else{
      service.edit(journal.id, journal).then((value) {
      Navigator.pop(context, value);});
    }

    //o segundo argumento no navigator.pop restorna uma informação para a
    //que invocou a tela atual (ou seja, tela anterior)
    //aqui no caso é a journal_card dentro da HomeScreen
  }
}
