import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PracticeMatchPlayer extends StatefulWidget {
  const PracticeMatchPlayer({Key? key, required this.teamId}) : super(key: key);
  final String teamId;

  @override
  State<PracticeMatchPlayer> createState() => _PracticeMatchPlayerState();
}

class _PracticeMatchPlayerState extends State<PracticeMatchPlayer> {
  String dropDownType = "Singles";
  var itemsType = [
    "Singles",
    "Doubles",
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Team Matches'),
        ),
        body: GestureDetector(
          onPanUpdate: (details) async {
            if (details.delta.dx > 0) {
              Navigator.pop(context);
            }
          },
          child: RefreshIndicator(
            onRefresh: () {
              return Future(() {
                setState(() {});
              });
            },
            child: FutureBuilder<QuerySnapshot>(
                future: read(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final List<DocumentSnapshot> documents =
                        snapshot.data!.docs;
                    return Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          'Practice Matches',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 30,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                            ),
                            DropdownButton(
                              alignment: AlignmentDirectional.bottomStart,
                              value: dropDownType,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: itemsType.map((String items) {
                                return DropdownMenuItem(
                                  value: items,
                                  child: Text(items),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  dropDownType = newValue!;
                                });
                              },
                            ),
                          ],
                        ),
                        Expanded(
                          child: ListView(
                              children: documents
                                  .map((doc) =>
                                      buildGestureDetector(context, doc))
                                  .toList()),
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  '<-- Swipe to see challenge matches',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                          ],
                        )
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
          ),
        ),
      );

  GestureDetector buildGestureDetector(
      BuildContext context, DocumentSnapshot<Object?> doc) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              'Match Result:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 25,
              ),
            ),
            content: Text(
              'Winner: ${doc['winner']} \n \nResult: ${doc['result']}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 25,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: Card(
        child: ListTile(
          title: (doc['checkSinglesDoubles'] == 'Singles')
              ? Text(
                  '${doc['player1name'].toString()} x ${doc['player2name'].toString()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 30,
                  ),
                )
              : Text(
                  '${doc['player1name'].toString()} x\n${doc['player2name'].toString()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 30,
                  ),
                ),
          subtitle: Text(
            doc['date'],
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }

  Future<QuerySnapshot<Object?>>? read() async {
    return await FirebaseFirestore.instance
        .collection('practice')
        .orderBy('timeStamp', descending: true)
        .where('teamId', isEqualTo: widget.teamId)
        .where('checkSinglesDoubles', isEqualTo: dropDownType)
        .get();
  }
}
