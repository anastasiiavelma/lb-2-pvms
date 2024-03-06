import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Max Element Finder',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  List<int> numbers = [];
  int? maxElement;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> findMaxElement() async {
    const String serverIp = '10.0.2.2';
    const int serverPort = 4898;

    try {
      RawDatagramSocket socket =
          await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

      // Відправляєм масив на сервер
      final jsonData = jsonEncode({'numbers': numbers});
      socket.send(utf8.encode(jsonData), InternetAddress(serverIp), serverPort);

      // Відповідь від серверу
      socket.listen((event) {
        if (event == RawSocketEvent.read) {
          Datagram? datagram = socket.receive();
          if (datagram != null) {
            final String data = utf8.decode(datagram.data);
            final Map<String, dynamic> jsonData = jsonDecode(data);
            final int? max = jsonData['max'];
            if (max != null) {
              setState(() {
                maxElement = max;
              });
            } else {
              if (kDebugMode) {
                print('Error: Max value is not provided by the server');
              }
            }
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Max Element Finder'),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.pink.shade200,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Enter numbers separated by commas'),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 235, 147, 177)),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 235, 147, 177)),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    labelText: '1,2,3',
                    filled: true,
                    fillColor: Colors.white,
                    focusColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      numbers = value
                          .split(',')
                          .map((e) => int.tryParse(e.trim()) ?? 0)
                          .toList();
                    });
                  },
                ),
              ),
              ElevatedButton(
                onPressed: findMaxElement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: const Text(
                  'Find Max Element',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              if (maxElement != null)
                Text(
                  'Max Element: $maxElement',
                  style: const TextStyle(fontSize: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
