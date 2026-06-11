import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../utils/formatter.dart';
import 'network_img.dart';

class ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback? onTap;
  const ServiceCard({super.key, required this.service, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(aspectRatio: 16 / 9, child: NetworkImg(url: service.image, fit: BoxFit.cover)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.description ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.muted, height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        rupiah(service.price),
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                      ),
                      const Spacer(),
                      if (service.durationMinutes != null)
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 14, color: AppColors.muted),
                            const SizedBox(width: 3),
                            Text('${service.durationMinutes} mnt', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
