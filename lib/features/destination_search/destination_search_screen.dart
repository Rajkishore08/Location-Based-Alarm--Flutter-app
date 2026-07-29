import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../shared/models/destination.dart';
import '../../shared/models/location_sample.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/destination_card.dart';
import '../../shared/widgets/location_search_bar.dart';

class DestinationSearchScreen extends ConsumerStatefulWidget {
  const DestinationSearchScreen({super.key});

  @override
  ConsumerState<DestinationSearchScreen> createState() => _DestinationSearchScreenState();
}

class _DestinationSearchScreenState extends ConsumerState<DestinationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Destination> _searchResults = [];
  bool _isLoading = false;
  LocationSample? _userLocation;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _initLocationAndSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _initLocationAndSearch() async {
    final activeSample = ref.read(activeJourneyProvider).currentSample;
    final loc = activeSample ?? await ref.read(locationServiceProvider).getCurrentLocation();
    if (mounted) {
      setState(() => _userLocation = loc);
      _performSearch('');
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);
    final results = await ref.read(placesServiceProvider).searchDestinations(
          query,
          userLocation: _userLocation,
        );
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Destination'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm),
            LocationSearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
              hintText: 'Search city, station, airport or address...',
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _searchController.text.isEmpty ? 'POPULAR & NEARBY DESTINATIONS' : 'SEARCH RESULTS',
                  style: AppTypography.labelMd.copyWith(
                    color: isDark ? AppColors.primaryFixed : AppColors.primaryContainer,
                  ),
                ),
                if (_userLocation != null)
                  Text(
                    'Real GPS Active',
                    style: AppTypography.labelMd.copyWith(color: AppColors.success, fontSize: 11),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off_rounded, size: 48, color: AppColors.outline),
                              const SizedBox(height: 8),
                              Text(
                                'No locations found',
                                style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Try searching a different city or street name',
                                style: AppTypography.bodyMd.copyWith(color: AppColors.outline),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: _searchResults.length,
                          separatorBuilder: (_, index) => const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, idx) {
                            final dest = _searchResults[idx];
                            return DestinationCard(
                              destination: dest,
                              onTap: () {
                                context.push('/destination', extra: dest);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
