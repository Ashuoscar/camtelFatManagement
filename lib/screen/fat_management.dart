import 'package:fatconnect/database/fat/fat.dart';
import 'package:fatconnect/database/fat/fat_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class FatManagementScreen extends StatefulWidget {
  const FatManagementScreen({super.key});

  @override
  State<FatManagementScreen> createState() => _FatManagementScreenState();
}

class _FatManagementScreenState extends State<FatManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _portController = TextEditingController();
  final _latController = TextEditingController();
  final _longController = TextEditingController();
  bool _isActive = true;
  DateTime? _lastMaintenance;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _portController.dispose();
    _latController.dispose();
    _longController.dispose();
    super.dispose();
  }

  void _showFatForm({Fat? fat}) async {
    if (fat != null) {
      _nameController.text = fat.name;
      _locationController.text = fat.location;
      _portController.text = fat.portCount.toString();
      _latController.text = fat.latitude.toString();
      _longController.text = fat.longitude.toString();
      _isActive = fat.isActive;
      _lastMaintenance = fat.lastMaintenance;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    fat == null ? 'Add FAT' : 'Edit FAT',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a location' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _portController,
                    decoration: const InputDecoration(
                      labelText: 'Port Count',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter port count' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latController,
                          decoration: const InputDecoration(
                            labelText: 'Latitude',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter latitude' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _longController,
                          decoration: const InputDecoration(
                            labelText: 'Longitude',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter longitude' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Active'),
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final newFat = Fat(
                          id: fat?.id ?? '',
                          name: _nameController.text,
                          location: _locationController.text,
                          portCount: int.parse(_portController.text),
                          lastMaintenance: _lastMaintenance ?? DateTime.now(),
                          isActive: _isActive,
                          latitude: double.parse(_latController.text),
                          longitude: double.parse(_longController.text),
                        );

                        final controller = context.read<FatController>();
                        if (newFat.id.isEmpty) {
                          await controller.createFat(newFat);
                        } else {
                          await controller.updateFat(newFat);
                        }

                        Navigator.pop(context);
                      }
                    },
                    child: Text(fat == null ? 'Create' : 'Update'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    _nameController.clear();
    _locationController.clear();
    _portController.clear();
    _latController.clear();
    _longController.clear();
    _isActive = true;
    _lastMaintenance = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('FAT Management',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showFatForm(),
          ),
        ],
      ),
      body: Consumer<FatController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          }

          if (controller.fats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lan, size: 64, color: Colors.blue[300]),
                  const SizedBox(height: 16),
                  Text('No FATs found',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Tap the + button to add a new FAT',
                      style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.fats.length,
            itemBuilder: (context, index) {
              final fat = controller.fats[index];
              return _buildFatCard(fat, context);
            },
          );
        },
      ),
    );
  }

  Widget _buildFatCard(Fat fat, BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showFatForm(fat: fat),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: fat.isActive ? Colors.green[50] : Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lan,
                  color: fat.isActive ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fat.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fat.location,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ports: ${fat.portCount}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete,
                    color: Colors.red[300]),
                onPressed: () => _showDeleteDialog(fat.id, context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(String id, BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete FAT'),
        content: const Text('Are you sure you want to delete this FAT?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<FatController>().deleteFat(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}