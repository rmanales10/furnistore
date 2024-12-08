import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  _ActivityLogScreenState createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> activityData = [];
  String searchQuery = "";
  String filterType =
      "All"; // Controls which data is displayed: All, Online, Offline

  @override
  void initState() {
    super.initState();
    _fetchActivityData();
  }

  Future<void> _fetchActivityData() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      setState(() {
        activityData = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print("Error fetching activity data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter data based on selected filter type and search query
    final filteredData = activityData
        .where((row) =>
            (filterType == "All" || row['status'] == filterType) &&
            (row['email']?.toLowerCase() ?? '')
                .contains(searchQuery.toLowerCase()))
        .toList();

    // Calculate total, online, and offline users
    final totalUsers = activityData.length;
    final onlineUsers =
        activityData.where((row) => row['status'] == "online").length;
    final offlineUsers =
        activityData.where((row) => row['status'] == "offline").length;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                const Text(
                  'Activity Log',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                // Search Bar
                TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search by email...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Summary Row: Total Users, Online Users, Offline Users
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryCard(
                      title: "Total Users",
                      count: totalUsers,
                      color: Colors.grey.withOpacity(0.5),
                      textColor: Colors.black,
                      onTap: () {
                        setState(() {
                          filterType = "All"; // Show all users
                        });
                      },
                    ),
                    _buildSummaryCard(
                      title: "Online Users",
                      count: onlineUsers,
                      color: Colors.blue.withOpacity(0.8),
                      textColor: Colors.white,
                      onTap: () {
                        setState(() {
                          filterType = "online"; // Show only online users
                        });
                      },
                    ),
                    _buildSummaryCard(
                      title: "Offline Users",
                      count: offlineUsers,
                      color: Colors.black.withOpacity(0.8),
                      textColor: Colors.white,
                      onTap: () {
                        setState(() {
                          filterType = "offline"; // Show only offline users
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Data Table
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        columnSpacing: 24.0,
                        columns: const [
                          DataColumn(label: Text("ID")),
                          DataColumn(label: Text("Email")),
                          DataColumn(label: Text("IP Address")),
                          DataColumn(label: Text("Date")),
                          DataColumn(label: Text("Time")),
                          DataColumn(label: Text("Action")),
                        ],
                        rows: filteredData.map((row) {
                          Timestamp? timestamp = row['createdAt'] as Timestamp?;
                          DateTime? dateTime = timestamp?.toDate();
                          String formattedDate = dateTime != null
                              ? DateFormat('yyyy-MM-dd').format(dateTime)
                              : 'N/A';
                          String formattedTime = dateTime != null
                              ? DateFormat('hh:mm:ss a').format(dateTime)
                              : 'N/A';

                          return DataRow(cells: [
                            DataCell(Text(row['idNumber'] ?? 'N/A')),
                            DataCell(Text(row['email'] ?? 'N/A')),
                            DataCell(Text(row['ipAddress'] ?? 'N/A')),
                            DataCell(Text(formattedDate)),
                            DataCell(Text(formattedTime)),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: row['status'] == "online"
                                      ? Colors.green
                                      : Colors.red,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Text(
                                  row['status'] ?? 'N/A',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required int count,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),
              const SizedBox(height: 10),
              Text(
                "$count",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
