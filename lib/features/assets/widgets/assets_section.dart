import 'dart:io';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:open_file/open_file.dart';

import 'package:template/core/utils/snackbars.dart';

import '../models/asset_model.dart';
import '../providers/assets_providers.dart';

/// Determines which DB stream to use and how to add assets.
enum AssetContext { patient, treatment }

/// Drop-in section for both PatientDetailPage and treatment views.
///
/// Usage (patient):
///   AssetsSection(context: AssetContext.patient, ownerId: patient.id)
///
/// Usage (treatment):
///   AssetsSection(context: AssetContext.treatment, ownerId: treatment.id)
class AssetsSection extends ConsumerWidget {
  const AssetsSection({
    super.key,
    required this.assetContext,
    required this.ownerId,
  });

  final AssetContext assetContext;
  final int ownerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = assetContext == AssetContext.patient
        ? ref.watch(patientAssetsProvider(ownerId))
        : ref.watch(treatmentAssetsProvider(ownerId));

    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
            child: Row(
              children: [
                Icon(
                  Icons.attach_file,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'المرفقات',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Count badge
                assetsAsync.maybeWhen(
                  data: (list) => list.isEmpty
                      ? const SizedBox.shrink()
                      : Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${list.length}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  orElse: () => const SizedBox.shrink(),
                ),
                // Add button
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  tooltip: 'إضافة مرفق',
                  onPressed: () => _pickAndAdd(context, ref),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          // ── Asset list ─────────────────────────────────────
          assetsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('خطأ: $e'),
            ),
            data: (assets) {
              if (assets.isEmpty) {
                return _EmptyAssets(onAdd: () => _pickAndAdd(context, ref));
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: assets.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, indent: 60, endIndent: 12),
                itemBuilder: (_, i) => _AssetTile(
                  asset: assets[i],
                  onDelete: () => _confirmDelete(context, ref, assets[i]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndAdd(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'gif',
        'webp',
        'bmp',
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'txt',
      ],
    );

    if (result == null || result.files.isEmpty) return;

    // Show label dialog for the batch
    String? label;
    if (context.mounted) {
      label = await _showLabelDialog(context);
    }

    final notifier = ref.read(assetNotifierProvider.notifier);

    for (final picked in result.files) {
      if (picked.path == null) continue;
      final file = File(picked.path!);

      if (assetContext == AssetContext.patient) {
        await notifier.addPatientAsset(
          patientId: ownerId,
          file: file,
          label: label,
        );
      } else {
        await notifier.addTreatmentAsset(
          treatmentId: ownerId,
          file: file,
          label: label,
        );
      }
    }

    if (context.mounted) {
      AppSnackBar.success(
        result.files.length == 1
            ? 'تمت إضافة المرفق'
            : 'تمت إضافة ${result.files.length} مرفقات',
      );
    }
  }

  Future<String?> _showLabelDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تسمية المرفق (اختياري)'),
          content: TextField(
            controller: controller,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'مثال: صورة أشعة، تقرير طبي...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('تخطي'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AssetModel asset,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف المرفق'),
        content: Text('هل تريد حذف "${asset.displayName}" نهائياً؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(assetNotifierProvider.notifier).deleteAsset(asset);
    }
  }
}

// ── Empty state ───────────────────────────────────────────────────────────

class _EmptyAssets extends StatelessWidget {
  const _EmptyAssets({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 40,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 10),
          Text(
            'لا توجد مرفقات',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.attach_file, size: 16),
            label: const Text('إضافة مرفق'),
          ),
        ],
      ),
    );
  }
}

// ── Single asset tile ─────────────────────────────────────────────────────

class _AssetTile extends StatelessWidget {
  const _AssetTile({required this.asset, required this.onDelete});
  final AssetModel asset;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileType = asset.fileType;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: _AssetIcon(asset: asset),
      title: Text(
        asset.displayName,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Text(
            asset.readableSize,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: fileType.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              fileType.arabicLabel,
              style: TextStyle(
                color: fileType.color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            DateFormat('d/M/yyyy').format(asset.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outlineVariant,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Open file
          IconButton(
            icon: Icon(
              Icons.open_in_new,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            tooltip: 'فتح الملف',
            onPressed: () => _openFile(context),
          ),
          // Delete
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              size: 18,
              color: theme.colorScheme.error,
            ),
            tooltip: 'حذف',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Future<void> _openFile(BuildContext context) async {
    final file = File(asset.filePath);
    if (!await file.exists()) {
      if (context.mounted) {
        AppSnackBar.error('الملف غير موجود على الجهاز');
      }
      return;
    }
    await OpenFile.open(asset.filePath);
  }
}

// ── Asset icon (thumbnail for images, icon for others) ───────────────────

class _AssetIcon extends StatelessWidget {
  const _AssetIcon({required this.asset});
  final AssetModel asset;

  @override
  Widget build(BuildContext context) {
    final fileType = asset.fileType;

    if (fileType == AssetFileType.image) {
      final file = File(asset.filePath);
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 44,
          height: 44,
          child: file.existsSync()
              ? Image.file(file, fit: BoxFit.cover)
              : _IconBox(fileType: fileType),
        ),
      );
    }

    return _IconBox(fileType: fileType);
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.fileType});
  final AssetFileType fileType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: fileType.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fileType.color.withValues(alpha: 0.3)),
      ),
      alignment: Alignment.center,
      child: Icon(fileType.icon, size: 22, color: fileType.color),
    );
  }
}
