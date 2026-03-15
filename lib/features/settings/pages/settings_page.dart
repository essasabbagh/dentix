// import 'package:flutter/material.dart';

// import 'package:hooks_riverpod/hooks_riverpod.dart';

// import 'package:template/components/loading/loading_widget.dart';
// import 'package:template/core/utils/snackbars.dart';

// import '../providers/settings_providers.dart';

// class SettingsPage extends ConsumerWidget {
//   const SettingsPage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final settingsAsync = ref.watch(allSettingsProvider);

//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       body: settingsAsync.when(
//         loading: LoadingWidget.new,
//         error: (e, _) => Center(child: Text('خطأ: $e')),
//         data: (settings) => _SettingsBody(initial: settings),
//       ),
//     );
//   }
// }

// class _SettingsBody extends ConsumerStatefulWidget {
//   const _SettingsBody({required this.initial});
//   final Map<String, String> initial;

//   @override
//   ConsumerState<_SettingsBody> createState() => _SettingsBodyState();
// }

// class _SettingsBodyState extends ConsumerState<_SettingsBody> {
//   late final TextEditingController _clinicName;
//   late final TextEditingController _clinicPhone;
//   late final TextEditingController _clinicAddress;
//   late final TextEditingController _currency;
//   late final TextEditingController _doctorName;
//   late String _themeMode;

//   bool _dirty = false;

//   @override
//   void initState() {
//     super.initState();
//     _clinicName = TextEditingController(
//       text: widget.initial['clinic_name'] ?? 'عيادة الأسنان',
//     );
//     _clinicPhone = TextEditingController(
//       text: widget.initial['clinic_phone'] ?? '',
//     );
//     _clinicAddress = TextEditingController(
//       text: widget.initial['clinic_address'] ?? '',
//     );
//     _currency = TextEditingController(
//       text: widget.initial['currency'] ?? '₺',
//     );
//     _doctorName = TextEditingController(
//       text: widget.initial['doctor_name'] ?? 'الدكتور',
//     );
//     _themeMode = widget.initial['theme_mode'] ?? 'light';

//     for (final c in [
//       _clinicName,
//       _clinicPhone,
//       _clinicAddress,
//       _currency,
//       _doctorName,
//     ]) {
//       c.addListener(() => setState(() => _dirty = true));
//     }
//   }

//   @override
//   void dispose() {
//     _clinicName.dispose();
//     _clinicPhone.dispose();
//     _clinicAddress.dispose();
//     _currency.dispose();
//     _doctorName.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isSaving = ref.watch(settingsNotifierProvider).isLoading;

//     ref.listen(settingsNotifierProvider, (_, next) {
//       if (next.hasError) {
//         AppSnackBar.error('خطأ: ${next.error}');
//       }
//     });

//     return CustomScrollView(
//       slivers: [
//         // ── App bar ──────────────────────────────────────────
//         SliverAppBar(
//           floating: true,
//           title: const Text('الإعدادات'),
//           actions: [
//             if (_dirty)
//               Padding(
//                 padding: const EdgeInsets.only(left: 12),
//                 child: FilledButton.icon(
//                   onPressed: isSaving ? null : _save,
//                   icon: isSaving
//                       ? const SizedBox(
//                           width: 16,
//                           height: 16,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: Colors.white,
//                           ),
//                         )
//                       : const Icon(
//                           Icons.save_outlined,
//                           size: 18,
//                           color: Colors.white,
//                         ),
//                   label: const Text(
//                     'حفظ',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),

//         SliverPadding(
//           padding: const EdgeInsets.all(20),
//           sliver: SliverList(
//             delegate: SliverChildListDelegate([
//               // ── Clinic info ───────────────────────────────
//               _SettingsSection(
//                 title: 'معلومات العيادة',
//                 icon: Icons.local_hospital_outlined,
//                 children: [
//                   _SettingsField(
//                     controller: _clinicName,
//                     label: 'اسم العيادة',
//                     icon: Icons.business_outlined,
//                   ),
//                   const SizedBox(height: 14),
//                   _SettingsField(
//                     controller: _clinicPhone,
//                     label: 'رقم الهاتف',
//                     icon: Icons.phone_outlined,
//                     keyboard: TextInputType.phone,
//                   ),
//                   const SizedBox(height: 14),
//                   _SettingsField(
//                     controller: _clinicAddress,
//                     label: 'العنوان',
//                     icon: Icons.location_on_outlined,
//                     maxLines: 2,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),

//               // ── Doctor ────────────────────────────────────
//               _SettingsSection(
//                 title: 'الطبيب',
//                 icon: Icons.medical_services_outlined,
//                 children: [
//                   _SettingsField(
//                     controller: _doctorName,
//                     label: 'اسم الطبيب',
//                     icon: Icons.person_outlined,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),

