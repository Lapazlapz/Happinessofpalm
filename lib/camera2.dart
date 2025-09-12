import 'dart:io';
import 'package:flutter/material.dart';
import 'classifier.dart';
import 'camera1.dart';
import 'home.dart';

class Camera2 extends StatefulWidget {
  const Camera2({super.key, required this.imagePath});

  final String imagePath;

  @override
  State<Camera2> createState() => _Camera2State();
}

class _Camera2State extends State<Camera2> {
  PalmClassifier? _classifier;
  List<Map<String, dynamic>>? _results;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAndClassify();
  }

  Future<void> _loadAndClassify() async {
    final classifier = PalmClassifier();
    await classifier.loadModel();
    final results = classifier.classify(File(widget.imagePath));

    setState(() {
      _classifier = classifier;
      _results = results;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'ผลการวิเคราะห์ผลปาล์ม',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Preview image
                Expanded(
                  flex: 4,
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(widget.imagePath),
                        width: 240,
                        height: 240,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // Results
                Expanded(
                  flex: 5,
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.green),
                        )
                      : ListView.builder(
                          itemCount: _results?.length ?? 0,
                          itemBuilder: (context, index) {
                            final r = _results![index];
                            final isTop = index == 0; // ตัวที่เปอร์เซ็นต์สูงสุด

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isTop ? Colors.green.withOpacity(0.2) : Colors.white10,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                leading: Text(
                                  "${index + 1}.",
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                title: Text(
                                  r["label"],
                                  style: TextStyle(
                                    color: isTop ? Colors.greenAccent : Colors.white,
                                    fontSize: 18,
                                    fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                trailing: Text(
                                  "${r["confidence"].toStringAsFixed(2)}%",
                                  style: TextStyle(
                                    color: isTop ? Colors.greenAccent : Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // Bottom buttons (Back + Confirm)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0, top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Back to Camera1
                      _RoundAction(
                        background: Colors.grey,
                        icon: Icons.arrow_back,
                        iconColor: Colors.white,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const Camera1()),
                          );
                        },
                      ),
                      const SizedBox(width: 28),
                      // Confirm -> Go to Home
                      _RoundAction(
                        background: Colors.green,
                        icon: Icons.check,
                        iconColor: Colors.white,
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const Homescreen()),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.background,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final Color background;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 32,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 28),
      ),
    );
  }
}
