import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Summary extends StatefulWidget {
  @override
  _SummaryState createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {

  Widget _buildListItem(BuildContext context, DocumentSnapshot document){
    return ListTile(
      title: Row(
          children: [
            Expanded(
              child: Text(
                document['name'],
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                  color: Colors.white
              ),
              padding: const EdgeInsets.all(10),
              child: Text(
                document['cat'].toString(),
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                  color: Colors.white
              ),
              padding: const EdgeInsets.all(10),
              child: Text(
                document['commission'].toString(),
                style: Theme.of(context).textTheme.headline6,
              ),
            )
          ]
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Flexible(
              flex: 9,
              child: Container(
                color: Colors.white,
                child: StreamBuilder(
                  stream: Firestore.instance.collection('users').snapshots(),
                  builder: (context, snapshot){
                    if(!snapshot.hasData) return const Text('Loading....');
                    return ListView.builder(
                      itemExtent: 80,
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) =>
                          _buildListItem(context, snapshot.data.documents[index]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
