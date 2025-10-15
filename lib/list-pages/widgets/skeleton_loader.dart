import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader {
  static const Color _baseColor = Color(0xFFF1F5F9);
  static const Color _highlightColor = Color(0xFFFFFFFF);

  static Widget cardSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Shimmer.fromColors(
        baseColor: _baseColor,
        highlightColor: _highlightColor,
        child: Row(
          children: [
            // Icon placeholder
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _baseColor,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title line
                  Container(
                    height: 18,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _baseColor,
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description line
                  Container(
                    height: 14,
                    width: 200,
                    decoration: BoxDecoration(
                      color: _baseColor,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced skeleton for list items with modern card styling
  static Widget listItemSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Shimmer.fromColors(
          baseColor: _baseColor,
          highlightColor: _highlightColor,
          child: Row(
            children: [
              // Icon placeholder
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _baseColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              const SizedBox(width: 16),

              // Content placeholder
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title line
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _baseColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Subtitle line
                    Container(
                      height: 14,
                      width: 150,
                      decoration: BoxDecoration(
                        color: _baseColor,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow placeholder
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _baseColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget statCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: _baseColor,
        highlightColor: _highlightColor,
        child: Column(
          children: [
            // Icon placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _baseColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 12),
            // Value placeholder
            Container(
              height: 20,
              width: 40,
              decoration: BoxDecoration(
                color: _baseColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 8),
            // Label placeholder
            Container(
              height: 12,
              width: 60,
              decoration: BoxDecoration(
                color: _baseColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New: Skeleton for menu grid cards
  static Widget menuCardSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Shimmer.fromColors(
          baseColor: _baseColor,
          highlightColor: _highlightColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon placeholder
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _baseColor,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),

              const SizedBox(height: 16),

              // Title placeholder
              Container(
                height: 18,
                width: 80,
                decoration: BoxDecoration(
                  color: _baseColor,
                  borderRadius: BorderRadius.circular(9),
                ),
              ),

              const SizedBox(height: 8),

              // Description placeholder
              Container(
                height: 12,
                width: 100,
                decoration: BoxDecoration(
                  color: _baseColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              const SizedBox(height: 12),

              // Arrow placeholder
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _baseColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // New: Skeleton for product detail quick stats
  static Widget productStatSkeleton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: _baseColor,
        highlightColor: _highlightColor,
        child: Column(
          children: [
            // Icon placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _baseColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 12),
            // Value placeholder
            Container(
              height: 18,
              width: 30,
              decoration: BoxDecoration(
                color: _baseColor,
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            const SizedBox(height: 4),
            // Label placeholder
            Container(
              height: 12,
              width: 50,
              decoration: BoxDecoration(
                color: _baseColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New: Skeleton for detail card sections
  static Widget detailCardSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Shimmer.fromColors(
        baseColor: _baseColor,
        highlightColor: _highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title placeholder
            Container(
              height: 14,
              width: 120,
              decoration: BoxDecoration(
                color: _baseColor,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            const SizedBox(height: 16),
            // Info rows placeholders
            ...List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label placeholder
                    Container(
                      height: 12,
                      width: 80 + (index * 20).toDouble(),
                      decoration: BoxDecoration(
                        color: _baseColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Value placeholder
                    Container(
                      height: 14,
                      width: 150 + (index * 30).toDouble(),
                      decoration: BoxDecoration(
                        color: _baseColor,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
