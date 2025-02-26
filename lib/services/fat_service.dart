import 'package:fatconnect/database/fat/fat.dart';
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final logger = Logger();

  // Fetch all FATs
  Future<List<Fat>> getAllFats() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('fats')
          .get();

      List<Fat> fats = querySnapshot.docs
          .map((doc) => Fat.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      logger.d('Fetched all FATs: $fats');
      return fats;
    } catch (e) {
      logger.e('Error in getAllFats: $e');
      rethrow;
    }
  }

  // Get FAT by ID
  Future<Fat> getFatById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('fats')
          .doc(id)
          .get();

      if (doc.exists) {
        return Fat.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        throw Exception('FAT not found');
      }
    } catch (e) {
      logger.e('Error in getFatById: $e');
      rethrow;
    }
  }

  // Create a new FAT
  Future<void> createFat(Fat fat) async {
    try {
      await _firestore
          .collection('fats')
          .add(fat.toJson());
      logger.i('FAT created successfully');
    } catch (e) {
      logger.e('Error in createFat: $e');
      rethrow;
    }
  }

  // Update an existing FAT
  Future<void> updateFat(Fat fat) async {
    try {
      await _firestore
          .collection('fats')
          .doc(fat.id)
          .update(fat.toJson());
      logger.i('FAT updated successfully');
    } catch (e) {
      logger.e('Error in updateFat: $e');
      rethrow;
    }
  }

  // Delete a FAT
  Future<void> deleteFat(String id) async {
    try {
      await _firestore
          .collection('fats')
          .doc(id)
          .delete();
      logger.i('FAT deleted successfully');
    } catch (e) {
      logger.e('Error in deleteFat: $e');
      rethrow;
    }
  }

  // Get FATs by location
  Future<List<Fat>> getFatsByLocation(String location) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('fats')
          .where('location', isEqualTo: location)
          .get();

      List<Fat> fats = querySnapshot.docs
          .map((doc) => Fat.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      logger.d('Fetched FATs by location: $fats');
      return fats;
    } catch (e) {
      logger.e('Error in getFatsByLocation: $e');
      rethrow;
    }
  }

  // Get active FATs
  Future<List<Fat>> getActiveFats() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('fats')
          .where('isActive', isEqualTo: true)
          .get();

      List<Fat> fats = querySnapshot.docs
          .map((doc) => Fat.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      logger.d('Fetched active FATs: $fats');
      return fats;
    } catch (e) {
      logger.e('Error in getActiveFats: $e');
      rethrow;
    }
  }
}