import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class FireCard extends StatelessWidget {
  const FireCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: padding, child: child),
    );
  }
}

class FireHeader extends StatelessWidget {
  const FireHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.titleMedium);
  }
}

class MetricStat extends StatelessWidget {
  const MetricStat({
    super.key,
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FireCard(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class ScoreSummaryCard extends StatelessWidget {
  const ScoreSummaryCard({super.key, required this.score, required this.zone});

  final String score;
  final String zone;

  @override
  Widget build(BuildContext context) {
    return FireCard(
      child: Column(
        children: [
          Text(
            'NPS Score',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          Text(
            score,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.primaryStrong,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Zona de $zone',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class SimpleInfoRow extends StatelessWidget {
  const SimpleInfoRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class DistributionPieChart extends StatelessWidget {
  const DistributionPieChart({
    super.key,
    required this.promoterPercent,
    required this.neutralPercent,
    required this.detractorPercent,
  });

  final double promoterPercent;
  final double neutralPercent;
  final double detractorPercent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 130,
          child: CustomPaint(
            painter: _PieChartPainter(
              values: [promoterPercent, neutralPercent, detractorPercent],
              colors: const [
                AppColors.success,
                AppColors.warning,
                AppColors.danger,
              ],
            ),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 6,
          children: [
            _LegendChip(
              color: AppColors.success,
              text: 'Promotores: ${promoterPercent.toStringAsFixed(0)}%',
            ),
            _LegendChip(
              color: AppColors.warning,
              text: 'Neutros: ${neutralPercent.toStringAsFixed(0)}%',
            ),
            _LegendChip(
              color: AppColors.danger,
              text: 'Detratores: ${detractorPercent.toStringAsFixed(0)}%',
            ),
          ],
        ),
      ],
    );
  }
}

class ScoreBarChart extends StatelessWidget {
  const ScoreBarChart({super.key, required this.distribution});

  final Map<int, int> distribution;

  @override
  Widget build(BuildContext context) {
    final maxValue = distribution.values.fold<int>(0, max);
    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: distribution.entries.map((entry) {
          final value = entry.value;
          final normalized = maxValue == 0 ? 0.0 : value / maxValue;
          final color = entry.key >= 9
              ? AppColors.success
              : entry.key >= 7
              ? AppColors.warning
              : AppColors.danger;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '$value',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 90 * normalized + 8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('${entry.key}'),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  _PieChartPainter({required this.values, required this.colors});

  final List<double> values;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (sum, value) => sum + value);
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: min(size.width, size.height) / 2.4,
    );
    final paint = Paint()..style = PaintingStyle.fill;
    var startAngle = -pi / 2;

    if (total == 0) {
      paint.color = AppColors.border;
      canvas.drawArc(rect, 0, pi * 2, true, paint);
      return;
    }

    for (var i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * pi * 2;
      paint.color = colors[i];
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }

    paint.color = Colors.white;
    canvas.drawCircle(rect.center, rect.width * 0.22, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
