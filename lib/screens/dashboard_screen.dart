import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import '../services/api_client.dart';
import '../widgets/loading_indicator.dart';

// Dashboard data provider
final dashboardsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  return await apiClient.getDashboards();
});

final defaultDashboardsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  return await apiClient.getDefaultDashboards();
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDashboard = ref.watch(selectedDashboardProvider);
    final editMode = ref.watch(dashboardEditModeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: selectedDashboard == null
          ? _DashboardSelector()
          : _DashboardView(
              dashboardId: selectedDashboard,
              editMode: editMode,
            ),
    );
  }
}

class _DashboardSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboards = ref.watch(dashboardsProvider);
    final defaultDashboards = ref.watch(defaultDashboardsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Dashboards',
                style: AppTextStyles.headingLarge,
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  _showCreateDashboardDialog(context, ref);
                },
                icon: const Icon(Icons.add),
                label: const Text('New Dashboard'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Default dashboards section
          Text(
            'Default Dashboards',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: 16),
          
          defaultDashboards.when(
            loading: () => const LoadingIndicator(),
            error: (error, stack) => _ErrorWidget(error.toString()),
            data: (defaults) => _DashboardGrid(
              dashboards: defaults,
              isDefault: true,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // User dashboards section
          Text(
            'My Dashboards',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: dashboards.when(
              loading: () => const LoadingIndicator(),
              error: (error, stack) => _ErrorWidget(error.toString()),
              data: (userDashboards) => userDashboards.isEmpty
                  ? _EmptyDashboards()
                  : _DashboardGrid(
                      dashboards: userDashboards,
                      isDefault: false,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateDashboardDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _CreateDashboardDialog(),
    );
  }
}

class _DashboardGrid extends ConsumerWidget {
  final List<Map<String, dynamic>> dashboards;
  final bool isDefault;

  const _DashboardGrid({
    required this.dashboards,
    required this.isDefault,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MasonryGridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: dashboards.length,
      itemBuilder: (context, index) {
        final dashboard = dashboards[index];
        return _DashboardCard(
          dashboard: dashboard,
          isDefault: isDefault,
          onTap: () {
            ref.read(selectedDashboardProvider.notifier).state = 
                dashboard['id'] ?? dashboard['name'];
          },
        );
      },
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final Map<String, dynamic> dashboard;
  final bool isDefault;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.dashboard,
    required this.isDefault,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = dashboard['name'] ?? 'Untitled Dashboard';
    final description = dashboard['description'] ?? '';
    final widgetCount = dashboard['widgets']?.length ?? 0;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: AppTextStyles.headingSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'DEFAULT',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              
              if (description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Icon(
                    Icons.widgets,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$widgetCount widgets',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardView extends ConsumerWidget {
  final String dashboardId;
  final bool editMode;

  const _DashboardView({
    required this.dashboardId,
    required this.editMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Dashboard header
        _DashboardHeader(
          dashboardId: dashboardId,
          editMode: editMode,
        ),
        
        // Dashboard content
        Expanded(
          child: _DashboardContent(
            dashboardId: dashboardId,
            editMode: editMode,
          ),
        ),
      ],
    );
  }
}

class _DashboardHeader extends ConsumerWidget {
  final String dashboardId;
  final bool editMode;

  const _DashboardHeader({
    required this.dashboardId,
    required this.editMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              ref.read(selectedDashboardProvider.notifier).state = null;
            },
            icon: const Icon(Icons.arrow_back),
          ),
          
          const SizedBox(width: 8),
          
          Text(
            dashboardId,
            style: AppTextStyles.headingMedium,
          ),
          
          const Spacer(),
          
          if (editMode) ...[
            OutlinedButton(
              onPressed: () {
                ref.read(dashboardEditModeProvider.notifier).state = false;
              },
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                // Save dashboard changes
                ref.read(dashboardEditModeProvider.notifier).state = false;
              },
              child: const Text('Save'),
            ),
          ] else ...[
            IconButton(
              onPressed: () {
                ref.read(dashboardEditModeProvider.notifier).state = true;
              },
              icon: const Icon(Icons.edit),
              tooltip: 'Edit dashboard',
            ),
            IconButton(
              onPressed: () {
                // Refresh dashboard data
              },
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
            ),
          ],
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final String dashboardId;
  final bool editMode;

  const _DashboardContent({
    required this.dashboardId,
    required this.editMode,
  });

  @override
  Widget build(BuildContext context) {
    if (editMode) {
      return _DashboardEditor(dashboardId: dashboardId);
    }
    
    return _DashboardViewer(dashboardId: dashboardId);
  }
}

class _DashboardViewer extends StatelessWidget {
  final String dashboardId;

  const _DashboardViewer({required this.dashboardId});

  @override
  Widget build(BuildContext context) {
    // Placeholder for dashboard widgets
    return Padding(
      padding: const EdgeInsets.all(24),
      child: MasonryGridView.builder(
        gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: 6, // Mock widget count
        itemBuilder: (context, index) {
          return _MockDashboardWidget(index: index);
        },
      ),
    );
  }
}

class _DashboardEditor extends StatelessWidget {
  final String dashboardId;

  const _DashboardEditor({required this.dashboardId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.warning),
            ),
            child: Row(
              children: [
                Icon(Icons.edit, color: AppColors.warning),
                const SizedBox(width: 8),
                Text(
                  'Edit Mode: Drag widgets to rearrange, click + to add new widgets',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Expanded(
            child: Row(
              children: [
                // Widget library
                Container(
                  width: 250,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: _WidgetLibrary(),
                ),
                
                const SizedBox(width: 24),
                
                // Dashboard grid editor
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: _DashboardGridEditor(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WidgetLibrary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final widgets = [
      {'name': 'Price Card', 'icon': Icons.attach_money, 'type': 'price'},
      {'name': 'Chart Widget', 'icon': Icons.show_chart, 'type': 'chart'},
      {'name': 'News Feed', 'icon': Icons.article, 'type': 'news'},
      {'name': 'Holder Activity', 'icon': Icons.groups, 'type': 'holders'},
      {'name': 'Options Flow', 'icon': Icons.swap_horiz, 'type': 'options'},
      {'name': 'Sector Heatmap', 'icon': Icons.grid_view, 'type': 'heatmap'},
      {'name': 'Economic Indicators', 'icon': Icons.trending_up, 'type': 'economic'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Widget Library',
            style: AppTextStyles.headingSmall,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widgets.length,
            itemBuilder: (context, index) {
              final widget = widgets[index];
              return _WidgetLibraryItem(widget: widget);
            },
          ),
        ),
      ],
    );
  }
}

class _WidgetLibraryItem extends StatelessWidget {
  final Map<String, dynamic> widget;

  const _WidgetLibraryItem({required this.widget});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(widget['icon'] as IconData),
      title: Text(
        widget['name'] as String,
        style: AppTextStyles.bodyMedium,
      ),
      onTap: () {
        // Add widget to dashboard
      },
    );
  }
}

class _DashboardGridEditor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Drag widgets here to build your dashboard',
        style: AppTextStyles.bodyLarge,
      ),
    );
  }
}

class _MockDashboardWidget extends StatelessWidget {
  final int index;

  const _MockDashboardWidget({required this.index});

  @override
  Widget build(BuildContext context) {
    final widgetTypes = [
      {'title': 'AAPL Price', 'subtitle': '\$150.25 +2.5%', 'color': AppColors.positive},
      {'title': 'Market News', 'subtitle': '5 new articles', 'color': AppColors.info},
      {'title': 'SPY Chart', 'subtitle': '5D view', 'color': AppColors.textSecondary},
      {'title': 'Options Flow', 'subtitle': 'Unusual activity', 'color': AppColors.warning},
      {'title': 'Holders', 'subtitle': '3 new moves', 'color': AppColors.negative},
      {'title': 'Economic Data', 'subtitle': 'CPI: 3.2%', 'color': AppColors.info},
    ];

    final widget = widgetTypes[index % widgetTypes.length];

    return Card(
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget['title'] as String,
              style: AppTextStyles.headingSmall,
            ),
            const SizedBox(height: 8),
            Text(
              widget['subtitle'] as String,
              style: AppTextStyles.bodyMedium.copyWith(
                color: widget['color'] as Color,
              ),
            ),
            const Spacer(),
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: (widget['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  'Mock Data',
                  style: AppTextStyles.caption.copyWith(
                    color: widget['color'] as Color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDashboards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.dashboard,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'No dashboards yet',
            style: AppTextStyles.headingMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first dashboard to get started',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String error;

  const _ErrorWidget(this.error);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.negative,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load dashboards',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CreateDashboardDialog extends StatefulWidget {
  @override
  State<_CreateDashboardDialog> createState() => _CreateDashboardDialogState();
}

class _CreateDashboardDialogState extends State<_CreateDashboardDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Dashboard'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Dashboard Name',
              hintText: 'e.g., My Portfolio',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'Brief description of this dashboard',
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Create dashboard logic
            Navigator.pop(context);
          },
          child: const Text('Create'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}