import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidtransPaymentPage extends StatefulWidget {
  final String redirectUrl;

  const MidtransPaymentPage({super.key, required this.redirectUrl});

  @override
  State<MidtransPaymentPage> createState() => _MidtransPaymentPageState();
}

class _MidtransPaymentPageState extends State<MidtransPaymentPage> {
  late final WebViewController controller;
  bool _alreadyReturned = false;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url;
            debugPrint("NAV => $url");

            // ✅ DEEP LINK DARI MIDTRANS (MOBILE)
            if (url.startsWith("kedaiwartiyem://")) {
              if (_alreadyReturned) {
                return NavigationDecision.prevent;
              }
              _alreadyReturned = true;

              if (url.contains("/payment/finish")) {
                Navigator.pop(context, "open_receipt");
                return NavigationDecision.prevent;
              }

              if (url.contains("/payment/unfinish") ||
                  url.contains("/payment/error")) {
                Navigator.pop(context, "open_history");
                return NavigationDecision.prevent;
              }
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectUrl));
  }

  bool _isReceiptUrl(String url) {
    return url.contains("redirect_struk") ||
        url.contains("/order/receipt") ||
        url.contains("lihat-struk");
  }

  bool _isHistoryUrl(String url) {
    return url.contains("redirect_history") ||
        url.contains("/order/history") ||
        url.contains("riwayat");
  }

  @override
Widget build(BuildContext context) {
  return PopScope(
    canPop: false,
    onPopInvoked: (didPop) {
      if (didPop) return;
      Navigator.pop(context, "open_history");
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text("Pembayaran"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context, "open_history");
          },
        ),
      ),
      body: WebViewWidget(controller: controller),
    ),
  );
}
}
