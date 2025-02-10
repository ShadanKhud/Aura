import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addMembers.dart';
import 'package:aura_app/Sign_up_in/PlaceholderPage.dart';

class ManageMembersPage extends StatefulWidget {
  @override
  _ManageMembersPageState createState() => _ManageMembersPageState();
}

class _ManageMembersPageState extends State<ManageMembersPage> {
  String? userEmail = FirebaseAuth.instance.currentUser?.email;

  String _getAvatarPath(String avatar) {
    final match = RegExp(r'Avatar (\d+)').firstMatch(avatar);
    if (match != null) {
      return 'assets/avatar${match.group(1)}.png';
    }
    return 'assets/avatar1.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Members"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: userEmail == null
          ? const Center(child: Text("User not logged in"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('customers')
                  .where('email', isEqualTo: userEmail)
                  .snapshots(),
              builder: (context, customerSnapshot) {
                if (!customerSnapshot.hasData ||
                    customerSnapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No customer found"));
                }

                String customerDocId = customerSnapshot.data!.docs.first.id;

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('customers')
                      .doc(customerDocId)
                      .collection('members')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var members = snapshot.data!.docs;
                    bool canAddMore = members.length < 9;

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Members",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Shop based on everyone's preferences. Add up to 9 members and find clothes for them based on their style easily.",
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: members.isNotEmpty
                                ? GridView.builder(
                                    padding: const EdgeInsets.only(top: 10),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 20,
                                      mainAxisSpacing: 20,
                                      childAspectRatio: 1,
                                    ),
                                    itemCount: members.length,
                                    itemBuilder: (context, index) {
                                      var member = members[index].data()
                                          as Map<String, dynamic>;
                                      String avatar = _getAvatarPath(
                                          member['avatar'] ?? '');
                                      return Column(
                                        children: [
                                          Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.asset(
                                                  avatar,
                                                  height: 70,
                                                  width: 70,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Positioned(
                                                top: -10,
                                                right: -10,
                                                child: IconButton(
                                                  icon: const Icon(Icons.close,
                                                      size: 20,
                                                      color: Colors.red),
                                                  onPressed: () async {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('customers')
                                                        .doc(customerDocId)
                                                        .collection('members')
                                                        .doc(members[index].id)
                                                        .delete();
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(member['name'],
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      );
                                    },
                                  )
                                : const Center(
                                    child: Text("No members added yet")),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canAddMore
                                    ? const Color(0xFF614FE0)
                                    : Colors.grey,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              onPressed: canAddMore
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => addMembers()),
                                      );
                                    }
                                  : null,
                              child: const Text(
                                'Add New Member',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                side:
                                    const BorderSide(color: Color(0xFF614FE0)),
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PlaceholderPage()),
                                );
                              },
                              child: const Text(
                                "I'm done with adding members",
                                style: TextStyle(
                                    fontSize: 16, color: Color(0xFF614FE0)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
