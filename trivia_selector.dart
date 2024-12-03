import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'question_page.dart';

class TriviaSelector extends StatefulWidget {
  @override
  _TriviaSelectorState createState() => _TriviaSelectorState();
}

class _TriviaSelectorState extends State<TriviaSelector> {
  List<Map<String, dynamic>> categories = [];
  String? selectedCategory;
  String? selectedDifficulty;
  String? selectedType;

  final List<String> difficulties = ['easy', 'medium', 'hard'];
  final List<String> questionTypes = ['multiple', 'boolean'];

  List<dynamic> questions = []; // Holds the fetched questions
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final url = Uri.parse('https://opentdb.com/api_category.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        categories = List<Map<String, dynamic>>.from(data['trivia_categories']);
      });
    } else {
      print('Failed to fetch categories');
    }
  }

void fetchQuestions() async {
  if (selectedCategory == null || selectedDifficulty == null || selectedType == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please make all selections')),
    );
    return;
  }

  setState(() {
    isLoading = true;
  });

  final url = Uri.parse(
    'https://opentdb.com/api.php?amount=10&category=$selectedCategory&difficulty=$selectedDifficulty&type=$selectedType',
  );
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    setState(() {
      isLoading = false;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionPage(questions: data['results']),
      ),
    );
  } else {
    setState(() {
      isLoading = false;
    });
    print('Failed to fetch questions');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trivia Selector')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Category:', style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedCategory,
              hint: Text('Select a category'),
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category['id'].toString(),
                  child: Text(category['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),
            SizedBox(height: 16),
            Text('Select Difficulty:', style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedDifficulty,
              hint: Text('Select difficulty'),
              items: difficulties.map((difficulty) {
                return DropdownMenuItem<String>(
                  value: difficulty,
                  child: Text(difficulty.capitalize()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDifficulty = value;
                });
              },
            ),
            SizedBox(height: 16),
            Text('Select Question Type:', style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedType,
              hint: Text('Select question type'),
              items: questionTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type == 'multiple' ? 'Multiple Choice' : 'True/False'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedType = value;
                });
              },
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: fetchQuestions,
              child: isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Generate Questions'),
            ),
            SizedBox(height: 24),
            if (questions.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Q${index + 1}: ${question['question']}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            if (selectedType == 'multiple')
                              ...List<Widget>.from(
                                question['incorrect_answers']
                                    .map((answer) => Text('- $answer')),
                              )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
