import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Quote App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple, // App bar color
        ),
        backgroundColor: Colors.deepPurple[300], // Background color
      ),
      debugShowCheckedModeBanner: false,
      home: QuotePage(),
    );
  }
}

class QuotePage extends StatefulWidget {
  @override
  _QuotePageState createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {
  String quote = "Loading...";
  String author = "";
  bool isFavorite = false;
  List<String> favoriteQuotes = [];

  @override
  void initState() {
    super.initState();
    fetchQuote();
  }

  Future<void> fetchQuote() async {
    try {
      final response = await http.get(Uri.parse('http://api.quotable.io/random'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          quote = data['content'];
          author = data['author'];
          isFavorite = false; // Reset isFavorite when fetching a new quote
        });
      } else {
        throw Exception('Failed to load quote');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void shareQuote() {
    final String text = Uri.encodeComponent('$quote\n- $author');
    final String whatsappUrl = 'whatsapp://send?text=$text';

    // Use url_launcher to launch WhatsApp
    launch(whatsappUrl);
  }

  void toggleFavorite() {
    setState(() {
      if (isFavorite) {
        favoriteQuotes.remove('$quote\n- $author');
      } else {
        favoriteQuotes.add('$quote\n- $author');
      }
      isFavorite = !isFavorite;
    });
  }

  void showFavorites() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Favorite Quotes'),
          content: SingleChildScrollView(
            child: Column(
              children: favoriteQuotes
                  .map((quote) => ListTile(
                        title: Text(quote),
                      ))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Daily Quote', style: TextStyle(color: Colors.white)),
            Spacer(),
            GestureDetector(
              onTap: showFavorites,
              child: Icon(
                Icons.favorite,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true, // Center align the title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              quote,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              '- $author',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: fetchQuote,
            tooltip: 'Next Quote',
            child: Icon(Icons.arrow_forward),
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            onPressed: toggleFavorite,
            tooltip: 'Favorite Quote',
            child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            onPressed: shareQuote,
            tooltip: 'Share Quote',
            child: Icon(Icons.share),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
