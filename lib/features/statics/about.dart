import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:dentix/configs/app_configs.dart';
import 'package:dentix/core/constants/images.dart';
import 'package:dentix/core/locale/generated/l10n.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildDescriptionCard(context),
            const SizedBox(height: 24),
            _buildFeaturesCard(context),
            const SizedBox(height: 24),
            _buildDeveloperCard(context),
            // const SizedBox(height: 24),
            // _buildLinksCard(context),
            const SizedBox(height: 24),
            _buildVersionCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Image.asset(
          AppImages.imagesLogo,
          width: 64,
          height: 64,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dentix Flow',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'نظام إدارة عيادة الأسنان',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard(BuildContext context) {
    final theme = Theme.of(context);
    return _buildCard(
      context,
      icon: Icons.description_outlined,
      title: S.of(context).description,
      child: Text(
        'Dentix Flow هو نظام شامل لإدارة عيادات طب الأسنان، '
        'يساعدك في إدارة المرضى والمواعيد والعلاجات '
        'والمدفوعات بكفاءة عالية. صُمم خصيصاً للعمل '
        'باللغة العربية مع دعم كامل للاتجاه من اليمين لليسار.',
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildFeaturesCard(BuildContext context) {
    final theme = Theme.of(context);
    final features = [
      {'icon': Icons.people, 'text': 'إدارة المرضى'},
      {'icon': Icons.calendar_month, 'text': 'جدولة المواعيد'},
      {'icon': Icons.medical_services, 'text': 'سجل العلاجات'},
      {'icon': Icons.payments, 'text': 'إدارة المدفوعات'},
      {'icon': Icons.grid_view, 'text': 'الملف السني'},
      {'icon': Icons.bar_chart, 'text': 'التقارير والإحصائيات'},
    ];

    return _buildCard(
      context,
      icon: Icons.star_outline,
      title: 'المميزات',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: features.map((f) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  f['icon'] as IconData,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  f['text'] as String,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDeveloperCard(BuildContext context) {
    final theme = Theme.of(context);
    return _buildCard(
      context,
      icon: Icons.code,
      title: 'المطور',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mohammad Essa Sabbagh',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'تطوير البرمجيات والتطبيقات',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildContactButton(
                context,
                icon: Icons.language,
                label: 'الموقع',
                onTap: () => _launchUrl(
                  'https://www.linkedin.com/in/mohamad-essa-sabbagh-0371b7117',
                ),
              ),
              const SizedBox(width: 8),
              _buildContactButton(
                context,
                icon: Icons.email_outlined,
                label: 'البريد',
                onTap: () => _launchUrl('mailto:essasabbagh@gmail.com'),
              ),
              const SizedBox(width: 8),
              _buildContactButton(
                context,
                icon: Icons.phone_android,
                label: 'الهاتف',
                onTap: () => _launchUrl('tel:+905050026612'),
              ),
              // whatsapp
              const SizedBox(width: 8),
              _buildContactButton(
                context,
                icon: Icons.chat,
                label: 'واتس اب',
                onTap: () => _launchUrl('whatsapp://send?phone=+905050026612'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildLinksCard(BuildContext context) {
    return _buildCard(
      context,
      icon: Icons.link,
      title: 'روابط مهمة',
      child: Column(
        children: [
          _buildLinkTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: S.of(context).privacyPolicy,
            onTap: () => _launchUrl(AppConfigs.privacyPolicyUrl),
          ),
          const Divider(height: 1),
          _buildLinkTile(
            context,
            icon: Icons.article_outlined,
            title: S.of(context).termsConditions,
            onTap: () => _launchUrl(AppConfigs.termsOfServiceUrl),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: theme.colorScheme.outline,
      ),
      onTap: onTap,
    );
  }

  Widget _buildVersionCard(BuildContext context) {
    return _buildCard(
      context,
      icon: Icons.info_outline,
      title: 'معلومات التطبيق',
      child: Column(
        children: [
          _buildInfoRow(context, 'الإصدار', '1.0.0'),
          _buildInfoRow(context, 'قاعدة البيانات', 'SQLite (Drift)'),
          _buildInfoRow(context, 'اللغة', 'العربية / English'),
          _buildInfoRow(context, 'النظام', 'Flutter Desktop'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
