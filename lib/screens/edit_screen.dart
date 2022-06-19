import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_own_frashcards/db/database.dart';
import 'package:my_own_frashcards/screens/word_list_screen.dart';

import '../main.dart';

enum EditStatus { ADD, EDIT }

class EditScreen extends StatefulWidget {
  final EditStatus status;
  final Word? word;

  EditScreen({required this.status, this.word});

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();

  String _titleText = "";

  bool _isQuestionEnabled = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.status == EditStatus.ADD) {
      _isQuestionEnabled = true;
      _titleText = "新しい単語の追加";
      questionController.text = "";
      answerController.text = "";
    } else {
      _isQuestionEnabled = false;
      _titleText = "登録した単語の修正";
      questionController.text = widget.word!.strQuestion;
      answerController.text = widget.word!.strAnswer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _backToWordScreen(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titleText),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: "登録",
              onPressed: () => _onWordRegistered(),
              icon: Icon(Icons.done),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 30.0,
              ),
              Center(
                child: Text(
                  "問題とこたえを入力して、「登録ボタンを押して下さい」",
                  style: TextStyle(fontSize: 12.0),
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              //問題入力部分
              _questionInputPart(),
              SizedBox(
                height: 50.0,
              ),
              // こたえ入力部分
              _answerInputPart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _questionInputPart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        children: [
          Text(
            "問題",
            style: TextStyle(fontSize: 24.0),
          ),
          SizedBox(
            height: 10.0,
          ),
          TextField(
            enabled: _isQuestionEnabled,
            controller: questionController,
            keyboardType: TextInputType.text,
            style: TextStyle(fontSize: 30.0),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _answerInputPart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        children: [
          Text(
            "こたえ",
            style: TextStyle(fontSize: 24.0),
          ),
          SizedBox(
            height: 10.0,
          ),
          TextField(
            controller: answerController,
            keyboardType: TextInputType.text,
            style: TextStyle(fontSize: 30.0),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<bool> _backToWordScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WordListScreen(),
      ),
    );
    return Future.value(false);
  }

  _onWordRegistered() {
    if (widget.status == EditStatus.ADD) {
      _insertWord();
    } else {
      _updateWord();
    }
  }

  _insertWord() async {
    if (questionController.text == "" || answerController.text == "") {
      Fluttertoast.showToast(
        msg: "問題と答えの両方を入力しないと登録できません",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text("登録"),
              content: Text("登録してもいいですか？"),
              actions: [
                TextButton(
                  child: Text("はい"),
                  onPressed: () async {
                    var word = Word(
                      strQuestion: questionController.text,
                      strAnswer: answerController.text,
                      isMemorized: false,
                    );
                    try {
                      await database.addWord(word);
                      questionController.clear();
                      answerController.clear();
                      Fluttertoast.showToast(
                        msg: "登録が完了しました",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                      );
                    } on SqliteException catch (e) {
                      Fluttertoast.showToast(
                          msg: "この問題は既に登録されていますので登録できません。",
                          toastLength: Toast.LENGTH_LONG);
                    } finally {
                      Navigator.pop(context);
                    }
                  },
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("いいえ"),
                ),
              ],
            ));
  }

  void _updateWord() async {
    if (questionController.text == "" || answerController.text == "") {
      Fluttertoast.showToast(
        msg: "問題と答えの両方を入力しないと登録できません",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text("${questionController.text}の変更"),
              content: Text("変更してもいいですか？"),
              actions: [
                TextButton(
                  child: Text("はい"),
                  onPressed: () async {
                    var word = Word(
                      strQuestion: questionController.text,
                      strAnswer: answerController.text,
                      isMemorized: false,
                    );

                    try {
                      await database.updateWord(word);
                      Navigator.pop(context);
                      _backToWordScreen();
                      Fluttertoast.showToast(
                        msg: "登録が完了しました",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                      );
                    } on SqliteException catch (e) {
                      Fluttertoast.showToast(
                          msg: "何らかの問題が発生して登録できませんでした: $e",
                          toastLength: Toast.LENGTH_LONG);
                      Navigator.pop(context);
                    }
                  },
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("いいえ"),
                ),
              ],
            ));
  }
}
