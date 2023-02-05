import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/post.dart';
import '../models/team.dart';

class Posts extends StatefulWidget {
  const Posts({Key? key, required this.teamId, required this.userName})
      : super(key: key);
  final String? teamId;
  final String? userName;

  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("posts")
            .where('teamId', isEqualTo: widget.teamId)
            .orderBy(
              "timeStamp",
              descending: true,
            )
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError ||
              snapshot.connectionState == ConnectionState.none ||
              !snapshot.hasData) {
            return const Center(child: Text("No posts yet!"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final QueryDocumentSnapshot doc = snapshot.data!.docs[index];

              final Post post = Post.fromSnapshot(doc);

              return Column(
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    alignment: Alignment.topLeft,
                    child: Text(post.userName,
                        style: Theme.of(context).textTheme.headline5),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.black26,
                        border: Border.all(
                          color: Colors.blueGrey,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    //margin: EdgeInsets.all(5),
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.topLeft,
                    child: Text(post.description,
                        style: Theme.of(context).textTheme.headline6),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    alignment: Alignment.topRight,
                    child: Text(
                      '${post.timeStamp.toDate().month.toString()}/'
                      '${post.timeStamp.toDate().day.toString()}/'
                      '${post.timeStamp.toDate().year.toString()}  '
                      '${post.timeStamp.toDate().hour.toString()}:'
                      '${post.timeStamp.toDate().minute.toString()}',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent.shade200,
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: const Text('New Post',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 25,
                        )),
                    content: TextField(
                      maxLines: null,
                      controller: descriptionController,
                      decoration: const InputDecoration(
                          labelText: "Type you post here..."),
                    ),
                    actions: [
                      Row(
                        children: [
                          TextButton(
                              onPressed: () async {
                                if (descriptionController.text != "") {
                                  final docPost = FirebaseFirestore.instance
                                      .collection('posts')
                                      .doc();
                                  final post = Post(
                                    id: docPost.id,
                                    teamId: widget.teamId!,
                                    userName: widget.userName!,
                                    timeStamp: Timestamp.now(),
                                    description: descriptionController.text,
                                  );
                                  final json = post.toJson();
                                  await docPost.set(json);
                                  Navigator.pop(context);
                                  descriptionController.clear();
                                  FirebaseFirestore.instance
                                      .collection('player')
                                      .where('teamId',
                                          isEqualTo: widget.teamId!)
                                      .get()
                                      .then((QuerySnapshot snapshot) {
                                    snapshot.docs.forEach((element) {
                                      sendPushMessage(element['token']);
                                    });
                                  });
                                  final docTeam = FirebaseFirestore.instance
                                      .collection("team")
                                      .doc(widget.teamId!);
                                  final snapshotTeam = await docTeam.get();
                                  final t = Team.fromJson(snapshotTeam.data()!);
                                  FirebaseFirestore.instance
                                      .collection('coach')
                                      .where('id', isEqualTo: t.coachId)
                                      .get()
                                      .then((QuerySnapshot snapshot) {
                                    snapshot.docs.forEach((element) {
                                      sendPushMessage(element['token']);
                                    });
                                  });
                                }
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
        child: const Icon(Icons.add),
      ),
    );
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
              'body': 'Check it out...',
              'title': 'New Post!',
            },
            'notification': <String, dynamic>{
              'body': 'Check it out...',
              'title': 'New Post!',
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
