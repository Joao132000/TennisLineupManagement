import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_up/handlers/signin_signout.dart';

import '../models/team.dart';

class NewTeam extends StatefulWidget {
  const NewTeam({Key? key}) : super(key: key);

  @override
  State<NewTeam> createState() => _NewTeamState();
}

class _NewTeamState extends State<NewTeam> {
  final schoolController = TextEditingController();
  final leagueController = TextEditingController();
  String type = 'Men Tennis Team';

  @override
  void dispose() {
    schoolController.dispose();
    leagueController.dispose();
    super.dispose();
  }

  String dropdownvalue = 'Men Tennis Team';

  // List of items in our dropdown menu
  var items = [
    "Men Tennis Team",
    'Women Tennis Team',
    'Boys Tennis Team',
    'Girls Tennis Team',
    'Men Senior',
    'Women Senior',
    'Overall',
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('New Team'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Create a New Team',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: schoolController,
                textInputAction: TextInputAction.next,
                decoration:
                    const InputDecoration(labelText: 'School/Organization'),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: leagueController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'League'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  DropdownButton(
                    alignment: AlignmentDirectional.bottomStart,
                    value: dropdownvalue,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: items.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownvalue = newValue!;
                        type = newValue;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  saveTeam();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignInSignOut()),
                  );
                },
                style: ButtonStyle(
                    minimumSize:
                        MaterialStateProperty.all(const Size(200, 50))),
                child: const Text(
                  'Create',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      );

  Future saveTeam() async {
    final docCoach = FirebaseFirestore.instance.collection('team').doc();
    final coach = Team(
      id: docCoach.id,
      type: type,
      school: schoolController.text,
      league: leagueController.text,
      coachId: FirebaseAuth.instance.currentUser!.uid,
    );
    final json = coach.toJson();
    await docCoach.set(json);
  }
}
