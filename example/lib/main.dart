// ignore_for_file: avoid_print, use_key_in_widget_constructors

import 'package:barcode_finder/barcode_finder.dart' as bf;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qris/qris.dart';

void main() {
  runApp(const QRISDemoApp(),);
}

class QRISDemoApp extends StatelessWidget {

  const QRISDemoApp();

  @override
  Widget build(BuildContext context) {

    const defaultBorder = OutlineInputBorder();

    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        elevatedButtonTheme: const ElevatedButtonThemeData(
          style: ButtonStyle(
            iconColor: MaterialStatePropertyAll(Colors.white,),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: defaultBorder,
          focusedBorder: defaultBorder,
          enabledBorder: defaultBorder,
          errorBorder: defaultBorder,
          focusedErrorBorder: defaultBorder,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.0, vertical: 8.0,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          foregroundColor: Colors.white,
        ),
        listTileTheme: ListTileThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0,),
            side: const BorderSide(
              color: Colors.black12,
            ),
          ),
        ),
      ),
      home: const QRISDemoPage(),
    );
  }
}

class QRISDemoPage extends StatefulWidget {

  const QRISDemoPage();

  @override
  State<QRISDemoPage> createState() => _QRISDemoPageState();
}

class _QRISDemoPageState extends State<QRISDemoPage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('QRIS Scanner Demo',),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0,),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Reading Result (Raw)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.copy,),
                  onPressed: () {
                    final result = resultController.text.trim();
                    if (result.isEmpty) {
                      return;
                    }
                    Clipboard.setData(
                      ClipboardData(text: result,),
                    );
                  },
                ),
              ),
              controller: resultController,
              readOnly: true,
              maxLines: 5,
            ),
            const SizedBox(height: 24.0,),
            Expanded(
              child: Builder(
                builder: (_) {
                  final qris = _qris;
                  if (qris == null) {
                    return const Center(
                      child: Text(
                        'See scan results here',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  final map = qris.toEncodable().entries;
                  return ListView.separated(
                    separatorBuilder: (_, __,) => const SizedBox(height: 12.0,),
                    itemCount: map.length,
                    itemBuilder: (_, idx,) {
                      final entry = map.elementAt(idx,);
                      final value = '${entry.value}';
                      return ListTile(
                        leading: Text(
                          '[${entry.key}]',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        title: Text(value,),
                        trailing: IconButton(
                          onPressed: () {
                            if (value.isEmpty) {
                              return;
                            }
                            Clipboard.setData(
                              ClipboardData(text: value,),
                            );
                          },
                          icon: const Icon(Icons.copy,),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Permission.camera.request().then(
            (permission) {
              if (!permission.isGranted) {
                if (permission.isPermanentlyDenied) {
                  openAppSettings();
                }
                return;
              }
              Navigator.of(context,).push(
                MaterialPageRoute(
                  builder: (_,) => const QRISScannerPage(),
                ),
              ).then(
                (result,) {
                  if (result is QRIS) {
                    resultController.text = result.toString();
                    setState(() {
                      _qris = result;
                    });
                  }
                },
              );
            },
          );
        },
        child: const Icon(Icons.qr_code_2,),
      ),
    );
  }

  @override
  void dispose() {
    resultController.dispose();
    super.dispose();
  }

  QRIS? _qris;

  late final resultController = TextEditingController();
}

class QRISScannerPage extends StatefulWidget {

  const QRISScannerPage();

  @override
  State<QRISScannerPage> createState() => _QRISScannerPageState();
}

class _QRISScannerPageState
    extends State<QRISScannerPage>
    with WidgetsBindingObserver {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner',),
      ),
      body: Stack(
        children: [
          Center(
            child: MobileScanner(
              controller: controller,
              onDetect: onDetect,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 64.0,),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ValueListenableBuilder(
                    valueListenable: controller.torchState,
                    builder: (context, state, _,) {

                      late final Widget icon;
                      switch (state) {
                        case TorchState.off:
                          icon = const Icon(Icons.flash_on,);
                          break;
                        case TorchState.on:
                          icon = const Icon(Icons.flash_off,);
                          break;
                      }

                      return ElevatedButton(
                        onPressed: toggleFlash,
                        child: icon,
                      );
                    },
                  ),
                  ElevatedButton(
                    onPressed: readFromImage,
                    child: const Icon(Icons.image,),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  late final MobileScannerController controller = MobileScannerController(
    formats: [
      BarcodeFormat.qrCode,
    ],
  );

  void onDetect(BarcodeCapture barcodes,) {
    for (var barcode in barcodes.barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue != null) {
        try {
          final qris = QRIS(rawValue,);
          Navigator.of(context,).pop(qris,);
          break;
        } catch (_) {
          print(_);
        }
      }
    }
  }

  void toggleFlash() {
    if (controller.hasTorch) {
      controller.toggleTorch();
    }
  }

  Future<void> readFromImage() async {
    final storagePermission = await Permission.storage.request();
    if (!storagePermission.isGranted) {
      if (storagePermission.isPermanentlyDenied) {
        openAppSettings();
      }
      return;
    }
    final xFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    final filePath = xFile?.path;
    if (filePath != null) {
      final data = await bf.BarcodeFinder.scanFile(
        path: filePath,
        formats: [
          bf.BarcodeFormat.QR_CODE,
        ],
      );
      if (data != null) {
        // ignore: use_build_context_synchronously
        Navigator.of(context,).pop(
          QRIS(data,),
        );
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        controller.start();
        break;
      case AppLifecycleState.inactive:
        controller.stop();
        break;
      case AppLifecycleState.paused:
        controller.stop();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}