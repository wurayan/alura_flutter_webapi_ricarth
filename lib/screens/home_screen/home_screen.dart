import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_webapi_first_course/screens/commom/exception_dialog.dart';
import 'package:flutter_webapi_first_course/screens/home_screen/widgets/home_screen_list.dart';
import 'package:flutter_webapi_first_course/services/journal_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/logout.dart';
import '../../models/journal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // O último dia apresentado na lista
  DateTime currentDay = DateTime.now();

  // Tamanho da lista
  int windowPage = 10;

  // A base de dados mostrada na lista
  Map<String, Journal> database = {};

  final ScrollController _listScrollController = ScrollController();

  final JournalService service = JournalService();

  int? userId;

  String? usertoken;

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Título basado no dia atual
        title: Text(
          "${currentDay.day}  |  ${currentDay.month}  |  ${currentDay.year}",
        ),
        actions: [
          IconButton(
              onPressed: () {
                refresh();
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: (userId != null && usertoken != null)
          ? ListView(
              controller: _listScrollController,
              children: generateListJournalCards(
                  windowPage: windowPage,
                  currentDay: currentDay,
                  database: database,
                  refreshFunction: refresh,
                  userId: userId!,
                  token: usertoken!
                  //sem parenteses pq não queremos enviar a chamada da função
                  //só a função
                  ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              onTap: () {
                logout(context);
              },
              title: const Text("Desconectar"),
              leading: const Icon(Icons.logout),
            )
          ],
        ),
      ),
    );
  }

  //foi necessário invocar essa função em outro widget que não possuia
  //acesso, então teve que ser invocada no parent que tambem não tinha
  //acesso até dar a volta e retornar nesta mesma tela. Não poderiamos criar
  //um arquivo para receber essa função refresh e os outros arquivos terem
  //acesso mais prático a mesma?
  void refresh() {
    SharedPreferences.getInstance().then((prefs) {
      String? token = prefs.getString("accessToken");
      String? email = prefs.getString("email");
      String? id = prefs.getString("id");
      // print("$id ---- $email ------ $token");
      if (token != null && email != null && id != null) {
        //a tela foi iniciada com um 'int? id' porque quando a tela é construída nós não temos ainda o valor do id, porém quando a função refresh é chamada no initstate, nós aproveitamos que já é feita a verificação se 'id != null' e puxamos um setState que vai atualizar a página com o id.
        setState(() {
          userId = int.parse(id);
          usertoken = token;
        });
        service
            .getAll(
          id: id.toString(),
          token: token,
        )
            .then((List<Journal> listjournal) {
          setState(() {
            database = {};
            for (Journal journal in listjournal) {
              database[journal.id] = journal;
            }

            //faz a tela pular automaticament pro dia atual
            if (_listScrollController.hasClients) {
              final double position =
                  _listScrollController.position.maxScrollExtent;
              _listScrollController.jumpTo(position);
            }
          });
        }).catchError(
          (error) {
            logout(context);
          },
          test: (error) => error is TokenNotValidException,
        ).catchError((error){
          //nesse método nós primeiro ocnvertemos o error para uma httpexception, permitindo assim que a ide reconheça e apresente a opção '.message', invés de digitarmos o código confiando que vai dar certo
          var innerError = error as HttpException;
          showExceptionDialog(context, content: innerError.message);
        },test: (error) => error is HttpException,);
      } else {
        Navigator.pushReplacementNamed(context, "login");
      }
    });
  }
}
