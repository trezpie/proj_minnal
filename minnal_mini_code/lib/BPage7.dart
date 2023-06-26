import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minnalmini/BPage9.dart';
import 'package:image_network/image_network.dart';
import 'package:firebase_storage/firebase_storage.dart';

class BPage7 extends StatefulWidget {
  final String complaintDocumentId;

  const BPage7({Key? key, required this.complaintDocumentId}) : super(key: key);

  @override
  _BPage7State createState() => _BPage7State();
}

class _BPage7State extends State<BPage7> {
  int? selectedRadioValue;
  String? poleNumber;
  String? complaintType;
  String? consumerNumber;
  String? consumerName;
  String? consumerAddress;
  String? status;
  String? comments;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    fetchComplaintDetails();
  }

  Future<void> fetchComplaintDetails() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> complaintSnapshot =
          await FirebaseFirestore.instance
              .collection('Complaints')
              .doc(widget.complaintDocumentId)
              .get();

      Map<String, dynamic>? complaintData = complaintSnapshot.data();
      if (complaintData != null) {
        consumerNumber = complaintData['consumerNumber'];
        complaintType = complaintData['complaintType'];
        poleNumber = complaintData['poleNumber'];
        status = complaintData['status'];
        comments = complaintData['comments'];
        // imageUrl = complaintData['imageUrl'];
        String imagePath = complaintData['imageUrl'];
        String downloadUrl = await getDownloadUrl(imagePath);

        print(
            'Consumer Number: $consumerNumber, Complaint Type: $complaintType');

        // Set the selected radio button based on the fetched status
        if (status == 'pending') {
          selectedRadioValue = 2;
        } else if (status == 'resolved') {
          selectedRadioValue = 1;
        } else if (status == 'processing') {
          selectedRadioValue = 3;
        }

        setState(() {
          imageUrl = downloadUrl;
        });

        QuerySnapshot<Map<String, dynamic>> consumerSnapshot =
            await FirebaseFirestore.instance
                .collection('consumers')
                .where('consumerNumber', isEqualTo: consumerNumber)
                .limit(1)
                .get();

        if (consumerSnapshot.docs.isNotEmpty) {
          DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
              consumerSnapshot.docs.first;
          Map<String, dynamic>? consumerData = documentSnapshot.data();
          if (consumerData != null) {
            String name = consumerData['name'];
            String address = consumerData['address'];

            print('Name: $name, Address: $address');

            setState(() {
              this.consumerName = name;
              this.consumerAddress = address;
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching complaint details: $e');
    }
  }

  Future<String> getDownloadUrl(String imagePath) async {
    Reference ref = FirebaseStorage.instance.ref().child(imagePath);
    String downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }

  Widget buildImageWidget() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      // If imageUrl exists, display the fetched image
      return Image.network(
        imageUrl!,
        width: 200,
        height: 200,
        fit: BoxFit.cover,
      );
    } else {
      // If imageUrl is empty or null, display a default image
      return Image.asset(
        'images/pic.png',
        width: 200,
        height: 200,
        fit: BoxFit.cover,
      );
    }
  }

  Future<void> updateComplaintDetails() async {
    try {
      await FirebaseFirestore.instance
          .collection('Complaints')
          .doc(widget.complaintDocumentId)
          .update({
        'status': status,
        'comments': comments,
      });
      print('Complaint details updated successfully!');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Updated'),
            content: Text('Complaint status updated successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error updating complaint details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 103,
        title: Column(
          children: const [
            Text(
              'SET STATUS',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color.fromARGB(255, 255, 255, 0),
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BPage9(),
                ),
              );
            },
            icon: const Icon(
              Icons.menu,
              color: Color.fromARGB(255, 255, 255, 0),
              size: 30,
            ),
          ),
        ],
        elevation: 10,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Pole No.  : P${poleNumber ?? ''}',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 2.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        width: 299,
                        color: Color.fromARGB(255, 194, 190, 190),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Name: $consumerName',
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 299,
                        color: Color.fromARGB(255, 194, 190,
                            190), // Set the color for the padding
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Address : $consumerAddress',
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 299,
                        color: Color.fromARGB(255, 194, 190,
                            190), // Set the color for the padding
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Issue : $complaintType',
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                      ),
                      Text(
                        "Image:",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          height: 300,
                          width: 300,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.yellow,
                              width: 2.0,
                            ),
                          ),
                          child: buildImageWidget(),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            "Resolved?",
                            style: TextStyle(
                                fontSize: 23, fontWeight: FontWeight.bold),
                          ),
                          RadioListTile(
                            title: Text('Yes'),
                            value: 1,
                            groupValue: selectedRadioValue,
                            onChanged: (value) {
                              setState(() {
                                selectedRadioValue = value as int?;
                                status = 'resolved';
                              });
                            },
                          ),
                          RadioListTile(
                            title: Text('No'),
                            value: 2,
                            groupValue: selectedRadioValue,
                            onChanged: (value) {
                              setState(() {
                                selectedRadioValue = value as int?;
                                status = 'pending';
                              });
                            },
                          ),
                          RadioListTile(
                            title: Text('Processing'),
                            value: 3,
                            groupValue: selectedRadioValue,
                            onChanged: (value) {
                              setState(() {
                                selectedRadioValue = value as int?;
                                status = 'processing';
                              });
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Add Comments',
                              style: TextStyle(
                                  fontSize: 23,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            // child: TextField(),
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  comments = value;
                                });
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Add Comments',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                updateComplaintDetails();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 255, 255, 0),
                                side: BorderSide(
                                    color: Colors.black,
                                    width:
                                        2.0), // Set the desired background color
                              ),
                              child: Text(
                                'Save',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 25),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
