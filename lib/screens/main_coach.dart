import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:line_up/screens/players_by_team.dart';
import 'package:line_up/screens/posts.dart';

import '../models/coach.dart';
import 'new_team.dart';

class MainCoach extends StatefulWidget {
  const MainCoach({Key? key}) : super(key: key);

  @override
  State<MainCoach> createState() => _MainCoachState();
}

class _MainCoachState extends State<MainCoach> {
  Coach? coach;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teams'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(
              Icons.logout,
              size: 30,
            ),
          )
        ],
      ),
      body: FutureBuilder<QuerySnapshot>(
          future: read(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<DocumentSnapshot> documents = snapshot.data!.docs;
              return Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Expanded(
                    child: ListView(
                        children: documents
                            .map((doc) => buildGestureDetector(context, doc))
                            .toList()),
                  ),
                  const NewTeamButton(),
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
    );
  }

  GestureDetector buildGestureDetector(
      BuildContext context, DocumentSnapshot<Object?> doc) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayersByTeam(
              teamId: doc['id'],
              teamSchool: doc['school'],
              teamType: doc['type'],
              teamLeague: doc['league'],
            ),
          ),
        );
      },
      child: Card(
        child: Slidable(
          endActionPane: ActionPane(
            motion: ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Text(
                              'Are you sure you want to delete this team?',
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
                                      final deleteDoc = FirebaseFirestore
                                          .instance
                                          .collection('team')
                                          .doc(doc['id']);
                                      setState(() {
                                        deleteDoc.delete();
                                      });
                                      Navigator.pop(context);
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
                icon: Icons.delete,
                backgroundColor: Colors.red,
              )
            ],
          ),
          child: ListTile(
            title: Text(
              doc['school'],
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 25,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () async {
                    final c = await getCoach();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Posts(
                          teamId: doc['id'],
                          userName: c.name,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.post_add),
                ),
                IconButton(
                  onPressed: () {
                    buildShowDialog(context, doc);
                  },
                  icon: const Icon(Icons.qr_code_2_sharp),
                ),
              ],
            ),
            subtitle: Text('${doc['type']}\n${doc['league']}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                )),
          ),
        ),
      ),
    );
  }

  Future<dynamic> buildShowDialog(
      BuildContext context, DocumentSnapshot<Object?> doc) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Team Code:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 25,
                  )),
              content: Text(doc['id'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  )),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 25,
                        ))),
                TextButton(
                    onPressed: () {
                      final value = ClipboardData(text: doc['id']);
                      Clipboard.setData(value);
                      Navigator.pop(context);
                    },
                    child: const Text('Copy',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 25,
                        ))),
              ],
            ));
  }

  Future<Coach> getCoach() async {
    final docCoach = FirebaseFirestore.instance
        .collection("coach")
        .doc(FirebaseAuth.instance.currentUser!.uid);
    final snapshot = await docCoach.get();
    return Coach.fromJson(snapshot.data()!);
  }

  Future<QuerySnapshot<Object?>>? read() async {
    coach = await getCoach();
    return await FirebaseFirestore.instance
        .collection('team')
        .where('coachId', isEqualTo: coach?.id)
        .get();
  }
}

class NewTeamButton extends StatelessWidget {
  const NewTeamButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 70,
        ),
        const SizedBox(
          width: 190,
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
              MaterialPageRoute(builder: (context) => const NewTeam()),
            );
          },
          child: const Text(
            'New Team',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ],
    );
  }
}
