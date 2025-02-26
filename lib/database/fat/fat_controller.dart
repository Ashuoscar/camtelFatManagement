import 'package:fatconnect/database/fat/fat.dart';
import 'package:flutter/material.dart';

import 'fat_service.dart';

class FatController extends ChangeNotifier {
  final FatService _fatService = FatService();
  List<Fat> _fats = [];
  bool _isLoading = false;

  List<Fat> get fats => _fats;
  bool get isLoading => _isLoading;

  // Get all FATs

  Future<void> getAllFats() async {
    
    _isLoading = true;

    notifyListeners();

    try {
      _fats = await _fatService.getAllFats();
    } catch (e) {
      print('Error fetching all FATs: $e');
      // Handle error appropriately
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get FAT by ID
  Future<Fat?> getFatById(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      return await _fatService.getFatById(id);
    } catch (e) {
      print('Error fetching FAT by ID: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new FAT
  Future<void> createFat(Fat fat) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _fatService.createFat(fat);
      await getAllFats(); // Refresh the list
    } catch (e) {
      print('Error creating FAT: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing FAT
  Future<void> updateFat(Fat fat) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _fatService.updateFat(fat);
      await getAllFats(); // Refresh the list
    } catch (e) {
      print('Error updating FAT: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a FAT
  Future<void> deleteFat(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _fatService.deleteFat(id);
      await getAllFats(); // Refresh the list
    } catch (e) {
      print('Error deleting FAT: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get FATs by location
  Future<List<Fat>> getFatsByLocation(String location) async {
    _isLoading = true;
    notifyListeners();

    try {
      return await _fatService.getFatsByLocation(location);
    } catch (e) {
      print('Error fetching FATs by location: $e');
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get active FATs
  Future<List<Fat>> getActiveFats() async {
    _isLoading = true;
    notifyListeners();

    try {
      return await _fatService.getActiveFats();
    } catch (e) {
      print('Error fetching active FATs: $e');
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search FATs by name or location
  Future<List<Fat>> searchFats(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_fats.isEmpty) {
        await getAllFats();
      }
      return _fats
          .where((fat) =>
              fat.name.toLowerCase().contains(query.toLowerCase()) ||
              fat.location.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      print('Error searching FATs: $e');
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
