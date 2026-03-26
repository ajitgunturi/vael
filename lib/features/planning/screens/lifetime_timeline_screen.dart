import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/timeline_provider.dart';
import '../widgets/timeline_painter.dart';
import 'fi_calculator_screen.dart';
import 'life_profile_wizard_screen.dart';
import 'milestone_dashboard_screen.dart';

/// Horizontal scrollable lifetime timeline showing milestones, purchases,
/// and FI date across decades.
class LifetimeTimelineScreen extends ConsumerStatefulWidget {
  const LifetimeTimelineScreen({
    super.key,
    required this.familyId,
    required this.userId,
  });

  final String familyId;
  final String userId;

  @override
  ConsumerState<LifetimeTimelineScreen> createState() =>
      _LifetimeTimelineScreenState();
}

class _LifetimeTimelineScreenState
    extends ConsumerState<LifetimeTimelineScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params = (userId: widget.userId, familyId: widget.familyId);
    final nodesAsync = ref.watch(timelineNodesProvider(params));
    final currentAge = ref.watch(currentAgeProvider(params));

    return Scaffold(
      appBar: AppBar(title: const Text('Life Plan')),
      body: nodesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.xl),
            child: Text('Error: $e'),
          ),
        ),
        data: (nodes) {
          if (currentAge == null) {
            return EmptyState(
              icon: Icons.timeline,
              title: 'Set up your Life Profile to see your timeline',
              actionLabel: 'Set Up Profile',
              onAction: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LifeProfileWizardScreen(
                    userId: widget.userId,
                    familyId: widget.familyId,
                  ),
                ),
              ),
            );
          }

          final range = TimelinePainter.decadeRange(nodes, currentAge);
          final decades = ((range.maxDecade - range.minDecade) / 10).ceil();
          final screenWidth = MediaQuery.sizeOf(context).width;
          final timelineWidth = screenWidth > decades * 120.0
              ? screenWidth
              : decades * 120.0;

          // Scroll to center on current age on first build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_scrollController.hasClients) return;
            final totalYears = (range.maxDecade - range.minDecade).toDouble();
            if (totalYears <= 0) return;
            final fraction = (currentAge - range.minDecade) / totalYears;
            final targetOffset = (fraction * timelineWidth - screenWidth / 2)
                .clamp(0.0, _scrollController.position.maxScrollExtent);
            _scrollController.jumpTo(targetOffset);
          });

          final painter = TimelinePainter(
            nodes: nodes,
            currentAge: currentAge,
            brightness: Theme.of(context).brightness,
            textColor: Theme.of(context).colorScheme.onSurface,
          );

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.md),
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: GestureDetector(
                onTapDown: (details) {
                  final node = painter.hitTestNode(details.localPosition);
                  if (node != null) _onNodeTap(node);
                },
                child: SizedBox(
                  width: timelineWidth,
                  height: 200,
                  child: CustomPaint(painter: painter),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onNodeTap(TimelineNode node) {
    switch (node.type) {
      case TimelineNodeType.milestone:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => MilestoneDashboardScreen(
              familyId: widget.familyId,
              userId: widget.userId,
            ),
          ),
        );
      case TimelineNodeType.purchase:
        // Navigate to goal list filtered to purchases
        // (GoalFormScreen needs a goal ID, so we navigate to goal list)
        Navigator.of(context).pushNamed('/goals');
      case TimelineNodeType.fiDate:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => FiCalculatorScreen(
              familyId: widget.familyId,
              userId: widget.userId,
            ),
          ),
        );
    }
  }
}
