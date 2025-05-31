import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:stray_finder/path.dart';
import 'package:stray_finder/storage.dart';

class PostsList extends StatefulWidget {
  PostsList({Key? key}) : super(key: key);

  final PostStorage storage = PostStorage();

  @override
  State<PostsList> createState() => _PostsListState();
}

class _PostsListState extends State<PostsList> {
  late Future<Stream<QuerySnapshot>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = widget.storage.getFormsStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Posts', style: TextStyle(color: Colors.black)),
      ),
      body: FutureBuilder<Stream<QuerySnapshot>>(
        future: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return StreamBuilder<QuerySnapshot>(
              stream: snapshot.data,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    children: snapshot.data!.docs.map((DocumentSnapshot doc) {
                      Map<String, dynamic> data =
                          doc.data()! as Map<String, dynamic>;
                      return Card(
                        color: const Color.fromARGB(255, 167, 240, 248),
                        child: ListTile(
                          title: Text(data['name']),
                          subtitle: Text(data['description']),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Waypoint(
                                  destination: LatLng(
                                      data['location'].latitude as double,
                                      data['location'].longitude as double),
                                  onLocationSelected:
                                      (LatLng selectedLocation) {
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
