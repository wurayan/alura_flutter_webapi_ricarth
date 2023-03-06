import 'package:flutter/material.dart';
import 'package:flutter_webapi_first_course/models/journal.dart';
import 'package:flutter_webapi_first_course/screens/add_journal_screen/add_journal_screen.dart';
import 'package:flutter_webapi_first_course/screens/login_screen/login_screen.dart';
import 'package:flutter_webapi_first_course/services/journal_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async  {
  //como eu alaterei o main como assincrona. isso afeta a criação do app e ele cobra essa linha e código para que possa executar sem dar erro
  WidgetsFlutterBinding.ensureInitialized();

  bool isLogged = await verifyToken();

  runApp(MyApp(isLogged: isLogged,));
  //JournalService service = JournalService();
  //service.register(Journal.empty());
  //service.getAll();
  //asyncStudy();
}

Future<bool> verifyToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("accessToken");
  if (token != null){
    return true;
  } return false;
}

class MyApp extends StatelessWidget {
  final bool isLogged;
  const MyApp({Key? key, required this.isLogged}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Journal',
      debugShowCheckedModeBanner: false,
      //alterando o tema padrão do aplicativo e personalizando
      //seria bom ter isso em outro arquivo na refatoração
      theme: ThemeData(
          primarySwatch: Colors.grey,
          appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              titleTextStyle: TextStyle(color: Colors.white),
              iconTheme: IconThemeData(color: Colors.white),
              actionsIconTheme: IconThemeData(color: Colors.white)),
          //usando o plugin google_fonts
          textTheme: GoogleFonts.bitterTextTheme()),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
      initialRoute: (isLogged) ? "home" : "login",
      routes: {
        "home": (context) => const HomeScreen(),
        "login": (context) => LoginScreen()
      },
      //ele 'captura' a rota no journal_card.dart junto com os dados de onde
      //ele foi chamado (no caso o card com informações de data)
      //e envia este contexto para que o addjournalscreen tenha com o que
      //trabalhar
      onGenerateRoute: (routesettings) {
        if (routesettings.name == 'add-journal') {
          //ele intercepta a rota do add-journal dentro do journal_card, pega os dados de contexto da tela e confere se o bool isEditing é true ou false.
          
          final Journal journal = routesettings.arguments as Journal;
          if(journal.content.isEmpty){
            journal.isEditing = true;
            //aparentemente no nosso add_journal_screen/registerJournal usamos true para registrar uma entrada nova e false para editar, sendo que o nome da função é ESTA_SENDO_EDITADO = VERDADE
          } else {
            journal.isEditing = false;
          }
          return MaterialPageRoute(builder: (context) {
            return AddJournalScreen(
              journal: journal,
              isEditing: journal.isEditing,
            );
          });
        }

        return null;
      },
    );
  }
}
