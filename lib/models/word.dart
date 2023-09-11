class Word {
  String word;
  List<String>? partOfSpeech;
  Map<String, dynamic>? wordForms;
  List<Meaning>? meanings;

  Word({
    required this.word,
    this.partOfSpeech,
    this.wordForms,
    this.meanings,
  });

  List<String> getPartOfSpeech() {
    List<String> partOfSpeech = [];
    if (this.partOfSpeech != null) {
      for (var element in this.partOfSpeech!) {
        partOfSpeech.add(element);
      }
    }
    return partOfSpeech;
  }

  List<List<String>> getWordForms() {
    List<List<String>> result = [];
    wordForms?.forEach((key, value) {
      List<String> tempList = [];
      tempList.add(key);

      if (value is String) {
        tempList.add(value);
      } else if (value is Map<String, dynamic>) {
        value.forEach((subKey, subValue) {
          tempList.add("$subKey: $subValue");
        });
      }
      result.add(tempList);
    });
    return result;
  }

  List<String> getDefinitions() {
    List<String> definitions = [];
    meanings?.forEach((meaning) {
      definitions.add(meaning.definition);
    });
    return definitions;
  }

  List<String> getExamples() {
    List<String> examples = [];
    meanings?.forEach((meaning) {
      examples.addAll(meaning.examples);
    });
    return examples;
  }

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      word: json['word'],
      partOfSpeech: List<String>.from(json['partOfSpeech']),
      wordForms: json['wordForms'],
      meanings: List<Meaning>.from(
          json['meanings'].map((meaning) => Meaning.fromJson(meaning))),
    );
  }
}

class Meaning {
  String definition;
  String partOfSpeech;
  List<String> synonyms;
  List<String> examples;

  Meaning({
    required this.definition,
    required this.partOfSpeech,
    required this.synonyms,
    required this.examples,
  });

  factory Meaning.fromJson(Map<String, dynamic> json) {
    return Meaning(
      definition: json['definition'],
      partOfSpeech: json['partofSpeech'] ?? '',
      synonyms: List<String>.from(json['synonyms']),
      examples: List<String>.from(json['examples']),
    );
  }
}
