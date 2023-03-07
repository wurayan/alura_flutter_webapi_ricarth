import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'http_interceptors.dart';

class AuthService {
  //TODO: Modularizar o endpoint
  static const String url = "http://192.168.2.190:3000/";
  static const String resource = "journals/";

  http.Client client =
      InterceptedClient.build(interceptors: [LoggingInterceptor()]);

  Future<bool> login({required String email, required String password}) async {
    //faz a requizição do método post na URL 
    http.Response response = await client.post(
      Uri.parse('${url}login'),
      body: {
        'email': email,
        'password': password
      }
      );
      //Esse if confere qualquer resposta que não for 200, ou seja, que não for sucesso e retorna o erro, se o código passar por aqui e não retornar erro, então deu tudo certo
      if (response.statusCode != 200){
        String content = json.decode(response.body);
        switch (content){
          case "Cannot find user":
          throw UserNotFindException();
        }
        throw HttpException(response.body);
      } 
      print("antes de saveuserinfo \n ${response.body}");
      saveUserInfos(response.body);
      return true;

  }

  Future<bool> register({required String email, required String password}) async {
    http.Response response = await client.post(
      Uri.parse('${url}register'),
      body: {
        'email': email,
        'password': password
      }
      );
      if (response.statusCode != 201){
        throw HttpException(response.body);
      }
      print('era para parecer negocio pow');
      saveUserInfos(response.body);
      return true;
  }

  saveUserInfos(String body) async {
    print("saveuserinfo recebe \n $body");
    Map<String, dynamic> map = json.decode(body);
    //essas respostas são salvas de acordo com a formatação do json que pode ser acessada pelo Postman
    //token salva a informação dentro do json que responde á chave accesToken
    String token = map["accessToken"];
    //email salva a infromação de chave 'email' dentro do subjson 'user'
    String email = map["user"]["email"];
    String id = map["user"]["id"].toString();
    print(id);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("accessToken", token);

    prefs.setString("email", email);

    prefs.setString("id", id);
    
    print(prefs.getString("id"));
  }
}

class UserNotFindException implements Exception {
  

}