//               // ── Display ───────────────────────────────────
//               _SettingsSection(
//                 title: 'العرض',
//                 icon: Icons.palette_outlined,
//                 children: [
//                   _SettingsField(
//                     controller: _currency,
//                     label: 'رمز العملة',
//                     icon: Icons.attach_money,
//                   ),
//                   const SizedBox(height: 16),
//                   // Theme selector
//                   Text(
//                     'مظهر التطبيق',
//                     style: theme.textTheme.labelMedium?.copyWith(
//                       color: theme.colorScheme.outline,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     children: [
//                       _ThemeOption(
//                         label: 'فاتح',
//                         icon: Icons.light_mode_outlined,
//                         value: 'light',
//                         selected: _themeMode == 'light',
//                         onTap: () => setState(() {
//                           _themeMode = 'light';
//                           _dirty = true;
//                         }),
//                       ),
//                       const SizedBox(width: 10),
//                       _ThemeOption(
//                         label: 'داكن',
//                         icon: Icons.dark_mode_outlined,
//                         value: 'dark',
//                         selected: _themeMode == 'dark',
//                         onTap: () => setState(() {
//                           _themeMode = 'dark';
//                           _dirty = true;
//                         }),
//                       ),
//                       const SizedBox(width: 10),
//                       _ThemeOption(
//                         label: 'تلقائي',
//                         icon: Icons.brightness_auto_outlined,
//                         value: 'system',
//                         selected: _themeMode == 'system',
//                         onTap: () => setState(() {
//                           _themeMode = 'system';
//                           _dirty = true;
//                         }),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),

//               // ── App info ──────────────────────────────────
//               const _SettingsSection(
//                 title: 'عن التطبيق',
//                 icon: Icons.info_outline,
//                 children: [
//                   _InfoTile(label: 'الإصدار', value: '1.0.0'),
//                   _InfoTile(label: 'قاعدة البيانات', value: 'SQLite (Drift)'),
//                   _InfoTile(label: 'اللغة', value: 'العربية'),
//                   _InfoTile(label: 'النظام', value: 'Windows (Offline)'),
//                 ],
//               ),
//             ]),
//           ),
//         ),
//       ],
//     );
//   }

//   Future<void> _save() async {
//     await ref.read(settingsNotifierProvider.notifier).saveAll({
//       'clinic_name': _clinicName.text.trim(),
//       'clinic_phone': _clinicPhone.text.trim(),
//       'clinic_address': _clinicAddress.text.trim(),
//       'currency': _currency.text.trim(),
//       'doctor_name': _doctorName.text.trim(),
//       'theme_mode': _themeMode,
//     });
//     setState(() => _dirty = false);
//     if (mounted) {
//       AppSnackBar.success('تم حفظ الإعدادات');
//     }
//   }
// }

// // ── Section card ──────────────────────────────────────────────────────────

// class _SettingsSection extends StatelessWidget {
//   const _SettingsSection({
//     required this.title,
//     required this.icon,
//     required this.children,
//   });
//   final String title;
//   final IconData icon;
//   final List<Widget> children;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(14),
//         side: BorderSide(color: theme.colorScheme.outlineVariant),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(18),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, size: 18, color: theme.colorScheme.primary),
//                 const SizedBox(width: 8),
//                 Text(
//                   title,
//                   style: theme.textTheme.titleSmall?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const Divider(height: 20),
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Text field ────────────────────────────────────────────────────────────

// class _SettingsField extends StatelessWidget {
//   const _SettingsField({
//     required this.controller,
//     required this.label,
//     required this.icon,
//     this.keyboard,
//     this.maxLines = 1,
//   });
//   final TextEditingController controller;
//   final String label;
//   final IconData icon;
//   final TextInputType? keyboard;
//   final int maxLines;

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       keyboardType: keyboard,
//       maxLines: maxLines,
//       textDirection: TextDirection.rtl,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, size: 18),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 14,
//           vertical: 12,
//         ),
//       ),
//     );
//   }
// }

// // ── Theme option button ───────────────────────────────────────────────────

// class _ThemeOption extends StatelessWidget {
//   const _ThemeOption({
//     required this.label,
//     required this.icon,
//     required this.value,
//     required this.selected,
//     required this.onTap,
//   });
//   final String label;
//   final IconData icon;
//   final String value;
//   final bool selected;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 180),
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             color: selected
//                 ? theme.colorScheme.primaryContainer
//                 : Colors.transparent,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(
//               color: selected
//                   ? theme.colorScheme.primary
//                   : theme.colorScheme.outlineVariant,
//               width: selected ? 2 : 1,
//             ),
//           ),
//           child: Column(
//             children: [
//               Icon(
//                 icon,
//                 size: 22,
//                 color: selected
//                     ? theme.colorScheme.primary
//                     : theme.colorScheme.outline,
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 label,
//                 style: theme.textTheme.labelMedium?.copyWith(
//                   color: selected
//                       ? theme.colorScheme.primary
//                       : theme.colorScheme.outline,
//                   fontWeight: selected ? FontWeight.bold : FontWeight.normal,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ── Read-only info tile ───────────────────────────────────────────────────

// class _InfoTile extends StatelessWidget {
//   const _InfoTile({required this.label, required this.value});
//   final String label;
//   final String value;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Text(
//             '$label: ',
//             style: theme.textTheme.bodySmall?.copyWith(
//               color: theme.colorScheme.outline,
//             ),
//           ),
//           Text(value, style: theme.textTheme.bodyMedium),
//         ],
//       ),
//     );
//   }
// }
