import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:line_up/handlers/utils.dart';
import 'package:line_up/screens/posts.dart';

import '../models/match.dart';
import '../models/player.dart';
import '../models/team.dart';
import 'matches.dart';

class MainPlayer extends StatefulWidget {
  @override
  State<MainPlayer> createState() => _MainPlayerState();
}

class _MainPlayerState extends State<MainPlayer> {
  String? type;
  String? university;
  Player? p;
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Team Lineup'),
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
                    height: 20,
                  ),
                  Text(university!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 30,
                      )),
                  Text(type!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 25,
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: ListView(
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
                                  trailing: IconButton(
                                    disabledColor: doc['challenge']
                                        ? Colors.red
                                        : Colors.green,
                                    color: doc['challenge']
                                        ? Colors.red
                                        : Colors.green,
                                    iconSize: 40,
                                    onPressed: ((((doc['challenge'] == false) &&
                                                    ((doc['id']) !=
                                                        (FirebaseAuth
                                                            .instance
                                                            .currentUser!
                                                            .uid))) &&
                                                (doc['position'] != 0)) &&
                                            (p?.challenge == false))
                                        ? () {
                                            if (((doc['position'] + 1) ==
                                                    (p?.position)) ||
                                                ((doc['position'] + 2) ==
                                                    (p?.position))) {
                                              final playerChallenged =
                                                  FirebaseFirestore.instance
                                                      .collection('player')
                                                      .doc(doc['id']);
                                              final playerChallenging =
                                                  FirebaseFirestore.instance
                                                      .collection('player')
                                                      .doc(FirebaseAuth.instance
                                                          .currentUser!.uid);
                                              setState(() {
                                                playerChallenging.update({
                                                  'challenge': true,
                                                });
                                                playerChallenged.update({
                                                  'challenge': true,
                                                });
                                              });
                                              saveMatch(doc['id'], doc['name'],
                                                  doc['position']);
                                              sendPushMessage(doc['token']);
                                            } else {
                                              Utils.showSnackBar(
                                                  'You can only challenge a player one or two positions above you');
                                            }
                                          }
                                        : null,
                                    icon: const Icon(
                                        Icons.sports_tennis_outlined),
                                  ),
                                )))
                            .toList()),
                  ),
                  Column(
                    children: [
                      Row(
                        verticalDirection: VerticalDirection.up,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                                    builder: (context) => const Matches()),
                              );
                            },
                            child: const Text(
                              'Team Matches',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
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
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Posts(
                                          teamId: p?.teamId,
                                          userName: p?.name,
                                        )),
                              );
                            },
                            child: const Text(
                              'Team Posts',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      )
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
          }));

  Future<Player> getPlayer() async {
    final docPlayer = FirebaseFirestore.instance
        .collection("player")
        .doc(FirebaseAuth.instance.currentUser!.uid);
    final snapshot = await docPlayer.get();
    return Player.fromJson(snapshot.data()!);
  }

  Future<QuerySnapshot<Object?>>? read() async {
    p = await getPlayer();
    final docTeam =
        FirebaseFirestore.instance.collection("team").doc(p?.teamId);
    final snapshotTeam = await docTeam.get();
    final t = Team.fromJson(snapshotTeam.data()!);
    type = t.type;
    university = t.school;
    return await FirebaseFirestore.instance
        .collection('player')
        .orderBy('position')
        .where('teamId', isEqualTo: p?.teamId)
        .get();
  }

  Future saveMatch(
      String player2id, String player2name, int player2position) async {
    final docMatch = FirebaseFirestore.instance.collection('match').doc();
    final match = Match(
      player1id: p?.id,
      player2id: player2id,
      date: '',
      result: 'No result yet',
      teamId: p?.teamId,
      player1name: p?.name,
      player2name: player2name,
      id: docMatch.id,
      player1position: p?.position,
      player2position: player2position,
      timeStamp: DateTime.now().microsecondsSinceEpoch,
      winner: 'No winner yet',
    );
    final json = match.toJson();
    await docMatch.set(json);
  }

  void sendPushMessage(String token) async {
    try {
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
                'key=AAAASs39_As:APA91bFDkJkWUtS6wbtJRdsPgFpfcO5EKMXgelG9aKkhIjq_zFJK0Z-ETM3qc7HRAIE-EODfiI1FW8sA2RX-ZsTfjCdQBZSAa6mE3CL-hymDh12GhU-iSFMpBNqyg2AVHkOcc7EhICvh',
          },
          body: jsonEncode(<String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': '${p?.name} is challenging you!',
              'title': 'New Challenge!',
            },
            'notification': <String, dynamic>{
              'body': '${p?.name} is challenging you!',
              'title': 'New Challenge!',
              'android_channel_id': 'channelID'
            },
            'to': token,
          }));
    } catch (e) {
      if (kDebugMode) {
        print('error');
      }
    }
  }
}
