import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_own_frashcards/db/database.dart';
import 'package:my_own_frashcards/screens/edit_screen.dart';

import '../main.dart';

class WordListScreen extends StatefulWidget {
  const WordListScreen({Key? key}) : super(key: key);

  @override
  _WordListScreenState createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  List<Word> _wordList = [];

  @override
  void initState() {
    super.initState();
    _getAllWords();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("単語一覧"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _sortWords(),
            icon: Icon(Icons.sort),
            tooltip: "暗記済みの単語を下になるようにソート",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewWord(),
        child: Icon(Icons.add),
        tooltip: "新しい単語の登録",
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _wordListWidget(),
      ),
    );
  }

  _addNewWord() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EditScreen(
          status: EditStatus.ADD,
        ),
      ),
    );
  }

  void _getAllWords() async {
    _wordList = await database.allWords;
    setState(() {});
  }

  Widget _wordListWidget() {
    return ListView.builder(
      itemCount: _wordList.length,
      itemBuilder: (context, int position) => _wordItem(position),
    );
  }

  Widget _wordItem(int position) {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      color: Colors.grey.shade700,
      child: ListTile(
        title: Text("${_wordList[position].strQuestion}"),
        subtitle: Text(
          "${_wordList[position].strAnswer}",
          style: TextStyle(fontFamily: "Mont"),
        ),
        trailing: (_wordList[position].isMemorized != null &&
                _wordList[position].isMemorized)
            ? Icon(Icons.check_circle)
            : null,
        onTap: () => _editWord(_wordList[position]),
        onLongPress: () => _deleteWord(_wordList[position]),
      ),
    );
  }

  _deleteWord(Word selectedWord) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
              title: Text(selectedWord.strQuestion),
              content: Text("削除してもいいですか？"),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white
                  ),
                  onPressed: () async {
                    await database.deletedWord(selectedWord);
                    Fluttertoast.showToast(
                      msg: "削除が完了しました",
                      toastLength: Toast.LENGTH_LONG,
                    );
                    _getAllWords();
                    Navigator.pop(context);
                  },
                  child: Text("はい"),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "いいえ",
                  ),
                ),
              ],
            ));
  }

  _editWord(Word selectedWord) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EditScreen(
          status: EditStatus.EDIT,
          word: selectedWord,
        ),
      ),
    );
  }

  _sortWords() async {
    _wordList = await database.allWordsSorted;
    setState(() {});
  }
}
