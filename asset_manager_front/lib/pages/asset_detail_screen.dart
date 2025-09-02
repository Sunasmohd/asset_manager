import 'package:asset_manager_front/pages/asset_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:asset_manager_front/models/asset.dart';
import 'package:asset_manager_front/services/api_service.dart';

class AssetDetailScreen extends StatelessWidget {
  final Asset asset;
  final ApiService apiService;
  final bool isAdmin;

  const AssetDetailScreen({
    required this.asset,
    required this.apiService,
    required this.isAdmin,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(asset.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${asset.name}'),
            Text('Type: ${asset.type}'),
            Text('Purchase Date: ${asset.purchaseDate.toIso8601String().split('T')[0]}'),
            Text('Assigned To: ${asset.assignedTo ?? 'N/A'}'),
            Text('Status: ${asset.status}'),
            if (isAdmin)
              ElevatedButton(
                onPressed: () async {
                  final updatedAsset = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AssetFormScreen(
                        apiService: apiService,
                        asset: asset,
                      ),
                    ),
                  );
                  if (updatedAsset != null) {
                    Navigator.pop(context, updatedAsset);
                  }
                },
                child: const Text('Edit'),
              ),
          ],
        ),
      ),
    );
  }
}