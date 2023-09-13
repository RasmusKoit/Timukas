import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:timukas/models/word.dart';

Future<Word> fetchWord(String wordToSearch) async {
  final uri = Uri.parse('https://sonapi.koit.dev/v1/$wordToSearch');
  final response = await http.get(
    uri,
    headers: {'Accept': 'application/json'},
  );
  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);
    return Word.fromJson(jsonData);
  } else {
    return Word(word: '');
  }
}

Future<String> translateText(
    String stringToTranslate, String from, String to) async {
  final apiKey = dotenv.env['AZ_API_KEY'];
  if (apiKey == null) {
    return '';
  }
  final String endPoint =
      'https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&from=$from&to=$to';
  final Map<String, String> headers = {
    'Ocp-Apim-Subscription-Key': apiKey,
    'Ocp-Apim-Subscription-Region': 'germanywestcentral',
    'Content-type': 'application/json',
  };
  final requestBody = jsonEncode([
    {'Text': stringToTranslate}
  ]);
  final response = await http.post(
    Uri.parse(endPoint),
    headers: headers,
    body: requestBody,
  );
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    final String translatedText = jsonResponse[0]['translations'][0]['text'];
    return translatedText.toLowerCase();
  } else {
    return '';
  }
}
