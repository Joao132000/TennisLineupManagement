import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_up/screens/team_doubles.dart';

import '../handlers/signin_signout.dart';
import 'matches_coach.dart';

class PlayersByTeam extends StatefulWidget {
  final String teamId;
  final String teamSchool;
  final String teamType;
  final String teamLeague;

  const PlayersByTeam(
      {Key? key,
      required this.teamId,
      required this.teamSchool,
      required this.teamType,
      required this.teamLeague})
      : super(key: key);

  @override
  State<PlayersByTeam> createState() => _PlayersByTeamState();
}

class _PlayersByTeamState extends State<PlayersByTeam> {
  final positionController = TextEditingController();
  final newTeamCodeController = TextEditingController();

  @override
  void dispose() {
    positionController.dispose();
    newTeamCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Team Lineup'),
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
                    Text(widget.teamSchool,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 25,
                        )),
                    Text(widget.teamLeague,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        )),
                    Text(widget.teamType,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: buildListView(documents, context),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blueAccent.shade200,
                              minimumSize: const Size(150, 40),
                              // foreground
                            ),
                            child: const Text(
                              'Doubles',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TeamDoubles(
                                    teamId: widget.teamId,
                                    teamSchool: widget.teamSchool,
                                    teamType: widget.teamType,
                                    teamLeague: widget.teamLeague,
                                  ),
                                ),
                              );
                            }),
                        const SizedBox(
                          height: 70,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blueAccent.shade200,
                            minimumSize: const Size(150, 40),
                            // foreground
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      MatchesCoach(teamId: widget.teamId)),
                            );
                          },
                          child: const Text(
                            'Team Matches',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                      ],
                    )
                  ],
                );
              } else if (snapshot.hasError) {
                return const Text('Its Error!');
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ));

  ListView buildListView(
      List<DocumentSnapshot<Object?>> documents, BuildContext context) {
    return ListView(
        children: documents
            .map((doc) => Card(
                    child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      doc['position'].toString(),
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.lightBlueAccent,
                  ),
                  title: Text(doc['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 30,
                      )),
                  trailing: buildRowIcons(context, doc),
                )))
            .toList());
  }

  Row buildRowIcons(BuildContext context, DocumentSnapshot<Object?> doc) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildIconButtonUpdate(context, doc),
        buildIconButtonDelete(context, doc),
        IconButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: Text(
                        'Move ${doc['name']} to a new team:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 25,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      content: TextField(
                        controller: newTeamCodeController,
                        textInputAction: TextInputAction.done,
                        decoration:
                            const InputDecoration(labelText: 'New Team Code'),
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
                              onPressed: () async {
                                await checkTeamFunc();
                                if (checkTeam) {
                                  final updateDoc = FirebaseFirestore.instance
                                      .collection('player')
                                      .doc(doc['id']);
                                  setState(() {
                                    updateDoc.update({
                                      'teamId': newTeamCodeController.text,
                                      'position': 0,
                                      'challenge': false,
                                    });
                                  });
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SignInSignOut(),
                                    ),
                                  );
                                } else {
                                  showDialog(
                                    context: (context),
                                    builder: (context) => AlertDialog(
                                      title: Text('Please enter a valid code'),
                                      titlePadding: EdgeInsets.all(10),
                                    ),
                                  );
                                }
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
          icon: const Icon(Icons.qr_code_2_sharp),
        ),
      ],
    );
  }

  bool checkTeam = false;
  Future checkTeamFunc() async {
    if (newTeamCodeController.text != "") {
      final docTeam = FirebaseFirestore.instance
          .collection("team")
          .doc(newTeamCodeController.text);
      final snapshot = await docTeam.get();
      if (snapshot.exists) {
        checkTeam = true;
      } else {
        checkTeam = false;
      }
    } else {
      checkTeam = false;
    }
  }

  IconButton buildIconButtonDelete(
      BuildContext context, DocumentSnapshot<Object?> doc) {
    return IconButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text(
                      'Are you sure that you want to remove this player from the lineup?',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 25,
                      )),
                  actions: [
                    Row(
                      children: [
                        TextButton(
                            onPressed: () {
                              final updateDoc = FirebaseFirestore.instance
                                  .collection('player')
                                  .doc(doc['id']);
                              setState(() {
                                updateDoc.delete();
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Yes',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 25,
                                ))),
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('No',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 25,
                                ))),
                      ],
                    ),
                  ],
                ));
      },
      icon: const Icon(Icons.delete),
    );
  }

  IconButton buildIconButtonUpdate(
      BuildContext context, DocumentSnapshot<Object?> doc) {
    return IconButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Update player position in the lineup:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 25,
                      )),
                  content: TextField(
                    controller: positionController,
                    decoration:
                        const InputDecoration(labelText: "New Position:"),
                    keyboardType: TextInputType.number,
                  ),
                  actions: [
                    Row(
                      children: [
                        TextButton(
                            onPressed: () {
                              int p = int.parse(positionController.text);
                              final updateDoc = FirebaseFirestore.instance
                                  .collection('player')
                                  .doc(doc['id']);
                              setState(() {
                                updateDoc.update({
                                  'position': p,
                                });
                              });
                              Navigator.pop(context);
                              positionController.clear();
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
      icon: const Icon(Icons.move_up),
    );
  }

  Future<QuerySnapshot<Object?>>? read() async {
    return await FirebaseFirestore.instance
        .collection('player')
        .orderBy('position')
        .where('teamId', isEqualTo: widget.teamId)
        .get();
  }
}
