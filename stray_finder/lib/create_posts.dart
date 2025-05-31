import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:stray_finder/storage.dart';
import 'package:stray_finder/ui.dart';

class Posts extends StatefulWidget {
  Posts({Key? key}) : super(key: key);

  final PostStorage storage = PostStorage();

  @override
  State<Posts> createState() => _PostState();
}

class _PostState extends State<Posts> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  LatLng _selectedLocation = const LatLng(0, 0);
  late Future<Stream<DocumentSnapshot>> _stream;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      String nameString = _nameController.text;
      String descString = _descController.text;
      GeoPoint location =
          GeoPoint(_selectedLocation.latitude, _selectedLocation.longitude);

      await widget.storage.writeForm(nameString, descString, location);
      _nameController.clear();
      _descController.clear();
    }
  }

  String? _textValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  void _press() {
    _submit();
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _stream = widget.storage.getStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Posts', style: TextStyle(color: Colors.black)),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: getBody(),
          ),
        ),
      ),
    );
  }

  List<Widget> getBody() {
    return <Widget>[
      TextFormField(
        controller: _nameController,
        validator: _textValidator,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Enter your name',
        ),
      ),
      const SizedBox(height: 10),
      TextFormField(
          controller: _descController,
          validator: _textValidator,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Enter a description',
          )),
      const SizedBox(height: 10),
      ElevatedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UI(
                        onLocationSelected: (LatLng selectedLocation) {
                          setState(() {
                            _selectedLocation = selectedLocation;
                          });
                        },
                      )));
        },
        child: const Text('Set Location'),
      ),
      const SizedBox(height: 10),
      ElevatedButton(
        onPressed: _press,
        child: const Text('Submit'),
      ),
      const SizedBox(height: 30),
      FutureBuilder(
        future: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return StreamBuilder(
              stream: snapshot.data,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                } else {
                  return const Text('');
                }
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    ];
  }
}
