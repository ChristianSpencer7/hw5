import 'dart:async';
import 'package:flutter/material.dart';
import 'result_page.dart';

class QuestionPage extends StatefulWidget {
  final List<dynamic> questions;

  const QuestionPage({required this.questions, Key? key}) : super(key: key);

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  int currentQuestionIndex = 0;
  int timeLeft = 30;
  Timer? timer;
  bool showFeedback = false;
  String? feedbackMessage;
  int score = 0; // Tracks the user's score
  List<String> shuffledOptions = []; // Store shuffled options for the current question
  List<Map<String, dynamic>> answers = []; // Stores user answers and correct answers

  @override
  void initState() {
    super.initState();
    loadQuestion();
    startTimer();
  }

  void startTimer() {
    timeLeft = 30;
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          recordAnswer(null); // No answer selected before timeout
          showFeedbackScreen('Time’s up! You ran out of time.');
        }
      });
    });
  }

  void loadQuestion() {
    final question = widget.questions[currentQuestionIndex];
    shuffledOptions = [...question['incorrect_answers'], question['correct_answer']];
    shuffledOptions.shuffle(); // Shuffle options once per question
  }

  void recordAnswer(String? selectedAnswer) {
    final question = widget.questions[currentQuestionIndex];
    final correctAnswer = question['correct_answer'];
    answers.add({
      'question': question['question'],
      'userAnswer': selectedAnswer ?? 'No Answer',
      'correctAnswer': correctAnswer,
    });
    if (selectedAnswer == correctAnswer) {
      score++; // Increment score for correct answers
    }
  }

  void showFeedbackScreen(String message, {bool isCorrect = false}) {
    setState(() {
      showFeedback = true;
      feedbackMessage = message;
    });
    timer?.cancel();
    Future.delayed(Duration(seconds: 2), nextQuestion);
  }

  void checkAnswer(String selectedAnswer) {
    recordAnswer(selectedAnswer); // Record the user's answer
    final correctAnswer = widget.questions[currentQuestionIndex]['correct_answer'];
    if (selectedAnswer == correctAnswer) {
      showFeedbackScreen('Correct!', isCorrect: true);
    } else {
      showFeedbackScreen('Incorrect!');
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        showFeedback = false;
        loadQuestion(); // Load the next question and shuffle options
      });
      startTimer();
    } else {
      endQuiz(); // End the quiz and show results
    }
  }

  void endQuiz() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          score: score,
          total: widget.questions.length,
          questions: widget.questions,
          answers: answers,
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[currentQuestionIndex];
    final progress = (currentQuestionIndex + 1) / widget.questions.length;

    return Scaffold(
      appBar: AppBar(title: Text('Question ${currentQuestionIndex + 1}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: showFeedback
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      feedbackMessage!,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: feedbackMessage == 'Correct!'
                            ? Colors.green
                            : Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress bar
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    color: Colors.blue,
                  ),
                  SizedBox(height: 16),
                  Text(
                    question['question'],
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 16),
                  if (question['type'] == 'multiple')
                    ...shuffledOptions.map((option) => ElevatedButton(
                          onPressed: () => checkAnswer(option),
                          child: Text(option),
                        )),
                  if (question['type'] == 'boolean') ...[
                    ElevatedButton(
                      onPressed: () => checkAnswer('True'),
                      child: Text('True'),
                    ),
                    ElevatedButton(
                      onPressed: () => checkAnswer('False'),
                      child: Text('False'),
                    ),
                  ],
                  Spacer(),
                  Text(
                    'Time left: $timeLeft seconds',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }
}
