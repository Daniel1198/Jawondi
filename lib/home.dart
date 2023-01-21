import 'package:flutter/material.dart';
import 'package:jawondi/loading.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int loading = 0;
  bool errorPage = false;

  late WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          setState(() {
            loading = progress;
          });
        },
        onPageStarted: (String url) {
          setState(() {
            loading = 0;
          });
        },
        onPageFinished: (String url) {
          setState(() {
            loading = 100;
          });
        },
        onWebResourceError: (WebResourceError error) {
          setState(() {
            errorPage = true;
          });
        },
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://www.youtube.com/')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse('https://store.goldeninstinct-ci.com'))
        .onError((error, stackTrace) => {errorPage = true})
        .timeout(const Duration(minutes: 1), onTimeout: () {
      setState(() {
        errorPage = true;
      });
    });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        if (!errorPage) WebViewWidget(controller: controller),
        if (loading < 100) const LoadingScreen(),
        if (errorPage)
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: const AssetImage('images/no-wifi.png'),
                  width: MediaQuery.of(context).size.width * 0.5,
                ),
                const SizedBox(
                  height: 20,
                ),
                MaterialButton(
                    color: Colors.grey,
                    onPressed: () {
                      setState(() {
                        errorPage = false;
                      });
                      controller.reload();
                    },
                    child: const Text('Recharger la page'))
              ],
            ),
          )
      ],
    ));
  }
}
