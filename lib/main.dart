import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MessagesClone());
}

class MessagesClone extends StatelessWidget {
  const MessagesClone({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MessagesHome(),
    );
  }
}

class MessagesHome extends StatefulWidget {
  const MessagesHome({super.key});

  @override
  State<MessagesHome> createState() => _MessagesHomeState();
}

class _MessagesHomeState extends State<MessagesHome> {
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? messagesData = prefs.getString('messages');
    if (messagesData != null) {
      try {
        List<dynamic> decodedMessages = jsonDecode(messagesData);
        //print("Loaded messages: $decodedMessages"); // Debug print

        // Convert the decoded list to the correct type
        setState(() {
          messages = decodedMessages.map((message) {
            // Ensure that the map is cast correctly
            return {
              ...message as Map<String,
                  dynamic>, // Explicitly cast to Map<String, dynamic>
              "color": Color(int.parse(message["color"],
                  radix: 16)), // Convert from hex string to Color
            };
          }).toList();
        });
      } catch (e) {
        //print("Failed to decode messages: $e");
        setState(() {
          messages = []; // Reset if decode fails
        });
      }
    } else {
      //print("No saved messages found.");
    }
  }

  Future<void> _saveMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      // Convert colors to hex strings before saving
      List<Map<String, dynamic>> encodedMessages = messages.map((message) {
        return {
          ...message,
          "color": (message["color"] as Color)
              .value
              .toRadixString(16), // Convert to hex string
        };
      }).toList();

      prefs.setString('messages', jsonEncode(encodedMessages));
      //print("Messages saved: ${jsonEncode(encodedMessages)}");
    } catch (e) {
      //print("Failed to save messages: $e");
    }
  }

  void _addMessage(Map<String, dynamic> newMessage) {
    setState(() {
      messages.add(newMessage);
    });
    _saveMessages();
  }

  void _removeMessage(int index) {
    setState(() {
      messages.removeAt(index);
    });
    _saveMessages();
  }

  void _showAddMessageSheet(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController timeController = TextEditingController();

    final TextEditingController message1Controller = TextEditingController();
    final TextEditingController time1Controller = TextEditingController();

    final TextEditingController message2Controller = TextEditingController();
    final TextEditingController time2Controller = TextEditingController();

    final TextEditingController message3Controller = TextEditingController();
    final TextEditingController time3Controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Add New Message",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Sender",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    labelText: "Main Time (e.g., 5:56 PM)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: message1Controller,
                  decoration: const InputDecoration(
                    labelText: "Message 1",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: time1Controller,
                  decoration: const InputDecoration(
                    labelText: "Timestamp 1 (e.g., Yesterday , 5:56 PM)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: message2Controller,
                  decoration: const InputDecoration(
                    labelText: "Message 2",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: time2Controller,
                  decoration: const InputDecoration(
                    labelText: "Timestamp 2 (e.g., Today , 6:12 PM)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: message3Controller,
                  decoration: const InputDecoration(
                    labelText: "Message 3",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: time3Controller,
                  decoration: const InputDecoration(
                    labelText: "Timestamp 3 (e.g., Tuesday , 6:45 PM)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final String title = titleController.text.trim();
                    final String mainTime = timeController.text.trim();

                    if (title.isEmpty || mainTime.isEmpty) {
                      Navigator.pop(context);
                      return;
                    }

                    List<Map<String, dynamic>> messageDetails = [];

                    if (message1Controller.text.trim().isNotEmpty &&
                        time1Controller.text.trim().isNotEmpty) {
                      messageDetails.add({
                        "timestamp": time1Controller.text.trim(),
                        "message": message1Controller.text.trim(),
                      });
                    }

                    if (message2Controller.text.trim().isNotEmpty &&
                        time2Controller.text.trim().isNotEmpty) {
                      messageDetails.add({
                        "timestamp": time2Controller.text.trim(),
                        "message": message2Controller.text.trim(),
                      });
                    }

                    if (message3Controller.text.trim().isNotEmpty &&
                        time3Controller.text.trim().isNotEmpty) {
                      messageDetails.add({
                        "timestamp": time3Controller.text.trim(),
                        "message": message3Controller.text.trim(),
                      });
                    }

                    _addMessage({
                      "name": title,
                      "message": message1Controller.text
                          .trim(), // Use the first message as the preview
                      "time": mainTime,
                      "unread": 0,
                      "color": Colors
                          .primaries[messages.length % Colors.primaries.length],
                      "details": messageDetails,
                    });

                    Navigator.pop(context);
                  },
                  child: const Text("Add Message"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        elevation: 1,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SvgPicture.asset('images/google1.svg'),
        ),
        title: const Text(
          "Messages",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.normal,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              _showAddMessageSheet(context);
            },
          ),
          CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, color: Colors.black),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MessageDetailScreen(message: message)));
            },
            onLongPress: () => _removeMessage(index),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: message['color'],
                child: const Icon(Icons.person, color: Colors.white),
              ),
              title: Text(message['name']),
              subtitle: Text(
                message['message'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(message['time']),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.pink[50],
        foregroundColor: Colors.black,
        onPressed: () {
          _showAddMessageSheet(context);
        },
        label: const Row(
          children: [
            Icon(Icons.chat),
            SizedBox(width: 5),
            Text("Start chat"),
          ],
        ),
      ),
    );
  }
}

class MessageDetailScreen extends StatefulWidget {
  final Map<String, dynamic> message;

  const MessageDetailScreen({super.key, required this.message});

  @override
  MessageDetailScreenState createState() => MessageDetailScreenState();
}

class MessageDetailScreenState extends State<MessageDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: widget.message['color'],
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.message['name'],
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SingleChildScrollView(
                        reverse: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: widget.message['details']
                              .map<Widget>((detail) => Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 8.0, left: 0, right: 30),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                         'Today , ' + detail['timestamp'],
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          margin:
                                              const EdgeInsets.only(bottom: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color: Colors.grey[300]!),
                                          ),
                                          child: Text(
                                            detail['message'],
                                            style:
                                                const TextStyle(fontSize: 17),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.grey[100],
        child: const Padding(
          padding: EdgeInsets.all(13),
          child: Text(
            "Can't reply to this short code.",
            style: TextStyle(color: Colors.black, fontSize: 17),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
