import 'package:dio/dio.dart';

class ApiService {
  late Dio _dio;
  
  // ⚠️ เปลี่ยน URL ตามที่ตั้งค่าจริงของคุณ
  // สำหรับ Android Emulator: http://10.0.2.2:8000
  // สำหรับ iOS Simulator: http://localhost:8000
  // สำหรับเครื่องจริง: ใช้ IP ของเครื่อง server เช่น http://192.168.1.100:8000
  static const String baseUrl = "http://10.0.2.2:8000";
  
  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  /// ส่งรูปภาพไปยัง API เพื่อทำนายผลปาล์ม
  Future<PredictionResult> predictPalmImage(String imagePath) async {
    try {
      // สร้าง FormData สำหรับส่งรูปภาพ
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
      });

      // ส่ง request ไปยัง API
      final response = await _dio.post(
        '/api/predict',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        return PredictionResult.fromJson(response.data);
      } else {
        throw Exception('Failed to predict image: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. กรุณาตรวจสอบการเชื่อมต่อ');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout. เซิร์ฟเวอร์ตอบสนองช้า');
      } else if (e.response != null) {
        throw Exception('Server error: ${e.response?.statusCode}');
      } else {
        throw Exception('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้\nกรุณาตรวจสอบว่าเซิร์ฟเวอร์ทำงานอยู่');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// ดึงข้อมูลราคาปาล์มจาก API
  Future<PalmPriceResponse> getPalmPrices() async {
    try {
      final response = await _dio.get('/api/palm-prices');

      if (response.statusCode == 200) {
        return PalmPriceResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to get palm prices: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout');
      } else if (e.response != null) {
        throw Exception('Server error: ${e.response?.statusCode}');
      } else {
        throw Exception('Cannot connect to server');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// ดึงราคาผลปาล์มน้ำมัน
  Future<PalmFruitPriceData> getPalmFruitPrices() async {
    try {
      final response = await _dio.get('/api/palm-fruit-prices');
      if (response.statusCode == 200) {
        return PalmFruitPriceData.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to get palm fruit prices');
      }
    } catch (e) {
      throw Exception('Error getting palm fruit prices: $e');
    }
  }

  /// ดึงราคาน้ำมันปาล์มดิบ
  Future<PalmOilPriceData> getPalmOilPrices() async {
    try {
      final response = await _dio.get('/api/palm-oil-prices');
      if (response.statusCode == 200) {
        return PalmOilPriceData.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to get palm oil prices');
      }
    } catch (e) {
      throw Exception('Error getting palm oil prices: $e');
    }
  }

  /// ดึงข่าวสารปาล์ม
  Future<List<PalmNews>> getPalmNews() async {
    try {
      final response = await _dio.get('/api/palm-news');
      if (response.statusCode == 200) {
        final List<dynamic> newsData = response.data['data'];
        return newsData.map((item) => PalmNews.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get palm news');
      }
    } catch (e) {
      throw Exception('Error getting palm news: $e');
    }
  }

  /// ดึงข้อมูลทั้งหมดในครั้งเดียว
  Future<AllPalmData> getAllData() async {
    try {
      final response = await _dio.get('/api/all-data');
      if (response.statusCode == 200) {
        return AllPalmData.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to get all data');
      }
    } catch (e) {
      throw Exception('Error getting all data: $e');
    }
  }

  /// ตรวจสอบว่า API ทำงานอยู่หรือไม่
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('/');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

/// Model สำหรับผลการทำนาย
class PredictionResult {
  final bool success;
  final int predictedClassIndex;
  final String? predictedClass;
  final double confidence;
  final Map<String, double>? allClasses;
  final List<double>? allPredictions;

  PredictionResult({
    required this.success,
    required this.predictedClassIndex,
    this.predictedClass,
    required this.confidence,
    this.allClasses,
    this.allPredictions,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      success: json['success'] ?? true,
      predictedClassIndex: json['predicted_class_index'],
      predictedClass: json['predicted_class'],
      confidence: (json['confidence'] as num).toDouble(),
      allClasses: json['all_classes'] != null
          ? Map<String, double>.from(
              (json['all_classes'] as Map).map(
                (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
              ),
            )
          : null,
      allPredictions: json['all_predictions'] != null
          ? (json['all_predictions'] as List).map((e) => (e as num).toDouble()).toList()
          : null,
    );
  }

  /// แปลงเป็นรูปแบบที่ใช้ใน UI (เหมือนกับ classifier.dart)
  List<Map<String, dynamic>> toResultList() {
    List<Map<String, dynamic>> results = [];
    
    if (allClasses != null) {
      // ถ้ามีชื่อ class ทั้งหมด
      allClasses!.forEach((label, confidence) {
        results.add({
          "label": label,
          "confidence": confidence * 100, // แปลงเป็น %
        });
      });
    } else if (allPredictions != null) {
      // ถ้ามีแค่ค่า predictions (ใช้ index)
      List<String> defaultLabels = ["Class 0", "Class 1", "Class 2", "Class 3"];
      for (int i = 0; i < allPredictions!.length; i++) {
        results.add({
          "label": i < defaultLabels.length ? defaultLabels[i] : "Class $i",
          "confidence": allPredictions![i] * 100,
        });
      }
    }
    
    // เรียงจากมากไปน้อย
    results.sort((a, b) => (b["confidence"] as double).compareTo(a["confidence"] as double));
    
    return results;
  }
}

/// Model สำหรับราคาปาล์ม
class PalmPrice {
  final String type;
  final double price;
  final String unit;
  final String region;
  final String date;
  final String? note;

  PalmPrice({
    required this.type,
    required this.price,
    required this.unit,
    required this.region,
    required this.date,
    this.note,
  });

  factory PalmPrice.fromJson(Map<String, dynamic> json) {
    return PalmPrice(
      type: json['type'],
      price: (json['price'] as num).toDouble(),
      unit: json['unit'],
      region: json['region'],
      date: json['date'],
      note: json['note'],
    );
  }
}

/// Response สำหรับราคาปาล์ม
class PalmPriceResponse {
  final bool success;
  final List<PalmPrice> data;
  final String source;

  PalmPriceResponse({
    required this.success,
    required this.data,
    required this.source,
  });

  factory PalmPriceResponse.fromJson(Map<String, dynamic> json) {
    return PalmPriceResponse(
      success: json['success'],
      data: (json['data'] as List)
          .map((item) => PalmPrice.fromJson(item))
          .toList(),
      source: json['source'],
    );
  }

  /// ดึงราคาน้ำมันปาล์มดิบ (CPO)
  PalmPrice? getCPOPrice() {
    try {
      return data.firstWhere(
        (price) => price.type.contains('น้ำมันปาล์มดิบ') || price.type.contains('CPO'),
      );
    } catch (e) {
      return null;
    }
  }

  /// ดึงราคาผลปาล์มเฉลี่ย
  double getAveragePalmPrice() {
    final palmPrices = data.where(
      (price) => !price.type.contains('น้ำมันปาล์มดิบ') && !price.type.contains('CPO'),
    );
    
    if (palmPrices.isEmpty) return 0.0;
    
    double sum = palmPrices.fold(0, (prev, price) => prev + price.price);
    return sum / palmPrices.length;
  }
}

/// Model สำหรับราคาผลปาล์มน้ำมัน
class PalmFruitPriceData {
  final String source;
  final String type;
  final double averagePrice;
  final double minPrice;
  final double maxPrice;
  final String unit;
  final String? quality;
  final String? region;
  final String updateDate;
  final bool success;

  PalmFruitPriceData({
    required this.source,
    required this.type,
    required this.averagePrice,
    required this.minPrice,
    required this.maxPrice,
    required this.unit,
    this.quality,
    this.region,
    required this.updateDate,
    required this.success,
  });

  factory PalmFruitPriceData.fromJson(Map<String, dynamic> json) {
    return PalmFruitPriceData(
      source: json['source'] ?? '',
      type: json['type'] ?? '',
      averagePrice: (json['average_price'] as num).toDouble(),
      minPrice: (json['min_price'] as num).toDouble(),
      maxPrice: (json['max_price'] as num).toDouble(),
      unit: json['unit'] ?? '',
      quality: json['quality'],
      region: json['region'],
      updateDate: json['update_date'] ?? '',
      success: json['success'] ?? true,
    );
  }
}

/// Model สำหรับราคาน้ำมันปาล์มดิบ
class PalmOilPriceData {
  final String source;
  final String type;
  final String? grade;
  final double averagePrice;
  final double minPrice;
  final double maxPrice;
  final String unit;
  final String updateDate;
  final bool success;

  PalmOilPriceData({
    required this.source,
    required this.type,
    this.grade,
    required this.averagePrice,
    required this.minPrice,
    required this.maxPrice,
    required this.unit,
    required this.updateDate,
    required this.success,
  });

  factory PalmOilPriceData.fromJson(Map<String, dynamic> json) {
    return PalmOilPriceData(
      source: json['source'] ?? '',
      type: json['type'] ?? '',
      grade: json['grade'],
      averagePrice: (json['average_price'] as num).toDouble(),
      minPrice: (json['min_price'] as num).toDouble(),
      maxPrice: (json['max_price'] as num).toDouble(),
      unit: json['unit'] ?? '',
      updateDate: json['update_date'] ?? '',
      success: json['success'] ?? true,
    );
  }
}

/// Model สำหรับข่าวสาร
class PalmNews {
  final String title;
  final String link;
  final String? date;
  final String? description;
  final String? imageUrl;

  PalmNews({
    required this.title,
    required this.link,
    this.date,
    this.description,
    this.imageUrl,
  });

  factory PalmNews.fromJson(Map<String, dynamic> json) {
    return PalmNews(
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      date: json['date'],
      description: json['description'],
      imageUrl: json['image_url'],
    );
  }
}

/// Model สำหรับข้อมูลทั้งหมด
class AllPalmData {
  final PalmFruitPriceData palmFruitPrices;
  final PalmOilPriceData palmOilPrices;
  final List<PalmNews> news;

  AllPalmData({
    required this.palmFruitPrices,
    required this.palmOilPrices,
    required this.news,
  });

  factory AllPalmData.fromJson(Map<String, dynamic> json) {
    return AllPalmData(
      palmFruitPrices: PalmFruitPriceData.fromJson(json['palm_fruit_prices']),
      palmOilPrices: PalmOilPriceData.fromJson(json['palm_oil_prices']),
      news: (json['news'] as List)
          .map((item) => PalmNews.fromJson(item))
          .toList(),
    );
  }
}
