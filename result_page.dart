import 'package:flutter/material.dart';
import 'question_page.dart';

class ResultPage extends StatelessWidget {
  final int score;
  final int total;
  final List<dynamic> questions;
  final List<Map<String, dynamic>> answers; // Stores user answers and correct answers

  const ResultPage({
    required this.score,
    required this.total,
    required this.questions,
    required this.answers,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz Results')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your Score',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '$score / $total',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: answers.length,
                itemBuilder: (context, index) {
                  final question = answers[index]['question'];
                  final userAnswer = answers[index]['userAnswer'];
                  final correctAnswer = answers[index]['correctAnswer'];
                  final isCorrect = userAnswer == correctAnswer;

                  return Card(
                    color: isCorrect ? Colors.green[100] : Colors.red[100],
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Q${index + 1}: $question',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Your Answer: $userAnswer',
                            style: TextStyle(
                              fontSize: 14,
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                          ),
                          Text(
                            'Correct Answer: $correctAnswer',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionPage(questions: questions),
                  ),
                ); // Restart the quiz with the same questions
              },
              child: Text('Redo Quiz'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst); // Go to homepage
              },
              child: Text('Go to Homepage'),
            ),
          ],
        ),
      ),
    );
  }
}