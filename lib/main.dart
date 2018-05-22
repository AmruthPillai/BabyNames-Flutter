import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Baby Names',
      home: const MyHomePage(title: 'Baby Name Votes'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text(title)),
      body: new StreamBuilder(
          stream: Firestore.instance.collection('baby-names').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return new Text('Loading...');
            return new ListView.builder(
                itemCount: snapshot.data.documents.length,
                padding: const EdgeInsets.only(top: 10.0),
                itemExtent: 55.0,
                itemBuilder: (context, index) =>
                  _buildListItem(context, snapshot.data.documents[index]),
            );
          }),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return new ListTile(
      key: new ValueKey(document.documentID),
      title: new Container(
        padding: const EdgeInsets.all(10.0),
        child: new Row(
          children: <Widget>[
            new Expanded(
              child: new Text(document['name']),
            ),
            new Text(
              document['votes'].toString(),
            ),
          ],
        ),
      ),
      onTap: () => Firestore.instance.runTransaction((transaction) async {
        DocumentSnapshot freshSnap =
        await transaction.get(document.reference);
        await transaction.update(
            freshSnap.reference, {'votes': freshSnap['votes'] + 1});
      }),
    );
  }
}