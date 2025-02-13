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
                      .orderBy('createdAt', descending: true)
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
                          const SizedBox(height: 5),
                          const Text(
                            "Shop based on everyone's preferences. Add up to 9 members and find clothes for them based on their style easily.",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 1,
                              ),
                              itemCount: members.length,
                              itemBuilder: (context, index) {
                                var member = members[index].data()
                                    as Map<String, dynamic>;
                                String avatar =
                                    _getAvatarPath(member['avatar'] ?? '');
                                return Stack(
                                  children: [
                                    Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.asset(avatar,
                                              height: 70,
                                              width: 70,
                                              fit: BoxFit.cover),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(member['name'] ?? 'Unknown',
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
                                        onPressed: () =>
                                            _showDeleteConfirmation(
                                                context,
                                                customerDocId,
                                                members[index].id,
                                                member['name']),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          Column(
                            children: [
                              const SizedBox(height: 40),
                              // Add New Member Button
                              ElevatedButton(
                                onPressed: canAddMore
                                    ? () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  addMembers()),
                                        )
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF614FE0),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Add New Member",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // I'm Done with Adding Members Button
                              ElevatedButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PlaceholderPage()),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Color(0xFF614FE0),
                                    width: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    "I'm Done with Adding Members",
                                    style: TextStyle(
                                      color: Color(0xFF614FE0),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
