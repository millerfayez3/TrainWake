import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:train_wake/core/theme/app_theme.dart';

class StationItem {
  final String nameAr;
  final String nameEn;
  final String line;
  final double lat;
  final double lng;
  final String platform;

  const StationItem({
    required this.nameAr,
    required this.nameEn,
    required this.line,
    required this.lat,
    required this.lng,
    required this.platform,
  });
}

class StationSearchScreen extends StatefulWidget {
  const StationSearchScreen({super.key});

  @override
  State<StationSearchScreen> createState() => _StationSearchScreenState();
}

class _StationSearchScreenState extends State<StationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String _query = '';

  static const List<StationItem> stations = [
    StationItem(
      nameAr: 'المنيا',
      nameEn: 'Minya Central Station',
      line: 'خط الصعيد',
      lat: 28.1099,
      lng: 30.7503,
      platform: 'رصيف 2',
    ),
    StationItem(
      nameAr: 'أسيوط',
      nameEn: 'Assiut Central Station',
      line: 'خط الصعيد',
      lat: 27.1809,
      lng: 31.1837,
      platform: 'رصيف 1',
    ),
    StationItem(
      nameAr: 'سيدي جابر - الإسكندرية',
      nameEn: 'Sidi Gaber Station',
      line: 'خط الإسكندرية',
      lat: 31.2185,
      lng: 29.9427,
      platform: 'رصيف 3',
    ),
    StationItem(
      nameAr: 'طنطا',
      nameEn: 'Tanta Junction Station',
      line: 'خط الدلتا',
      lat: 30.7865,
      lng: 31.0004,
      platform: 'رصيف 4',
    ),
    StationItem(
      nameAr: 'بني سويف',
      nameEn: 'Beni Suef Station',
      line: 'خط الصعيد',
      lat: 29.0744,
      lng: 31.0978,
      platform: 'رصيف 1',
    ),
    StationItem(
      nameAr: 'سوهاج',
      nameEn: 'Sohag Station',
      line: 'خط الصعيد',
      lat: 26.5569,
      lng: 31.6948,
      platform: 'رصيف 2',
    ),
    StationItem(
      nameAr: 'الأقصر',
      nameEn: 'Luxor Central Station',
      line: 'خط الصعيد',
      lat: 25.6989,
      lng: 32.6421,
      platform: 'رصيف 1',
    ),
    StationItem(
      nameAr: 'أسوان',
      nameEn: 'Aswan Terminal Station',
      line: 'خط الصعيد',
      lat: 24.0889,
      lng: 32.8998,
      platform: 'رصيف 1',
    ),
    StationItem(
      nameAr: 'بنها',
      nameEn: 'Banha Interchange',
      line: 'خط الإسكندرية',
      lat: 30.4660,
      lng: 31.1853,
      platform: 'رصيف 2',
    ),
    StationItem(
      nameAr: 'دمنهور',
      nameEn: 'Damanhour Station',
      line: 'خط الإسكندرية',
      lat: 31.0409,
      lng: 30.4700,
      platform: 'رصيف 2',
    ),
    StationItem(
      nameAr: 'المنصورة',
      nameEn: 'Mansoura Central Station',
      line: 'خط الدلتا',
      lat: 31.0409,
      lng: 31.3785,
      platform: 'رصيف 3',
    ),
    StationItem(
      nameAr: 'الإسماعيلية',
      nameEn: 'Ismailia Station',
      line: 'خط القناة',
      lat: 30.5965,
      lng: 32.2715,
      platform: 'رصيف 1',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary;
    final borderSubtle = isDark ? AppTheme.borderSubtleDark : AppTheme.borderSubtle;

    final filtered = stations.where((s) {
      if (_query.isNotEmpty) {
        final q = _query.toLowerCase();
        final match = s.nameAr.toLowerCase().contains(q) ||
            s.nameEn.toLowerCase().contains(q) ||
            s.line.toLowerCase().contains(q);
        if (!match) return false;
      }
      if (_selectedCategory == 'saeed' && s.line != 'خط الصعيد') return false;
      if (_selectedCategory == 'alex' && s.line != 'خط الإسكندرية') return false;
      if (_selectedCategory == 'delta' && s.line != 'خط الدلتا') return false;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'البحث عن المحطات • Station Search',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primary, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (v) => setState(() => _query = v),
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 15,
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primary, size: 22),
                    hintText: 'اكتب اسم المحطة (المنيا، طنطا، أسيوط...)...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: textSecondary.withValues(alpha: 0.7),
                    ),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: textSecondary, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // Line Categories Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  _buildCategoryPill('all', 'جميع الخطوط', isDark),
                  const SizedBox(width: 8),
                  _buildCategoryPill('saeed', 'خط الصعيد', isDark),
                  const SizedBox(width: 8),
                  _buildCategoryPill('alex', 'خط الإسكندرية', isDark),
                  const SizedBox(width: 8),
                  _buildCategoryPill('delta', 'خط الدلتا', isDark),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Results List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final station = filtered[index];
                  return Material(
                    color: cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: borderSubtle),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryFixed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.train,
                            color: AppTheme.primary, size: 22),
                      ),
                      title: Text(
                        station.nameAr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            station.nameEn,
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                station.line,
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primary,
                                ),
                              ),
                              Text(
                                ' • ${station.platform}',
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 11,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, station);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          minimumSize: const Size(0, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'تحديد',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPill(String key, String title, bool isDark) {
    final isSelected = _selectedCategory == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary
              : (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLow),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : (isDark ? AppTheme.borderSubtleDark : AppTheme.borderSubtle),
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
