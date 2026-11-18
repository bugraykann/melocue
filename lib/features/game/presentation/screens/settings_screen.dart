import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:melocue/core/utils/context_extensions.dart';
import 'package:melocue/features/game/presentation/widgets/melocue_app_bar.dart';
import 'package:melocue/features/game/data/datasources/local_storage_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:melocue/core/network/spotify_api_service.dart';
import 'package:dio/dio.dart';
import 'package:melocue/core/services/location_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = '${info.version} (${info.buildNumber})';
      });
    } catch (_) {
      // Ignore if not available
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF181820),
        title: Text(
          context.l10n.resetAllDataTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          context.l10n.resetAllDataDesc,
          style: const TextStyle(color: Color(0xFFB3B3B3)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.l10n.cancel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final storage = context.read<LocalStorageService>();
              await storage.resetAllStats();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.dataResetSuccess),
                    backgroundColor: const Color(0xFF1ED760),
                  ),
                );
              }
            },
            child: Text(
              context.l10n.reset,
              style: const TextStyle(color: Color(0xFFF3722C)),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageSheet() {
    final storage = context.read<LocalStorageService>();
    final currentLang = storage.languageCode;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151219),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.language,
                  style: context.typography.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                16.h,
                ListTile(
                  title: const Text('English', style: TextStyle(color: Colors.white)),
                  trailing: currentLang == 'en' ? const Icon(Icons.check_circle_rounded, color: Color(0xFF1ED760)) : null,
                  onTap: () {
                    storage.setLanguageCode('en');
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  title: const Text('Türkçe', style: TextStyle(color: Colors.white)),
                  trailing: currentLang == 'tr' ? const Icon(Icons.check_circle_rounded, color: Color(0xFF1ED760)) : null,
                  onTap: () {
                    storage.setLanguageCode('tr');
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getCountryName(String code) {
    const countries = {
      'US': 'Global (United States)',
      'TR': 'Türkiye',
      'GB': 'United Kingdom',
      'DE': 'Germany',
      'FR': 'France',
      'IT': 'Italy',
      'ES': 'Spain',
      'BR': 'Brazil',
      'MX': 'Mexico',
      'AR': 'Argentina',
      'CL': 'Chile',
      'CO': 'Colombia',
      'PE': 'Peru',
      'JP': 'Japan',
      'KR': 'South Korea',
      'IN': 'India',
      'ID': 'Indonesia',
      'AU': 'Australia',
      'NZ': 'New Zealand',
      'CA': 'Canada',
      'RU': 'Russia',
      'NL': 'Netherlands',
      'SE': 'Sweden',
      'NO': 'Norway',
      'DK': 'Denmark',
      'FI': 'Finland',
      'PL': 'Poland',
      'GR': 'Greece',
      'LT': 'Lithuania',
      'PT': 'Portugal',
      'ZA': 'South Africa',
      'EG': 'Egypt',
      'NG': 'Nigeria',
      'CN': 'China',
      'TW': 'Taiwan',
      'TH': 'Thailand',
      'VN': 'Vietnam',
      'MY': 'Malaysia',
      'PH': 'Philippines',
      'IE': 'Ireland',
      'CH': 'Switzerland',
      'AT': 'Austria',
      'BE': 'Belgium',
      'CZ': 'Czechia',
      'HU': 'Hungary',
      'RO': 'Romania',
      'BG': 'Bulgaria',
      'UA': 'Ukraine',
      'IL': 'Israel',
      'AE': 'United Arab Emirates',
      'SA': 'Saudi Arabia',
    };
    return countries[code] ?? code;
  }

  void _showRegionSheet() {
    final storage = context.read<LocalStorageService>();
    final locationService = context.read<LocationService>();
    final currentRegion = storage.countryCode?.toUpperCase() ?? 'US';
    final isManual = storage.isCountryManual;

    final Map<String, String> countries = {
      'US': 'Global (United States)',
      'TR': 'Türkiye',
      'GB': 'United Kingdom',
      'DE': 'Germany',
      'FR': 'France',
      'IT': 'Italy',
      'ES': 'Spain',
      'BR': 'Brazil',
      'MX': 'Mexico',
      'AR': 'Argentina',
      'CO': 'Colombia',
      'JP': 'Japan',
      'KR': 'South Korea',
      'IN': 'India',
      'AU': 'Australia',
      'CA': 'Canada',
      'NL': 'Netherlands',
      'SE': 'Sweden',
      'PL': 'Poland',
      'GR': 'Greece',
      'LT': 'Lithuania',
      'ZA': 'South Africa',
      'NG': 'Nigeria',
      'PH': 'Philippines',
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (_, scrollController) {
            return Material(
              color: const Color(0xFF1E1E28),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              clipBehavior: Clip.antiAlias,
              child: SafeArea(
                child: Column(
                  children: [
                    16.h,
                    Text(
                      'İçerik Bölgesi / Content Region',
                      style: context.typography.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    16.h,
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children: [
                          ListTile(
                            title: const Text('Otomatik / Auto', style: TextStyle(color: Colors.white)),
                            trailing: !isManual ? const Icon(Icons.check_circle_rounded, color: Color(0xFF1ED760)) : null,
                            onTap: () async {
                              await storage.saveCountryCode(currentRegion, isManual: false);
                              await locationService.determineUserCountry();
                              if (mounted) setState(() {});
                              if (ctx.mounted) Navigator.pop(ctx);
                            },
                          ),
                          const Divider(color: Colors.white24, height: 1),
                          ...countries.entries.map((entry) {
                            return ListTile(
                              title: Text(entry.value, style: const TextStyle(color: Colors.white)),
                              trailing: (isManual && currentRegion == entry.key)
                                  ? const Icon(Icons.check_circle_rounded, color: Color(0xFF1ED760))
                                  : null,
                              onTap: () async {
                                await storage.saveCountryCode(entry.key, isManual: true);
                                if (mounted) setState(() {});
                                if (ctx.mounted) Navigator.pop(ctx);
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<LocalStorageService>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0),
              child: MelocueAppBar(
                title: 'Melocue',
                subtitle: context.l10n.settingsTitle,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildSettingsGroup(
                    context,
                    title: context.l10n.preferences,
                    items: [
                      _buildSettingsTile(
                        context,
                        icon: Icons.language,
                        title: context.l10n.language,
                        subtitle: storage.languageCode == 'tr' ? 'Türkçe' : 'English',
                        onTap: _showLanguageSheet,
                      ),
                      _buildSettingsTile(
                        context,
                        icon: Icons.public_rounded,
                        title: 'Bölge / Region',
                        subtitle: !storage.isCountryManual
                            ? 'Otomatik (${storage.countryCode?.toUpperCase() ?? "US"})'
                            : _getCountryName(storage.countryCode?.toUpperCase() ?? 'US'),
                        onTap: _showRegionSheet,
                      ),
                      _buildSettingsTile(
                        context,
                        icon: Icons.notifications_active_rounded,
                        title: context.l10n.notifications,
                        trailingOverride: Switch(
                          value: storage.notificationsEnabled,
                          activeThumbColor: const Color(0xFF1ED760),
                          onChanged: (val) async {
                            await storage.setNotificationsEnabled(val);
                            setState(
                              () {},
                            ); // Using watch anyway, but just in case
                          },
                        ),
                      ),
                      _buildSettingsTile(
                        context,
                        icon: Icons.vibration_rounded,
                        title: context.l10n.haptics,
                        trailingOverride: Switch(
                          value: storage.hapticsEnabled,
                          activeThumbColor: const Color(0xFF1ED760),
                          onChanged: (val) async {
                            await storage.setHapticsEnabled(val);
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  24.h,
                  _buildSettingsGroup(
                    context,
                    title: context.l10n.dataAndPrivacy,
                    items: [
                      _buildSettingsTile(
                        context,
                        icon: Icons.delete_outline_rounded,
                        title: context.l10n.resetAllDataBtn,
                        titleColor: const Color(0xFFF3722C),
                        iconColor: const Color(0xFFF3722C),
                        onTap: _showResetDialog,
                      ),
                    ],
                  ),
                  24.h,
                  _buildSettingsGroup(
                    context,
                    title: context.l10n.connectedAccounts,
                    items: [
                      _buildSettingsTile(
                        context,
                        icon: Icons.music_note_rounded,
                        title: 'Spotify',
                        subtitle: storage.spotifyAccessToken != null
                            ? context.l10n.connected
                            : context.l10n.tapToConnect,
                        trailingOverride: storage.spotifyAccessToken != null
                            ? TextButton(
                                onPressed: () async {
                                  final service = SpotifyApiService(
                                    Dio(),
                                    storage,
                                  );
                                  await service.logout();
                                  if (mounted) setState(() {});
                                },
                                child: Text(
                                  context.l10n.logout,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                  ),
                                ),
                              )
                            : null,
                        onTap: storage.spotifyAccessToken != null
                            ? null
                            : () async {
                                final service = SpotifyApiService(
                                  Dio(),
                                  storage,
                                );
                                try {
                                  final success = await service.authenticate();
                                  if (!context.mounted) return;
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          context.l10n.spotifyConnected,
                                        ),
                                        backgroundColor: const Color(
                                          0xFF1ED760,
                                        ),
                                      ),
                                    );
                                    setState(() {});
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          context.l10n.spotifyConnectionFailed,
                                        ),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString()),
                                      backgroundColor: Colors.redAccent,
                                      duration: const Duration(seconds: 4),
                                    ),
                                  );
                                }
                              },
                      ),
                    ],
                  ),
                  24.h,
                  _buildSettingsGroup(
                    context,
                    title: context.l10n.about,
                    items: [
                      _buildSettingsTile(
                        context,
                        icon: Icons.info_outline_rounded,
                        title: context.l10n.version,
                        subtitle: _appVersion,
                      ),
                      _buildSettingsTile(
                        context,
                        icon: Icons.privacy_tip_outlined,
                        title: context.l10n.privacyPolicy,
                        onTap: () {},
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

  Widget _buildSettingsGroup(
    BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: context.typography.labelMedium?.copyWith(
              color: const Color(0xFF888888),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Material(
          color: const Color(0xFF151219),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailingOverride,
    Color? titleColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor ?? const Color(0xFF1ED760)),
      title: Text(
        title,
        style: context.typography.bodyLarge?.copyWith(
          color: titleColor ?? Colors.white,
        ),
      ),
      trailing:
          trailingOverride ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (subtitle != null) ...[
                Text(
                  subtitle,
                  style: context.typography.bodyMedium?.copyWith(
                    color: const Color(0xFF888888),
                  ),
                ),
                8.w,
              ],
              if (onTap != null)
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF888888),
                  size: 16,
                ),
            ],
          ),
    );
  }
}
