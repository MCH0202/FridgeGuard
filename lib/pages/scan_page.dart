
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:flutter/foundation.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/scanned_product.dart';
import 'scan_edit_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  bool _isShowingManualInputDialog = false;
  final List<ScannedProduct> _scannedProducts = [];
  final PanelController _panelController = PanelController();
  late final BarcodeScanner _barcodeScanner;
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
    );

    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _cameraController.initialize();

    _cameraController.startImageStream((CameraImage image) async {
      if (_isDetecting) return;
      _isDetecting = true;

      try {
        final WriteBuffer allBytes = WriteBuffer();
        for (final plane in image.planes) {
          allBytes.putUint8List(plane.bytes);
        }
        final bytes = allBytes.done().buffer.asUint8List();

        final rotation = InputImageRotationValue.fromRawValue(
              _cameraController.description.sensorOrientation,
            ) ?? InputImageRotation.rotation0deg;

        final inputImage = InputImage.fromBytes(
          bytes: bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: InputImageFormat.nv21,
            bytesPerRow: image.planes.first.bytesPerRow,
          ),
        );

        final barcodes = await _barcodeScanner.processImage(inputImage);

        for (final barcode in barcodes) {
          final code = barcode.rawValue;
          if (code != null && !_scannedProducts.any((p) => p.barcode == code)) {
            final productName = await fetchProductName(code);
            if (productName != null) {
              setState(() {
                _scannedProducts.add(
                  ScannedProduct(barcode: code, name: productName),
                );
              });
            } else {
              _promptForManualName(code);
            }
          }
        }
      } catch (e) {
        debugPrint('Barcode scan error: $e');
      } finally {
        _isDetecting = false;
      }
    });

    if (mounted) {
      setState(() => _isCameraInitialized = true);
    }
  }

  Future<String?> fetchProductName(String barcode) async {
    try {
      final config = ProductQueryConfiguration(
        barcode,
        language: OpenFoodFactsLanguage.ENGLISH,
        fields: [ProductField.NAME],
        version: ProductQueryVersion.v3,
      );
      final result = await OpenFoodAPIClient.getProductV3(config);

      if (result.status == ProductResultV3.statusSuccess &&
          result.product?.productName != null &&
          result.product!.productName!.trim().isNotEmpty) {
        return result.product!.productName;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('[DEBUG] OpenFoodFacts error: $e');
      return null;
    }
  }

  Future<void> _promptForManualName(String barcode) async {
    if (_isShowingManualInputDialog) return;
    _isShowingManualInputDialog = true;

    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No match found'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the name to add your item.'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Name of scanned food',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );

    _isShowingManualInputDialog = false;

    if (result != null && result.isNotEmpty) {
      setState(() {
        _scannedProducts.add(ScannedProduct(barcode: barcode, name: result));
      });
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Food'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isCameraInitialized
          ? SlidingUpPanel(
              controller: _panelController,
              minHeight: 140,
              maxHeight: 500,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              backdropEnabled: true,
              parallaxEnabled: true,
              parallaxOffset: 0.2,
              panelBuilder: (sc) => _buildPanel(context, sc),
              body: Stack(
                children: [
                  Positioned.fill(child: CameraPreview(_cameraController)),
                  Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white70, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildPanel(BuildContext context, ScrollController scrollController) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _panelController.isPanelOpen
              ? _panelController.close()
              : _panelController.open(),
          child: Container(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 10),
                Text("You have ${_scannedProducts.length} item(s) ready to add"),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _scannedProducts.length,
            itemBuilder: (context, index) {
              final product = _scannedProducts[index];
              final isIncomplete = product.storage == null || product.expiryDate == null;
              return Card(
                color: isIncomplete ? Colors.red[50] : null,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: isIncomplete ? Colors.red : Colors.transparent, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Text(
                    '${product.storage ?? 'No storage'} - ${product.expiryDate?.toLocal().toString().split(' ')[0] ?? 'No expiry'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isIncomplete)
                        const Icon(Icons.warning, color: Colors.red),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ScanEditPage(product: product),
                            ),
                          );
                          if (updated is ScannedProduct) {
                            setState(() => _scannedProducts[index] = updated);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          setState(() => _scannedProducts.removeAt(index));
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.cloud_upload),
          label: const Text('Add item(s)'),
          onPressed: () async {
            final uid = FirebaseAuth.instance.currentUser?.uid;
            if (uid == null) return;

            final incomplete = _scannedProducts.any((p) => p.storage == null || p.expiryDate == null);
            if (incomplete) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please complete all fields before uploading.')),
              );
              return;
            }

            for (final product in _scannedProducts) {
              await FirebaseFirestore.instance.collection('foods').add({
                'name': product.name,
                'storage': product.storage,
                'expiry': product.expiryDate!.toIso8601String().split('T')[0],
                'expiryDate': Timestamp.fromDate(product.expiryDate!),
                'createdAt': Timestamp.now(),
                'userId': uid,
              });
            }

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All valid items uploaded!')),
              );
              Navigator.pop(context);
            }
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
