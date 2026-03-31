import 'package:flutter/material.dart';

/// Placeholder row resembling an order card (used in My Orders loading state).
class OrderCardSkeletonWidget extends StatelessWidget {
  const OrderCardSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LoadingSkeletonWidget(width: 72, height: 72, borderRadius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LoadingSkeletonWidget(
                  width: MediaQuery.sizeOf(context).width * 0.5,
                  height: 14,
                  borderRadius: 4,
                ),
                const SizedBox(height: 8),
                const LoadingSkeletonWidget(width: 120, height: 12, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingSkeletonWidget extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const LoadingSkeletonWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<LoadingSkeletonWidget> createState() => _LoadingSkeletonWidgetState();
}

class _LoadingSkeletonWidgetState extends State<LoadingSkeletonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _shimmer = Tween<double>(
      begin: -0.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            colors: [base, base.withAlpha(102), base],
            stops: [
              (_shimmer.value - 0.3).clamp(0.0, 1.0),
              _shimmer.value.clamp(0.0, 1.0),
              (_shimmer.value + 0.3).clamp(0.0, 1.0),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }
}
