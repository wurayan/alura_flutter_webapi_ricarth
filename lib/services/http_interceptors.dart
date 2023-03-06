import 'package:http_interceptor/http_interceptor.dart';
import 'package:logger/logger.dart';

//ainda não entendi o que são os interceptors e porque estamos implementando


class LoggingInterceptor implements InterceptorContract {
  Logger logger = Logger();

  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    logger.v("Requisição para ${data.baseUrl}\nCbeçalhos: ${data.headers}\nCorpo: ${data.body}");
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    if(data.statusCode ~/ 100 == 2){
       logger.i("resposta de ${data.url}\nStatus da Resposta:${data.statusCode}\nCbeçalhos: ${data.headers}\nCorpo: ${data.body}");
    }else{
       logger.e("Requisição para ${data.url}\nStatus da Resposta:${data.statusCode}\nCbeçalhos: ${data.headers}\nCorpo: ${data.body}");
    }
     
      return data;
  }

}