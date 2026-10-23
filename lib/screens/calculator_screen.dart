import 'package:flutter/material.dart';
import '../services/voice_service.dart';
import '../utils/calculator_engine.dart';
import 'history_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  bool _isListening = false;
  String _textSpoken = 'Инициализация...';
  String _result = '0';

  final List<String> _accumulatedHistory = [];
  final VoiceService _voiceService = VoiceService();

  @override
  void initState() {
    super.initState();
    _voiceService.initModel((status) {
      setState(() {
        _textSpoken = status;
      });
    });
  }

  void _toggleListening() async {
    if (!_voiceService.isInitialized) return;

    if (!_isListening) {
      setState(() {
        _isListening = true;
        _textSpoken = 'Слушаю... Говорите пример';
        _result = '0';
      });

      await _voiceService.startListening(
        onPartial: (text) {
          setState(() {
            _textSpoken = text;
          });
        },
        onSilenceTimeout: () {
          if (_isListening) {
            _stopAndCalculate();
          }
        },
      );
    } else {
      _stopAndCalculate();
    }
  }

  void _stopAndCalculate() async {
    final text = await _voiceService.stopListening();
    setState(() {
      _isListening = false;
      if (text.isNotEmpty) {
        _textSpoken = text;
      }
    });

    final calcResult = CalculatorEngine.calculate(_textSpoken);
    setState(() {
      _textSpoken = calcResult.displayExpression;
      _result = calcResult.result;

      if (calcResult.success) {
        _accumulatedHistory.insert(0, '$_textSpoken = $_result');
      }
    });
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Голосовой калькулятор'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryScreen(
                    history: _accumulatedHistory,
                    onClearHistory: () {
                      setState(() {
                        _accumulatedHistory.clear();
                      });
                    },
                    onDeleteItem: (index) {
                      setState(() {
                        _accumulatedHistory.removeAt(index);
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 80,
                          child: Center(
                            child: Text(
                              'Распознано:\n$_textSpoken',
                              style: const TextStyle(fontSize: 18, color: Colors.black54),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'Результат:',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 5),

                        SizedBox(
                          height: 60,
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _result,
                                style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 50),

                        SizedBox(
                          width: 80,
                          height: 80,
                          child: FloatingActionButton(
                            onPressed: _voiceService.isInitialized ? _toggleListening : null,
                            backgroundColor: _isListening ? Colors.red : Colors.blue,
                            child: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              size: 36,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}