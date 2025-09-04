import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/investment_model.dart';
import '../providers/investment_provider.dart';
import '../widgets/investment_tile.dart';
import 'add_investment_screen.dart';

class InvestmentListScreen extends ConsumerStatefulWidget {
  const InvestmentListScreen({super.key});

  @override
  ConsumerState<InvestmentListScreen> createState() => _InvestmentListScreenState();
}

class _InvestmentListScreenState extends ConsumerState<InvestmentListScreen> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final investmentsAsync = ref.watch(investmentListProvider);
    final filteredInvestments = ref.watch(filteredInvestmentsProvider);
    final filter = ref.watch(investmentFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investments'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          if (filter.searchQuery.isNotEmpty || filter.type != null || filter.status != null)
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      children: [
                        if (filter.searchQuery.isNotEmpty)
                          Chip(
                            label: Text('Search: "${filter.searchQuery}"'),
                            onDeleted: () => _clearSearch(),
                            deleteIcon: const Icon(Icons.close, size: 18),
                          ),
                        if (filter.type != null)
                          Chip(
                            label: Text('Type: ${filter.type!.displayName}'),
                            onDeleted: () => _clearTypeFilter(),
                            deleteIcon: const Icon(Icons.close, size: 18),
                          ),
                        if (filter.status != null)
                          Chip(
                            label: Text('Status: ${filter.status!.displayName}'),
                            onDeleted: () => _clearStatusFilter(),
                            deleteIcon: const Icon(Icons.close, size: 18),
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _clearAllFilters,
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),
          
          // Investment List
          Expanded(
            child: investmentsAsync.when(
              data: (investments) {
                if (filteredInvestments.isEmpty) {
                  return _buildEmptyState();
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(investmentListProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: filteredInvestments.length,
                    itemBuilder: (context, index) {
                      final investment = filteredInvestments[index];
                      return InvestmentTile(
                        investment: investment,
                        onTap: () => _navigateToDetails(investment),
                        onEdit: () => _navigateToEdit(investment),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error loading investments: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(investmentListProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAdd(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    final filter = ref.read(investmentFilterProvider);
    final hasFilters = filter.searchQuery.isNotEmpty || 
                      filter.type != null || 
                      filter.status != null;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.search_off : Icons.trending_up,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'No investments found' : 'No investments yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters 
                  ? 'Try adjusting your search or filters'
                  : 'Start tracking your investments by adding your first one',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: hasFilters ? _clearAllFilters : _navigateToAdd,
              icon: Icon(hasFilters ? Icons.clear : Icons.add),
              label: Text(hasFilters ? 'Clear Filters' : 'Add Investment'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        _searchController.text = ref.read(investmentFilterProvider).searchQuery;
        return AlertDialog(
          title: const Text('Search Investments'),
          content: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Enter investment name...',
              prefixIcon: Icon(Icons.search),
            ),
            autofocus: true,
            onSubmitted: (value) {
              _applySearch(value);
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _applySearch(_searchController.text);
                Navigator.pop(context);
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return _FilterBottomSheet(scrollController: scrollController);
          },
        );
      },
    );
  }

  void _applySearch(String query) {
    final currentFilter = ref.read(investmentFilterProvider);
    ref.read(investmentFilterProvider.notifier).state = 
        currentFilter.copyWith(searchQuery: query.trim());
  }

  void _clearSearch() {
    final currentFilter = ref.read(investmentFilterProvider);
    ref.read(investmentFilterProvider.notifier).state = 
        currentFilter.copyWith(searchQuery: '');
  }

  void _clearTypeFilter() {
    final currentFilter = ref.read(investmentFilterProvider);
    ref.read(investmentFilterProvider.notifier).state = 
        currentFilter.copyWith(type: null);
  }

  void _clearStatusFilter() {
    final currentFilter = ref.read(investmentFilterProvider);
    ref.read(investmentFilterProvider.notifier).state = 
        currentFilter.copyWith(status: null);
  }

  void _clearAllFilters() {
    ref.read(investmentFilterProvider.notifier).state = InvestmentFilter();
  }

  void _navigateToAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddInvestmentScreen()),
    );
  }

  void _navigateToEdit(Investment investment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddInvestmentScreen(existingInvestment: investment),
      ),
    );
  }

  void _navigateToDetails(Investment investment) {
    // Navigate to investment detail screen
    // Implementation depends on your detail screen
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _FilterBottomSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;

  const _FilterBottomSheet({required this.scrollController});

  @override
  ConsumerState<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<_FilterBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(investmentFilterProvider);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            'Filter Investments',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Investment Type Filter
                  Text(
                    'Investment Type',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: filter.type == null,
                        onSelected: (selected) {
                          if (selected) {
                            ref.read(investmentFilterProvider.notifier).state = 
                                filter.copyWith(type: null);
                          }
                        },
                      ),
                      ...InvestmentType.values.map((type) {
                        return FilterChip(
                          label: Text(type.displayName),
                          selected: filter.type == type,
                          onSelected: (selected) {
                            ref.read(investmentFilterProvider.notifier).state = 
                                filter.copyWith(type: selected ? type : null);
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Status Filter
                  Text(
                    'Status',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: filter.status == null,
                        onSelected: (selected) {
                          if (selected) {
                            ref.read(investmentFilterProvider.notifier).state = 
                                filter.copyWith(status: null);
                          }
                        },
                      ),
                      ...InvestmentStatus.values.map((status) {
                        return FilterChip(
                          label: Text(status.displayName),
                          selected: filter.status == status,
                          onSelected: (selected) {
                            ref.read(investmentFilterProvider.notifier).state = 
                                filter.copyWith(status: selected ? status : null);
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Sort Options - FIXED VERSION
                  Text(
                    'Sort By',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: InvestmentSortBy.values.map((sortBy) {
                      return ListTile(
                        leading: Radio<InvestmentSortBy>(
                          value: sortBy,
                          groupValue: filter.sortBy,
                          onChanged: (value) {
                            if (value != null) {
                              ref.read(investmentFilterProvider.notifier).state = 
                                  filter.copyWith(sortBy: value);
                            }
                          },
                        ),
                        title: Text(sortBy.displayName),
                        onTap: () {
                          ref.read(investmentFilterProvider.notifier).state = 
                              filter.copyWith(sortBy: sortBy);
                        },
                      );
                    }).toList(),
                  ),
                  
                  // Sort Order
                  SwitchListTile(
                    title: const Text('Descending Order'),
                    value: filter.sortDescending,
                    onChanged: (value) {
                      ref.read(investmentFilterProvider.notifier).state = 
                          filter.copyWith(sortDescending: value);
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
