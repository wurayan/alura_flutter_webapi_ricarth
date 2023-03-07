import 'dart:convert';

import 'package:flutter_webapi_first_course/models/journal.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';

import 'http_interceptors.dart';

class JournalService {
  static const String url = "http://192.168.2.190:3000/";
  static const String resource = "journals/";

  http.Client client =
      InterceptedClient.build(interceptors: [LoggingInterceptor()]);

  String getUrl() {
    return "$url$resource";
  }

  Uri getUri() {
    return Uri.parse(getUrl());
  }

  Future<bool> register(Journal journal, String token) async {
    //converte a classe/model journal em um map/dicionario e então
    //converte o dicionário para um json que será reconhecido pelo BD
    String jsonJournal = json.encode(journal.toMap());
    //o metodo http.post recebe um Uri, não um Url, portanto usamos o Uri.parse
    http.Response response = await client.post(getUri(),
        //envia o nosso dicionário jsonJournal para o corpo do nosso journals
        //dentro do banco de dados
        headers: {
          'content-type': 'application/json',
          "Authorization": "Bearer $token"
        },
        body: jsonJournal);
    //retonro 201 é o retorno de criação com sucesso
    if (response.statusCode == 201) {
      return true;
    }
    return false;
  }

  Future<bool> edit(String id, Journal journal, String token) async {
    String jsonJournal = json.encode(journal.toMap());

    http.Response response = await client.put(Uri.parse('${getUrl()}$id'),
        headers: {
          'content-type': 'application/json',
          "Authorization": "Bearer $token"
        },
        body: jsonJournal);

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<List<Journal>> getAll(
      {required String id, required String token}) async {
    http.Response response = await client.get(
        Uri.parse("${url}users/$id/journals"),
        headers: {"Authorization": "Bearer $token"});

    if (response.statusCode != 200) {
      throw Exception();
    }

    List<Journal> result = [];
    //Pega o corpo(body) da resposta (response) do BD que está em forma
    //de json e decode ela para uma lista dinamica
    List<dynamic> listDynamic = json.decode(response.body);
    //o for itera a lista gerada em listDynamic e para cada item, adiciona
    //o mesmo ao final da nossa lista vazia, convertendo o resultado
    //dinamico em um Journal
    for (var jsonMap in listDynamic) {
      result.add(Journal.fromMap(jsonMap));
    }
    return result;
  }

  Future<bool> delete(String id, String token) async {
    http.Response response = await http.delete(Uri.parse('${getUrl()}$id'),
    headers: {"Authorization": "Bearer $token"});
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }
}
