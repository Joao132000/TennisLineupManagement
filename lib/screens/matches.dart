import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../handlers/signin_signout.dart';
import '../models/player.dart';

class Matches extends StatefulWidget {
  const Matches({Key? key}) : super(key: key);

  @override
  State<Matches> createState() => _MatchesState();
}

class _MatchesState extends State<Matches> {
  String date = '';
  String? minute;
  String? hour;
  String? day;
  String? month;
  final resultController = TextEditingController();
  String? radioButton;
  final currentUser = FirebaseAuth.instance.currentUser!.uid;

  @override
  void dispose() {
    resultController.dispose();
    super.dispose();
  }

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
          color: ((doc['result']) != "No result yet") ? Colors.green : null,
          child: ListTile(
            title: Text(
                '${doc['player1name'].toString()} x ${doc['player2name'].toString()}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 25,
                )),
            subtitle: Text(doc['date'],
                style: const TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 20,
                )),
            trailing: Visibility(
              visible: (((currentUser == doc['player1id']) ||
                          (currentUser == doc['player2id'])) &&
                      (doc['result'] == 'No result yet'))
                  ? true
                  : false,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildIconButtonDate(context, doc),
                  buildIconButtonResult(context, doc),
                  buildIconButtonDelete(context, doc),
                ],
              ),
            ),
          )),
    );
  }

  IconButton buildIconButtonDelete(
      BuildContext context, DocumentSnapshot<Object?> doc) {
    return IconButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text(
                    'Are you sure you want to delete this match?',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  actions: [
                    Row(
                      children: [
                        TextButton(
                          child: const Text(
                            'Confirm',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                          ),
                          onPressed: () {
                            final deleteDoc = FirebaseFirestore.instance
                                .collection('match')
                                .doc(doc['id']);
                            setState(() {
                              deleteDoc.delete();
                            });
                            Navigator.pop(context);
                            updateChallenge(doc);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignInSignOut(),
                              ),
                            );
                          },
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ));
      },
      icon: const Icon(Icons.delete),
    );
  }

  void updateChallenge(DocumentSnapshot<Object?> doc) {
    final updateDocPlayer1 =
        FirebaseFirestore.instance.collection('player').doc(doc['player1id']);
    final updateDocPlayer2 =
        FirebaseFirestore.instance.collection('player').doc(doc['player2id']);
    setState(() {
      updateDocPlayer1.update({
        'challenge': false,
      });
      updateDocPlayer2.update({
        'challenge': false,
      });
    });
  }

  IconButton buildIconButtonResult(
      BuildContext context, DocumentSnapshot<Object?> doc) {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(doc['player1name']),
                      leading: Radio(
                        value: 'player1',
                        groupValue: radioButton,
                        onChanged: (value) {
                          setState(() {
                            radioButton = value.toString();
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(doc['player2name']),
                      leading: Radio(
                        value: 'player2',
                        groupValue: radioButton,
                        onChanged: (value) {
                          setState(() {
                            radioButton = value.toString();
                          });
                        },
                      ),
                    ),
                    TextField(
                      controller: resultController,
                      textInputAction: TextInputAction.next,
                      decoration:
                          const InputDecoration(labelText: 'Match Result'),
                    ),
                  ],
                ),
              );
            }),
            title: const Text('Match Result:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                )),
            actions: [
              Row(
                children: [
                  TextButton(
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                      onPressed: () {
                        if ((resultController.text != "") &&
                            (radioButton != null)) {
                          final updateDocPlayer1 = FirebaseFirestore.instance
                              .collection('player')
                              .doc(doc['player1id']);
                          final updateDocPlayer2 = FirebaseFirestore.instance
                              .collection('player')
                              .doc(doc['player2id']);
                          setState(() {
                            updateDocPlayer1.update({
                              'challenge': false,
                            });
                            updateDocPlayer2.update({
                              'challenge': false,
                            });
                          });
                          final updateDoc = FirebaseFirestore.instance
                              .collection('match')
                              .doc(doc['id']);
                          setState(() {
                            updateDoc.update({
                              'result': resultController.text,
                            });
                          });
                          if (radioButton == 'player1') {
                            setState(() {
                              updateDocPlayer1.update({
                                'position': doc['player2position'],
                              });
                              updateDocPlayer2.update({
                                'position': (doc['player1position']).toInt(),
                              });
                              updateDoc.update({
                                'winner': doc['player1name'],
                              });
                            });
                          } else {
                            setState(() {
                              updateDoc.update({
                                'winner': doc['player2name'],
                              });
                            });
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignInSignOut(),
                            ),
                          );
                        } else {
                          showDialog(
                            context: (context),
                            builder: (context) => AlertDialog(
                              title: Text('Please enter match result'),
                              titlePadding: EdgeInsets.all(10),
                            ),
                          );
                        }
                      }),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ))),
                ],
              ),
            ],
          ),
        );
      },
      icon: const Icon(Icons.scoreboard_outlined),
    );
  }

  IconButton buildIconButtonDate(
      BuildContext context, DocumentSnapshot<Object?> doc) {
    return IconButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Schedule Match:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 25,
                      )),
                  content: SizedBox(
                    height: 200,
                    width: 220,
                    child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.dateAndTime,
                        initialDateTime: DateTime.now(),
                        minimumDate: DateTime(2023),
                        use24hFormat: true,
                        onDateTimeChanged: (val) {
                          setState(() {
                            minute = val.minute.toString();
                            hour = val.hour.toString();
                            day = val.day.toString();
                            month = val.month.toString();
                            date = '$month/$day - $hour:$minute';
                          });
                        }),
                  ),
                  actions: [
                    Row(
                      children: [
                        TextButton(
                            onPressed: () {
                              final updateDoc = FirebaseFirestore.instance
                                  .collection('match')
                                  .doc(doc['id']);
                              setState(() {
                                updateDoc.update({
                                  'date': date,
                                });
                              });

                              Navigator.pop(context);
                            },
                            child: const Text('Confirm',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 25,
                                ))),
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 25,
                                ))),
                      ],
                    ),
                  ],
                ));
      },
      icon: const Icon(Icons.schedule),
    );
  }

  Future<QuerySnapshot<Object?>>? read() async {
    final docPlayer = FirebaseFirestore.instance
        .collection("player")
        .doc(FirebaseAuth.instance.currentUser!.uid);
    final snapshot = await docPlayer.get();
    final p = Player.fromJson(snapshot.data()!);
    return await FirebaseFirestore.instance
        .collection('match')
        .orderBy('timeStamp', descending: true)
        .where('teamId', isEqualTo: p.teamId)
        .get();
  }
}
