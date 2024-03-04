// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({Key? key}) : super(key: key);

  @override
  _TeamScreenState createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final TextEditingController _teamNameController = TextEditingController();

  void _saveTeam() async {
    String teamName = _teamNameController.text;

    if (teamName.isNotEmpty) {
      // Check if a team with the same name already exists
      QuerySnapshot teamQuery = await FirebaseFirestore.instance
          .collection('team')
          .where('teamName', isEqualTo: teamName)
          .get();

      if (teamQuery.docs.isEmpty) {
        // No team with the same name found, proceed to save
        await FirebaseFirestore.instance.collection('team').add({
          'teamName': teamName,
        });

        _teamNameController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Equipe salva com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Team with the same name already exists
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Já existe uma equipe com este nome.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira um nome para a equipe.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _deleteTeam(String teamId) async {
    await FirebaseFirestore.instance.collection('team').doc(teamId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Equipe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _teamNameController,
              decoration: const InputDecoration(
                labelText: 'Nome da Equipe',
                prefixIcon: Icon(Icons.group_add),
                enabled: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 0.6, color: Colors.grey),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: ElevatedButton.icon(
                onPressed: _saveTeam,
                icon: const Icon(Icons.add),
                label:
                    const Text('Criar Equipe', style: TextStyle(fontSize: 16)),
              ),
            ),
            Divider(
              endIndent: MediaQuery.of(context).size.width * 0.1,
              indent: MediaQuery.of(context).size.width * 0.1,
              height: 30,
            ),
            Expanded(
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('team').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final teams = snapshot.data!.docs;
                    return ListView.separated(
                      itemCount: teams.length,
                      separatorBuilder: (context, index) =>
                          const Divider(), // Separator
                      itemBuilder: (context, index) {
                        final team = teams[index];
                        final teamName = team['teamName'];
                        final teamId = team.id;
                        return Dismissible(
                          key: Key(teamId),
                          background: Container(
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: Colors.red),
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          onDismissed: (direction) {
                            _deleteTeam(teamId);
                          },
                          confirmDismiss: (DismissDirection direction) async {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Confirmar Exclusão"),
                                  content: const Text(
                                      "Tem certeza de que deseja excluir esta equipe?"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text("Sim"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text("Não"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 0.7),
                                borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              title: const Text("Equipe",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              leading:
                                  const FaIcon(FontAwesomeIcons.peopleGroup),
                              selected: true,
                              subtitle: Text(teamName,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic)),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
