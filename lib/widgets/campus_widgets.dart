import 'package:flutter/material.dart';
import '../models/campus_resource.dart';
import '../theme.dart';

class SectionHeading extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const SectionHeading({super.key, required this.title, this.subtitle, this.trailing});
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: navy,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: const TextStyle(color: muted, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      if (trailing != null) trailing!,
    ],
  );
}


class ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const ActionCard({super.key, required this.title, required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: color, size: 21),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: muted,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      );
}


class ResourceIcon extends StatelessWidget {
  final IconData icon;
  const ResourceIcon({super.key, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: paleTeal,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: teal, size: 24),
      );
}


class ResourceCard extends StatelessWidget {
  final CampusResource resource;
  final VoidCallback onView;
  const ResourceCard({super.key, required this.resource, required this.onView});
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(17),
    child: InkWell(
      onTap: onView,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFE8EDF2)),
        ),
        child: Row(
          children: [
            ResourceIcon(icon: resource.icon),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: muted,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          resource.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: muted, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 7,
                    runSpacing: 5,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _StatusPill(
                        label:
                            resource.available ? 'Available' : 'Unavailable',
                        color: resource.available
                            ? const Color(0xFF168566)
                            : const Color(0xFFB33A45),
                        background: resource.available
                            ? const Color(0xFFE9F7F1)
                            : const Color(0xFFFFEEEE),
                      ),
                      _StatusPill(
                        label: resource.type,
                        color: muted,
                        background: const Color(0xFFF1F4F7),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: muted, size: 22),
          ],
        ),
      ),
    ),
  );
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _StatusPill({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? action;
  const EmptyState({super.key, required this.title, required this.subtitle, this.action});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: surfaceTint,
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 27,
                color: muted,
              ),
            ),
            const SizedBox(height: 13),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: navy,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: muted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 14),
              action!,
            ],
          ],
        ),
      );
}

