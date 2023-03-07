import 'package:flutter/material.dart';
import 'package:flutter_webapi_first_course/helpers/weekday.dart';
import 'package:flutter_webapi_first_course/models/journal.dart';
import 'package:flutter_webapi_first_course/screens/commom/confirmation_dialog.dart';
import 'package:flutter_webapi_first_course/services/journal_service.dart';
import 'package:uuid/uuid.dart';

class JournalCard extends StatelessWidget {
  final Journal? journal;
  final DateTime showedDate;
  final Function refreshFunction;
  final int userId;
  final String token;

  const JournalCard(
      {Key? key,
      this.journal,
      required this.showedDate,
      required this.refreshFunction,
      required this.userId,
      required this.token})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //verifica se a entrada é nula, ou seja, se não tem nenhum dado
    if (journal != null) {
      return InkWell(
        onTap: () {
          // chamou a função addjournalscreen inserindo o parametro
          //opcional, que é o jornal, pq anteriormente verificamos que ele
          //não era nulo
          callAddJournalScreen(context, journal: journal);
        },
        child: Container(
          height: 115,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black87,
            ),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    height: 75,
                    width: 75,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      border: Border(
                          right: BorderSide(color: Colors.black87),
                          bottom: BorderSide(color: Colors.black87)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      journal!.createdAt.day.toString(),
                      style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    height: 38,
                    width: 75,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.black87),
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Text(WeekDay(journal!.createdAt).short),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    journal!.content,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    removeJournal(context);
                  },
                  icon: const Icon(Icons.delete))
            ],
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          //de fato era nulo, por isso chama o calladdjournal não adiciona o
          //parametro journal
          callAddJournalScreen(context);
        },
        child: Container(
          height: 115,
          alignment: Alignment.center,
          child: Text(
            "${WeekDay(showedDate).short} - ${showedDate.day}",
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  callAddJournalScreen(BuildContext context, {Journal? journal}) {
    //cria um journal template para ser utilizado caso o journal seja nulo
    Journal innerJournal = Journal(
        id: const Uuid().v1(),
        content: '',
        createdAt: showedDate,
        updatedAt: showedDate,
        userId: userId
        );

    Map<String, dynamic> map = {};
    //confere se o journal é diferente de null, se sim ele substitui o nosso template pelo journal que a função recebe e diz que o is_editing é false
    if (journal != null) {
      innerJournal = journal;
      map['is_editing'] = false;
    } else {
      map['is_editing'] = true;
    }
    //se o journal for nulo (se não recebemos um journal como parametro), ou seja, uma entrada nova, nós preenchemos ela com esse template
    map['journal'] = innerJournal;
    //ele cria o journal template e envia essa infromação para tela de criação de journal
    Navigator.pushNamed(context, 'add-journal', arguments: innerJournal).then(
        (value) {
      refreshFunction();
      if (value != null && value == true) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro salvo com sucesso!')));
      }
    }
        //.then essa função chama a journal_screen que tem um resultado como
        //argumento em seu navigator.pop, ou seja, quando retornamos para
        //a tela atual através da add_journal_screen, recebemos um registro.
        //a função .then ao final do navigator atual espera que um argumento
        //seja retornado junto com o navigator e então executa o showsnackbar
        );
  }

  removeJournal(BuildContext context) {
    JournalService service = JournalService();

    if (journal != null) {
      showConfirmationDialog(context,
              content:
                  'Deseja realomente remover a entrada do dia ${WeekDay(journal!.createdAt)}?',
              affirmativeOption: 'remover')
          .then((value) {
        if (value != null) {
          if (value) {
            service.delete(journal!.id, token).then((value) {
              // não seria necessário fazer essa verificação, ja que para o usuário apertar o botao de delete ele obrigatoriamente precisa ser um objeto não nulo, porém por boas práticas e evitar exceptions no código realizamos essa verificação extra
              if (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Removido com sucesso!")));
                refreshFunction();
              }
            });
          }
        }
      });
    }
  }
}
