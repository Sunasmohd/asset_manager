import 'package:asset_manager_front/pages/asset_detail_screen.dart';
import 'package:asset_manager_front/pages/asset_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:asset_manager_front/models/asset.dart';
import 'package:asset_manager_front/models/user.dart';
import 'package:asset_manager_front/services/api_service.dart';

class AssetListScreen extends StatefulWidget {
  final ApiService apiService;

  const AssetListScreen({required this.apiService, super.key});

  @override
  State<AssetListScreen> createState() => _AssetListScreenState();
}

class _AssetListScreenState extends State<AssetListScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Asset> assets = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  final int pageSize = 10;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    fetchAssets();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
          !isLoading &&
          hasMore) {
        fetchAssets();
      }
    });
  }

  Future<void> _loadUserRole() async {
    final role = await User.getRole();
    setState(() {
      userRole = role;
    });
  }

  Future<void> fetchAssets({String? status, int? pageNumber}) async {
    setState(() => isLoading = true);

    try {
      final result = await widget.apiService.getAllAssets(
        pageNumber: currentPage,
        status: status,
      );
      final List<Asset> newAssets = List<Asset>.from(result['data']);
      final int totalRecords = result['totalRecords'];

      setState(() {
        assets.addAll(newAssets);
        currentPage++;
        hasMore = assets.length < totalRecords;
      });
    } catch (e) {
      print('Error fetching assets: $e');
    }

    setState(() => isLoading = false);
  }

  Future<void> refreshAssets() async {
    setState(() {
      assets.clear();
      currentPage = 1;
      hasMore = true;
    });
    await fetchAssets();
  }

  Future<void> _logout() async {
    await User.clearAuthData();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Assets'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: assets.isEmpty && isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    final selectedStatus = await showModalBottomSheet<String>(
                      context: context,
                      builder: (context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: const Text("Available"),
                              onTap: () => Navigator.pop(context, "Available"),
                            ),
                            ListTile(
                              title: const Text("Retired"),
                              onTap: () => Navigator.pop(context, "Retired"),
                            ),
                            ListTile(
                              title: const Text("InUse"),
                              onTap: () => Navigator.pop(context, "InUse"),
                            ),
                          ],
                        );
                      },
                    );

                    setState(() {
                      assets.clear();
                      currentPage = 1;
                      hasMore = true;
                    });

                    await fetchAssets(status: selectedStatus, pageNumber: 1);
                  },
                  label: const Text('status'),
                  icon: const Icon(Icons.filter_list, color: Colors.black),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: assets.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == assets.length) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final asset = assets[index];
                      return ListTile(
                        title: Text(asset.name),
                        subtitle: Text('Type: ${asset.type}, Status: ${asset.status}'),
                        onTap: () async {
                          final updatedAsset = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AssetDetailScreen(
                                asset: asset,
                                apiService: widget.apiService,
                                isAdmin: userRole == 'Admin',
                              ),
                            ),
                          );
                          if (updatedAsset != null) {
                            await refreshAssets();
                          }
                        },
                        trailing: userRole == 'Admin'
                            ? IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Confirm Delete"),
                                        content: Text('Are you sure you want to delete "${asset.name}"?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: const Text("No"),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            child: const Text("Yes"),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirm == true) {
                                    try {
                                      await widget.apiService.deleteAsset(asset.id!);
                                      setState(() {
                                        assets.removeWhere((a) => a.id == asset.id);
                                      });
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed to delete asset: $e')),
                                      );
                                    }
                                  }
                                },
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: userRole == 'Admin'
          ? FloatingActionButton(
              onPressed: () async {
                final newAsset = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssetFormScreen(apiService: widget.apiService),
                  ),
                );
                if (newAsset != null) {
                  await refreshAssets();
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}