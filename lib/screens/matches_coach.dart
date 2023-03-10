import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MatchesCoach extends StatefulWidget {
  const MatchesCoach({Key? key, required this.teamId}) : super(key: key);
  final String teamId;

  @override
  State<MatchesCoach> createState() => _MatchesCoachState();
}

class _MatchesCoachState extends State<MatchesCoach> {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Team Matches'),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return Future(() {
            setState(() {});
          });
        },
        child: FutureBuilder<QuerySnapshot>(
            future: read(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final List<DocumentSnapshot> documents = snapshot.data!.docs;
                return Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    const Text('Matches',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 30,
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                        child: ListView(
                            children: documents
                                .map(
                                    (doc) => buildGestureDetector(context, doc))
                                .toList())),
                  ],
                );
              } else if (snapshot.hasError) {
                return const Text('Something went wrong!');
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ));

  GestureDetector buildGestureDetector(
      BuildContext context, DocumentSnapshot<Object?> doc) {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Match Result:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 25,
                      )),
                  content: Text(
                      'Winner: ${doc['winner']} \nResult: ${doc['result']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      )),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 25,
                            ))),
                  ],
                ));
      },
      child: Card(
          child: ListTile(
        title: Text(
            '${doc['player1name'].toString()} x ${doc['player2name'].toString()}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 30,
            )),
        subtitle: Text(doc['date'],
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 20,
            )),
      )),
    );
  }

  Future<QuerySnapshot<Object?>>? read() async {
    return await FirebaseFirestore.instance
        .collection('match')
        .orderBy('timeStamp', descending: true)
        .where('teamId', isEqualTo: widget.teamId)
        .get();
  }
}
