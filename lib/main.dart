import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:share_plus/share_plus.dart';
import 'option.dart';


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Get any initial links

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => const HomePage(),
        '/helloworld': (BuildContext context) => _DynamicLinkScreen(),
      },
    );
  }
}
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final TextEditingController _editingController = TextEditingController();
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  final String DynamicLink = 'https://www.google.com/helloworld';
  final String Link = 'https://referandearnra.page.link/XktS';
  late Timer _timerLink;
  bool _isCreatingLink = false;
  String? _linkMessage;
@override
void initState(){
  initDynamicLinks();
  super.initState();
}
  Future<void> initDynamicLinks() async {
    dynamicLinks.onLink.listen((dynamicLinkData) {
      print('app is here');
      Navigator.pushNamed(context,'/helloworld' );

    }).onError((error) {
      print('onLink error');
      print(error.message);
    });
  }
  Future<void> _createDynamicLink(bool short) async {
    setState(() {
      _isCreatingLink = true;
    });

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://referandearnra.page.link/XktS',
      longDynamicLink: Uri.parse(
        'https://referandearnra.page.link/?link=https://www.google.com&apn=com.example.firebase_dynamic_link',
      ),
      link: Uri.parse(DynamicLink),
      androidParameters: const AndroidParameters(
        packageName: 'com.example.firebase_dynamic_link',
        minimumVersion: 0,
      ),
      iosParameters: const IOSParameters(
        bundleId: 'com.example.firebase_dynamic_link',
        minimumVersion: '0',
      ),
    );

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink =
      await dynamicLinks.buildShortLink(parameters);
      url = shortLink.shortUrl;
      print(url);
    } else {
      url = await dynamicLinks.buildLink(parameters);
      print(url);
    }

    setState(() {
      _linkMessage = url.toString();
      _isCreatingLink = false;
    });
  }


  @override


  @override
  void dispose() {
    _timerLink.cancel();
    super.dispose();
  }







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Deep Linking"),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _editingController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter Text To Share",
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final PendingDynamicLinkData? data =
              await dynamicLinks.getInitialLink();
              final Uri? deepLink = data?.link;

              if (deepLink != null) {
                // ignore: unawaited_futures
                Navigator.pushNamed(context, deepLink.path);
              }
            },
            child: const Text('getInitialLink'),
          ),
          ElevatedButton(
            onPressed: () async {
              final PendingDynamicLinkData? data =
              await dynamicLinks
                  .getDynamicLink(Uri.parse(Link));
              final Uri? deepLink = data?.link;

              if (deepLink != null) {
                // ignore: unawaited_futures
                Navigator.pushNamed(context, deepLink.path);
              }
            },
            child: const Text('getDynamicLink'),
          ),
          ElevatedButton(
            onPressed: !_isCreatingLink
                ? () => _createDynamicLink(false)
                : null,
            child: const Text('Get Long Link'),
          ),
          ElevatedButton(
            onPressed: !_isCreatingLink
                ? () {
              _createDynamicLink(true);

            }
                : null,
            child: const Text('Get Short Link'),
          ),

        ],
      ),



    );
  }
}

class _DynamicLinkScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hello World DeepLink'),
        ),
        body: const Center(
          child: Text('Hello, World!'),
        ),
      ),
    );
  }}