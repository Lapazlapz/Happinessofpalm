import 'dart:io';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'camera.dart';
import 'home.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.imagePath});

  final String imagePath;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>>? _results;
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _predictImage();
  }

  Future<void> _predictImage() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      // เรียก API เพื่อทำนาย
      final prediction = await _apiService.predictPalmImage(widget.imagePath);
      
      setState(() {
        _results = prediction.toResultList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = e.toString();
      });
      
      // แสดง error dialog
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เกิดข้อผิดพลาด'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _predictImage(); // ลองใหม่
            },
            child: const Text('ลองใหม่'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with gradient
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1A2332),
                    const Color(0xFF0A0E27),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'ผลการวิเคราะห์ผลปาล์ม',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Preview image with hero animation
                      Hero(
                        tag: 'palmImage',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.shade900.withOpacity(0.3),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.green.shade700.withOpacity(0.3),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Image.file(
                                File(widget.imagePath),
                                width: double.infinity,
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Results section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF1A2332),
                              const Color(0xFF0F1823),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: _loading
                            ? Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade900.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: CircularProgressIndicator(
                                      color: Colors.green.shade400,
                                      strokeWidth: 3,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'กำลังวิเคราะห์ผลปาล์ม...',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'กรุณารอสักครู่',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              )
                            : _errorMessage != null
                                ? Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade900.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.error_outline,
                                          color: Colors.redAccent,
                                          size: 48,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'ไม่สามารถเชื่อมต่อได้',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        _errorMessage!,
                                        style: const TextStyle(color: Colors.white60),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green.shade600,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          onPressed: _predictImage,
                                          child: const Text(
                                            'ลองอีกครั้ง',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.green.shade400,
                                                  Colors.green.shade700,
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.analytics,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'ผลการวิเคราะห์',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      ...List.generate(
                                        _results?.length ?? 0,
                                        (index) {
                                          final r = _results![index];
                                          final isTop = index == 0;
                                          final confidence = r["confidence"] as double;

                                          return Container(
                                            margin: const EdgeInsets.only(bottom: 12),
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              gradient: isTop
                                                  ? LinearGradient(
                                                      colors: [
                                                        Colors.green.shade700.withOpacity(0.3),
                                                        Colors.green.shade900.withOpacity(0.2),
                                                      ],
                                                    )
                                                  : null,
                                              color: isTop ? null : Colors.white.withOpacity(0.05),
                                              borderRadius: BorderRadius.circular(16),
                                              border: isTop
                                                  ? Border.all(
                                                      color: Colors.green.shade400.withOpacity(0.5),
                                                      width: 2,
                                                    )
                                                  : null,
                                            ),
                                            child: Row(
                                              children: [
                                                // Rank badge
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    gradient: isTop
                                                        ? LinearGradient(
                                                            colors: [
                                                              Colors.green.shade400,
                                                              Colors.green.shade700,
                                                            ],
                                                          )
                                                        : null,
                                                    color: isTop ? null : Colors.white.withOpacity(0.1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "${index + 1}",
                                                      style: TextStyle(
                                                        color: isTop ? Colors.white : Colors.white60,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                // Label
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        r["label"],
                                                        style: TextStyle(
                                                          color: isTop ? Colors.white : Colors.white70,
                                                          fontSize: isTop ? 18 : 16,
                                                          fontWeight: isTop ? FontWeight.bold : FontWeight.w500,
                                                        ),
                                                      ),
                                                      if (isTop) ...[
                                                        const SizedBox(height: 4),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.green.shade400.withOpacity(0.2),
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          child: const Text(
                                                            '🎯 ผลที่น่าจะเป็นที่สุด',
                                                            style: TextStyle(
                                                              color: Colors.greenAccent,
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                                // Confidence
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      "${confidence.toStringAsFixed(1)}%",
                                                      style: TextStyle(
                                                        color: isTop ? Colors.greenAccent : Colors.white70,
                                                        fontSize: isTop ? 22 : 18,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Container(
                                                      width: 60,
                                                      height: 4,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(2),
                                                      ),
                                                      child: FractionallySizedBox(
                                                        alignment: Alignment.centerLeft,
                                                        widthFactor: confidence / 100,
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            gradient: LinearGradient(
                                                              colors: isTop
                                                                  ? [
                                                                      Colors.green.shade400,
                                                                      Colors.green.shade600,
                                                                    ]
                                                                  : [
                                                                      Colors.white60,
                                                                      Colors.white30,
                                                                    ],
                                                            ),
                                                            borderRadius: BorderRadius.circular(2),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                      ),
                      const SizedBox(height: 24),

                      // Bottom action buttons
                      Row(
                        children: [
                          Expanded(
                            child: _ModernButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Camera()),
                                );
                              },
                              icon: Icons.camera_alt,
                              label: 'ถ่ายใหม่',
                              isPrimary: false,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _ModernButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Homescreen()),
                                  (route) => false,
                                );
                              },
                              icon: Icons.home,
                              label: 'กลับหน้าหลัก',
                              isPrimary: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modern button widget
class _ModernButton extends StatelessWidget {
  const _ModernButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.isPrimary,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.green.shade600 : Colors.white.withOpacity(0.1),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: isPrimary ? 8 : 0,
        shadowColor: isPrimary ? Colors.green.shade900.withOpacity(0.5) : null,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
