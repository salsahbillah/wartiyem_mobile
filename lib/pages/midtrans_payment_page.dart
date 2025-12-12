import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidtransPaymentPage extends StatefulWidget {
  final String redirectUrl;

  const MidtransPaymentPage({super.key, required this.redirectUrl});

  @override
  State<MidtransPaymentPage> createState() => _MidtransPaymentPageState();
}

class _MidtransPaymentPageState extends State<MidtransPaymentPage> {
  late WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onUrlChange: (change) {
            if (change.url == null) return;
            final url = change.url!;

            print("URL CHANGE => $url");

            // jika web Midtrans / halaman hasil redirect menampilkan tombol struk
            if (url.contains("redirect_struk") ||
                url.contains("/order/receipt") ||
                url.contains("lihat-struk")) {
              Navigator.pop(context, "open_receipt");
            }

            if (url.contains("redirect_history") ||
                url.contains("/order/history") ||
                url.contains("riwayat")) {
              Navigator.pop(context, "open_history");
            }
          },
          onNavigationRequest: (request) {
            final url = request.url;
            print("NAV REQ => $url");

            if (url.contains("/order/receipt") ||
                url.contains("lihat-struk")) {
              Navigator.pop(context, "open_receipt");
              return NavigationDecision.prevent;
            }

            if (url.contains("/order/history") ||
                url.contains("riwayat")) {
              Navigator.pop(context, "open_history");
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pembayaran")),
      body: WebViewWidget(controller: controller),
    );
  }
}
