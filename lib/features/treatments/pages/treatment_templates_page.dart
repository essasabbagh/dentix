import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/components/loading/loading_widget.dart';
import 'package:template/core/database/app_database.dart';
import 'package:template/core/utils/snackbars.dart';

import '../providers/treatment_templates_providers.dart';

class TreatmentTemplatesPage extends ConsumerWidget {
  const TreatmentTemplatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(treatmentTemplatesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('قوالب العلاجات المشتركة'),
      ),
      body: templatesAsync.when(
        data: (templates) {
          if (templates.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 64,
                    color: theme.colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  const Text('لا توجد قوالب مضافة حالياً'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _showTemplateDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة قالب جديد'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: templates.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final template = templates[index];
              return Card(
                child: ListTile(
                  title: Text(
                    template.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('السعر الافتراضي: ${template.defaultPrice} ₺'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showTemplateDialog(
                          context,
                          ref,
                          template: template,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _confirmDelete(context, ref, template),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, st) => Center(child: Text('خطأ: $e')),
      ),
      floatingActionButton:
          templatesAsync.hasValue && templatesAsync.value!.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showTemplateDialog(context, ref),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'قالب جديد',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  void _showTemplateDialog(
    BuildContext context,
    WidgetRef ref, {
    TreatmentTemplatesTableData? template,
  }) {
    final nameController = TextEditingController(text: template?.name);
    final priceController = TextEditingController(
      text: template?.defaultPrice.toString() ?? '0',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(template == null ? 'إضافة قالب جديد' : 'تعديل القالب'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  labelText: 'اسم العلاج',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'يرجى إدخال الاسم' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'السعر الافتراضي',
                  border: OutlineInputBorder(),
                  suffixText: '₺',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'يرجى إدخال السعر' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text) ?? 0.0;

              if (template == null) {
                await ref
                    .read(treatmentTemplateFormProvider.notifier)
                    .addTemplate(name, price);
              } else {
                await ref
                    .read(treatmentTemplateFormProvider.notifier)
                    .updateTemplate(template.id, name, price);
              }

              if (context.mounted) {
                Navigator.pop(context);
                AppSnackBar.success('تم الحفظ بنجاح');
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    TreatmentTemplatesTableData template,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف القالب'),
        content: Text('هل أنت متأكد من حذف قالب "${template.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ref
                  .read(treatmentTemplateFormProvider.notifier)
                  .deleteTemplate(template.id);
              if (context.mounted) {
                Navigator.pop(context);
                AppSnackBar.success('تم الحذف بنجاح');
              }
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
