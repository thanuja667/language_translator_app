import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

void main() => runApp(LanguageTranslatorApp());

class LanguageTranslatorApp extends StatelessWidget {
  const LanguageTranslatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Language Translator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.lightBlue[50], // Light blue background
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final translator = GoogleTranslator(); // Initialize Google Translator
  final TextEditingController textController = TextEditingController();

  String selectedSourceLang = 'en'; // Default source language: English
  String selectedTargetLang = 'ta'; // Default target language: Tamil
  String translation = ''; // To display the translated text

  // List to store translation history
  List<Map<String, String>> translationHistory = [];

  // Translation Function
  Future<void> translateText() async {
    String inputText = textController.text;
    if (inputText.isNotEmpty) {
      try {
        var result = await translator.translate(
          inputText,
          from: selectedSourceLang,
          to: selectedTargetLang,
        );
        setState(() {
          translation = result.text; // Translated text
          // Add the translation to the history list
          translationHistory.add({
            'text': inputText,
            'translation': result.text,
            'from': selectedSourceLang,
            'to': selectedTargetLang,
          });
        });
      } catch (e) {
        setState(() {
          translation = 'Error: Unable to translate.';
        });
      }
    } else {
      setState(() {
        translation = 'Please enter some text.';
      });
    }
  }

  // Navigate to Language Selector Screen
  void selectLanguage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LanguageSelectorScreen(
          sourceLang: selectedSourceLang,
          targetLang: selectedTargetLang,
          onLanguageSelected: (source, target) {
            setState(() {
              selectedSourceLang = source;
              selectedTargetLang = target;
            });
          },
        ),
      ),
    );
  }

  // Navigate to History Screen
  void goToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryPage(
          history: translationHistory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Translator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: goToHistory, // Open history screen
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Enter text to translate',
                border: OutlineInputBorder(),
                fillColor: Colors.white70, // Light pastel color for text field
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: selectLanguage,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[200]),
                  child: Text('Select Languages'),
                ),
                ElevatedButton(
                  onPressed: translateText,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[200]),
                  child: Text('Translate'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (translation.isNotEmpty)
              Text(
                'Translation: $translation',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
      backgroundColor: Colors.lightGreen[50], // Light green pastel background
    );
  }
}

class LanguageSelectorScreen extends StatefulWidget {
  final String sourceLang;
  final String targetLang;
  final Function(String, String) onLanguageSelected;

  const LanguageSelectorScreen({
    super.key,
    required this.sourceLang,
    required this.targetLang,
    required this.onLanguageSelected,
  });

  @override
  _LanguageSelectorScreenState createState() => _LanguageSelectorScreenState();
}

class _LanguageSelectorScreenState extends State<LanguageSelectorScreen> {
  String selectedSourceLang = 'en'; // Default source language
  String selectedTargetLang = 'ta'; // Default target language

  final Map<String, String> languages = {
    'en': 'English',
    'hi': 'Hindi',
    'te': 'Telugu',
    'ta': 'Tamil',
    'ml': 'Malayalam',
    'ko': 'Korean',
  };

  @override
  void initState() {
    super.initState();
    selectedSourceLang = widget.sourceLang;
    selectedTargetLang = widget.targetLang;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Languages')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedSourceLang,
              items: languages.entries
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => selectedSourceLang = value);
              },
              decoration: const InputDecoration(labelText: 'Source Language'),
            ),
            DropdownButtonFormField<String>(
              value: selectedTargetLang,
              items: languages.entries
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => selectedTargetLang = value);
              },
              decoration: const InputDecoration(labelText: 'Target Language'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                widget.onLanguageSelected(
                    selectedSourceLang, selectedTargetLang);
                Navigator.pop(context);
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.purple[100]),
              child: Text('Confirm'),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.yellow[50], // Light yellow pastel background
    );
  }
}

class HistoryPage extends StatelessWidget {
  final List<Map<String, String>> history;

  const HistoryPage({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Translation History')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: history.isEmpty
            ? const Center(child: Text('No history available.'))
            : ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final translation = history[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.purple[50], // Light purple pastel card
                    child: ListTile(
                      title: Text(
                          'From: ${translation['from']} to: ${translation['to']}'),
                      subtitle: Text(
                          '${translation['text']} => ${translation['translation']}'),
                    ),
                  );
                },
              ),
      ),
      backgroundColor: Colors.lightBlue[50], // Light blue pastel background
    );
  }
}
