import 'package:flutter/material.dart';

class KpiSummaryModel {
  final String title;
  final String value;
  final String trendText;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Color trendColor;

  KpiSummaryModel({
    required this.title,
    required this.value,
    required this.trendText,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.trendColor,
  });
}
