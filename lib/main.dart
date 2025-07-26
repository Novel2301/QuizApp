import 'package:flutter/material.dart';

void main() => runApp(QuizApp());

final List<List<Question>> levels = [
  [ // Уровень 1 - Математика
    Question(questionText: 'Сколько будет 7 + 5?', answers: ['10', '12', '14', '15'], correctAnswer: 1),
    Question(questionText: 'Чему равен корень из 49?', answers: ['5', '6', '7', '8'], correctAnswer: 2),
    Question(questionText: '5 * 6 = ?', answers: ['11', '25', '30', '35'], correctAnswer: 2),
    Question(questionText: '24 / 6 = ?', answers: ['4', '6', '3', '2'], correctAnswer: 0),
    Question(questionText: 'Сколько градусов в прямом угле?', answers: ['45', '90', '180', '360'], correctAnswer: 1),
    Question(questionText: 'Чему равен периметр квадрата со стороной 4?', answers: ['8', '12', '16', '20'], correctAnswer: 2),
    Question(questionText: '7 * 8 = ?', answers: ['54', '56', '58', '64'], correctAnswer: 1),
    Question(questionText: '100 - 37 = ?', answers: ['63', '67', '73', '77'], correctAnswer: 0),
    Question(questionText: 'Сколько нулей в числе тысяча?', answers: ['1', '2', '3', '4'], correctAnswer: 2),
    Question(questionText: '15 + 26 = ?', answers: ['41', '40', '42', '39'], correctAnswer: 0),
  ],
  [], [], [], []
];

class QuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Викторина',
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: StartScreen(),
    );
  }
}

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  List<bool> unlocked = [true, false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.quiz, size: 150, color: Colors.white),
              SizedBox(height: 30),
              Text('🧠 Викторина',
                  style: TextStyle(fontSize: 54, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 20),
              for (int i = 0; i < levels.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.play_arrow),
                    onPressed: unlocked[i]
                        ? () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => QuizScreen(level: i)),
                      );
                      if (result == true && i + 1 < unlocked.length) {
                        setState(() => unlocked[i + 1] = true);
                      }
                    }
                        : null,
                    label: Text('Уровень ${i + 1}'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class Question {
  final String questionText;
  final List<String> answers;
  final int correctAnswer;

  Question({required this.questionText, required this.answers, required this.correctAnswer});
}

class QuizScreen extends StatefulWidget {
  final int level;

  QuizScreen({required this.level});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  int? _selected;
  bool _answered = false;

  void _nextQuestion() {
    if (_selected == levels[widget.level][_currentIndex].correctAnswer) {
      _score++;
    }
    setState(() {
      _answered = false;
      _selected = null;
      if (_currentIndex < levels[widget.level].length - 1) {
        _currentIndex++;
      } else {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: Duration(seconds: 2),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return ScaleTransition(scale: animation, child: child);
            },
            pageBuilder: (context, animation, secondaryAnimation) {
              return CongratulationScreen(currentLevel: widget.level);

            },
          ),
        );
      }
    });
  }

  Color _getButtonColor(int i) {
    if (!_answered) return Colors.white;
    if (i == levels[widget.level][_currentIndex].correctAnswer) return Colors.green;
    if (i == _selected) return Colors.red;
    return Colors.deepPurple.shade100;
  }

  @override
  Widget build(BuildContext context) {
    Question q = levels[widget.level][_currentIndex];
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
                  Text(q.questionText,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white)),
                  SizedBox(height: 20),
                  for (int i = 0; i < q.answers.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getButtonColor(i),
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: _answered
                              ? null
                              : () {
                            setState(() {
                              _selected = i;
                              _answered = true;
                            });
                          },
                          child: Text(q.answers[i], textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _answered ? _nextQuestion : null,
                    child: Text('Далее'),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => Navigator.of(context).pop(),
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.home),
            ),
          ),
        ],
      ),
    );
  }
}

class CongratulationScreen extends StatelessWidget {
  final int currentLevel;

  CongratulationScreen({required this.currentLevel});

  @override
  Widget build(BuildContext context) {
    bool hasNext = currentLevel + 1 < levels.length;

    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 80, color: Colors.deepPurple),
            SizedBox(height: 20),
            Text('Поздравляем!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            Text('Вы успешно прошли уровень!', style: TextStyle(fontSize: 20)),
            SizedBox(height: 30),
            if (hasNext)
              ElevatedButton.icon(
                icon: Icon(Icons.navigate_next),
                label: Text('Следующий уровень'),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => QuizScreen(level: currentLevel + 1)),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ElevatedButton.icon(
              icon: Icon(Icons.home),
              label: Text('На главный экран'),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => StartScreen()),
                      (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: TextStyle(fontSize: 18),
              ),
            )
          ],
        ),
      ),
    );
  }
}

