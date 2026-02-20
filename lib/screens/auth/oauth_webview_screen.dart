import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OAuthWebViewScreen extends StatefulWidget {
  final String url;

  const OAuthWebViewScreen({
    super.key,
    required this.url,
  });

  @override
  State<OAuthWebViewScreen> createState() => _OAuthWebViewScreenState();
}

class _OAuthWebViewScreenState extends State<OAuthWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('🔵 Page started: $url');
            _checkForCallback(url);
          },
          onPageFinished: (String url) {
            print('🔵 Page finished: $url');
            setState(() => _isLoading = false);
            _checkForCallback(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            print('🔵 Navigation request: ${request.url}');
            _checkForCallback(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _checkForCallback(String url) {
    // Check if URL contains access_token
    if (url.contains('access_token=') || url.contains('#access_token=')) {
      print('✅ OAuth callback detected!');

      // Close the WebView and return the URL
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pop(context, url);
        }
      });
    }

    // Also check for error
    if (url.contains('error=')) {
      print('❌ OAuth error detected');
      Navigator.pop(context, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        title: Text(
          'Sign in with Google',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFFE91E63),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading Google Sign-In...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
