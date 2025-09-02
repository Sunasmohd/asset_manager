import 'package:asset_manager_front/models/asset.dart';
import 'package:asset_manager_front/services/api_service.dart';
import 'package:flutter/material.dart';

class AssetFormScreen extends StatefulWidget {
  final ApiService apiService;
  final Asset? asset;

  const AssetFormScreen({super.key,required this.apiService, this.asset});

  @override
  State<AssetFormScreen> createState() => _AssetFormScreenState();
}

class _AssetFormScreenState extends State<AssetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String type;
  late DateTime purchaseDate;
  late String assignedTo;
  late String status;

  @override
  void initState() {
    super.initState();
    name = widget.asset?.name ?? '';
    type = widget.asset?.type ?? '';
    purchaseDate = widget.asset?.purchaseDate ?? DateTime.now();
    assignedTo = widget.asset?.assignedTo ?? '';
    status = widget.asset?.status ?? 'Available';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.asset == null ? 'Add Asset' : 'Edit Asset')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Name is required' : null,
                onChanged: (value) => name = value,
              ),
              TextFormField(
                initialValue: type,
                decoration: InputDecoration(labelText: 'Type'),
                validator: (value) => value!.isEmpty ? 'Type is required' : null,
                onChanged: (value) => type = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Purchase Date'),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: purchaseDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => purchaseDate = picked);
                },
                controller: TextEditingController(text: purchaseDate.toIso8601String().split('T')[0]),
              ),
              TextFormField(
                initialValue: assignedTo,
                validator: (value) => value!.isEmpty ? 'Assigned To is required' : null,
                decoration: InputDecoration(labelText: 'Assigned To'),
                onChanged: (value) => assignedTo = value,
              ),
              DropdownButtonFormField<String>(
                value: status,
                items: ['Available', 'InUse', 'Retired'].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (value) => setState(() => status = value!),
                decoration: InputDecoration(labelText: 'Status'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final asset = Asset(
                      id: widget.asset?.id,
                      name: name,
                      type: type,
                      purchaseDate: purchaseDate,
                      assignedTo: assignedTo,
                      status: status,
                    );
                    try {
                      if (widget.asset == null) {
                        await widget.apiService.createAsset(asset);
                      } else {
                        await widget.apiService.updateAsset(widget.asset!.id!, asset);
                      }
                      Navigator.pop(context, asset);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                },
                child: Text(widget.asset == null ? 'Add' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}