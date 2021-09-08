import 'dart:convert';
import 'package:http/http.dart' as http;

main() async {
  String soap = '''<?xml version="1.0"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                  xmlns:tot="http://www.totvs.com/">
  <soapenv:Header/>
  <soapenv:Body>
    <tot:RealizarConsultaSQL>      
      <tot:codSentenca>ETHOS.TESTE</tot:codSentenca>    
      <tot:codColigada>0</tot:codColigada>       
      <tot:codSistema>F</tot:codSistema>       
      <tot:parameters></tot:parameters>
    </tot:RealizarConsultaSQL>
  </soapenv:Body>
</soapenv:Envelope>''';

  http.Response response = await http.post(
    'http://totvs.brazilsouth.cloudapp.azure.com:8051/wherever',
    headers: {
      'content-type': 'text/xmlc',
      'authorization': 'bWVzdHJlOnRvdHZz',
      'SOAPAction': 'http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL',
    },
    body: utf8.encode(soap),
  );
  print(response.statusCode);
}