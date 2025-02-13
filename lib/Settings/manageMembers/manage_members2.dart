import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aura_app/Settings/manageMembers/addMembers2.dart';
import 'package:aura_app/Settings/settings.dart';

class ManageMembersPage2 extends StatelessWidget {
  const ManageMembersPage2({Key? key}) : super(key: key);

  Stream<QuerySnapshot> _getMembersStream() {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('customers')
        .where('email', isEqualTo: userEmail)
        .limit(1)
        .snapshots()
        .asyncExpand((customerSnapshot) {
      if (customerSnapshot.docs.isEmpty) return const Stream.empty();
      String customerId = customerSnapshot.docs.first.id;
      return FirebaseFirestore.instance
          .collection('customers')
          .doc(customerId)
          .collection('members')
          .orderBy('createdAt', descending: true)
          .snapshots();
    });
  }

  Future<void> _deleteMember(String customerId, String memberId) async {
    await FirebaseFirestore.instance
        .collection('customers')
        .doc(customerId)
        .collection('members')
        .doc(memberId)
        .delete();
  }

  void _showDeleteConfirmation(
      BuildContext context, String customerId, String memberId, String name) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Delete Member?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Are you sure you want to delete $name? You will not be able to retrieve the member’s data.",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child:
                        Text("Cancel", style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    onPressed: () {
                      _deleteMember(customerId, memberId);
                      Navigator.pop(context);
                    },
                    child:
                        Text("Delete", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

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
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Members",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Shop based on everyone's preferences. Add up to 9 members and find clothes for them based on their style easily.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getMembersStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No members added yet."));
                  }

                  var members = snapshot.data!.docs;
                  String customerId =
                      FirebaseAuth.instance.currentUser?.uid ?? '';

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      var member = members[index];
                      String memberId = member.id;
                      String name = member['name'] ?? 'Unknown';
                      String avatar = _getAvatarPath(member['avatar'] ?? '');

                      return Stack(
                        children: [
                          Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(avatar,
                                    height: 70, width: 70, fit: BoxFit.cover),
                              ),
                              const SizedBox(height: 5),
                              Text(name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14)),
                            ],
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.red, size: 20),
                              onPressed: () => _showDeleteConfirmation(
                                  context, customerId, memberId, name),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: _getMembersStream(),
              builder: (context, snapshot) {
                bool canAddMember =
                    snapshot.hasData && snapshot.data!.docs.length < 9;
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          canAddMember ? const Color(0xFF614FE0) : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    onPressed: canAddMember
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => addMembers2()),
                            );
                          }
                        : null,
                    child: const Text("Add New Member",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
