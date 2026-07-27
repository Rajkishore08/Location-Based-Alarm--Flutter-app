import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/models/destination.dart';
import '../../../shared/models/location_sample.dart';
import '../../../shared/models/saved_place.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../home/widgets/interactive_map_view.dart';

class MapLocationPickerModal extends ConsumerStatefulWidget {
  const MapLocationPickerModal({super.key});

  @override
  ConsumerState<MapLocationPickerModal> createState() => _MapLocationPickerModalState();
}

class _MapLocationPickerModalState extends ConsumerState<MapLocationPickerModal> {
  final TextEditingController _nameController = TextEditingController(text: 'Home');
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'home';
  LatLng _selectedLatLng = const LatLng(13.0827, 80.2707);
  bool _isSearching = false;
  List<Destination> _searchResults = [];

  final List<Map<String, dynamic>> _categories = const [
    {'id': 'home', 'label': 'Home', 'icon': Icons.home_rounded},
    {'id': 'work', 'label': 'Work', 'icon': Icons.work_rounded},
    {'id': 'college', 'label': 'College', 'icon': Icons.school_rounded},
    {'id': 'station', 'label': 'Station', 'icon': Icons.train_rounded},
    {'id': 'other', 'label': 'Other', 'icon': Icons.place_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final activeSample = ref.watch(activeJourneyProvider).currentSample;

    final LocationSample sample = activeSample ??
        LocationSample(
          latitude: _selectedLatLng.latitude,
          longitude: _selectedLatLng.longitude,
          speed: 0,
          heading: 0,
          accuracy: 5,
          timestamp: DateTime.now(),
        );

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(
        left: AppSpacing.containerMargin,
        right: AppSpacing.containerMargin,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.inverseSurface : AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
                borderRadius: AppRadius.borderFull,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Title Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select & Pin Location',
                style: AppTypography.headlineLgMobile.copyWith(
                  color: isDark ? AppColors.inverseOnSurface : AppColors.onSurface,
                  fontSize: 20,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Text(
            'Tap on the map or search to choose your Home/Custom location.',
            style: AppTypography.bodyMd.copyWith(color: AppColors.outline),
          ),

          const SizedBox(height: AppSpacing.md),

          // Search Field
          TextField(
            controller: _searchController,
            onChanged: (query) async {
              if (query.trim().isEmpty) {
                setState(() => _isSearching = false);
                return;
              }
              setState(() => _isSearching = true);
              final results = await ref.read(placesServiceProvider).searchDestinations(query);
              setState(() => _searchResults = results);
            },
            decoration: InputDecoration(
              hintText: 'Search city, station, or address...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _isSearching = false);
                      },
                    )
                  : null,
              filled: true,
              fillColor: isDark ? const Color(0xFF1E2638) : AppColors.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: AppRadius.borderXl,
                borderSide: BorderSide.none,
              ),
            ),
          ),

          if (_isSearching) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 140,
              child: ListView.separated(
                itemCount: _searchResults.length,
                separatorBuilder: (_, idx) => const Divider(height: 1),
                itemBuilder: (context, idx) {
                  final dest = _searchResults[idx];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_on_rounded, color: AppColors.primaryContainer),
                    title: Text(dest.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(dest.address),
                    onTap: () {
                      setState(() {
                        _selectedLatLng = LatLng(dest.latitude, dest.longitude);
                        _nameController.text = dest.name;
                        _addressController.text = dest.address;
                        _isSearching = false;
                      });
                    },
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.md),

          // Interactive Map Picker Container
          Expanded(
            child: ClipRRect(
              borderRadius: AppRadius.borderXl,
              child: InteractiveMapView(
                currentSample: sample,
                pickedPosition: _selectedLatLng,
                isNightMode: isDark,
                onTapPosition: (pos) {
                  setState(() {
                    _selectedLatLng = pos;
                    if (_addressController.text.isEmpty) {
                      _addressController.text =
                          'Lat: ${pos.latitude.toStringAsFixed(4)}, Lng: ${pos.longitude.toStringAsFixed(4)}';
                    }
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                final bool isSelected = _selectedCategory == cat['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: FilterChip(
                    selected: isSelected,
                    showCheckmark: false,
                    avatar: Icon(
                      cat['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.primaryContainer,
                    ),
                    label: Text(cat['label'] as String),
                    selectedColor: AppColors.primaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.onSurface),
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (val) {
                      setState(() {
                        _selectedCategory = cat['id'] as String;
                        _nameController.text = cat['label'] as String;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Place Name Input
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Place Name',
              hintText: 'e.g. Home, Office, Central Station',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Save Action Button
          AppPrimaryButton(
            text: 'Save Place to Account',
            icon: Icons.bookmark_add_rounded,
            onPressed: () async {
              if (_nameController.text.trim().isEmpty) return;

              final String placeName = _nameController.text.trim();
              final String placeAddress = _addressController.text.trim().isNotEmpty
                  ? _addressController.text.trim()
                  : '$placeName Area (${_selectedLatLng.latitude.toStringAsFixed(3)}, ${_selectedLatLng.longitude.toStringAsFixed(3)})';

              final newPlace = SavedPlace(
                id: 'sp_${DateTime.now().millisecondsSinceEpoch}',
                name: placeName,
                category: _selectedCategory,
                destination: Destination(
                  id: 'dest_${DateTime.now().millisecondsSinceEpoch}',
                  name: placeName,
                  address: placeAddress,
                  latitude: _selectedLatLng.latitude,
                  longitude: _selectedLatLng.longitude,
                  category: _selectedCategory,
                ),
                createdAt: DateTime.now(),
              );

              final nav = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              await ref.read(savedPlacesProvider.notifier).addPlace(newPlace);
              await ref.read(firestoreServiceProvider).saveUserPlace(newPlace);

              nav.pop();
              messenger.showSnackBar(
                SnackBar(content: Text('"$placeName" saved to your account successfully!')),
              );
            },
          ),
        ],
      ),
    );
  }
}
