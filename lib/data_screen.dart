import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:excel/excel.dart' hide Border;
import 'package:google_fonts/google_fonts.dart';
import 'package:nammabus/localization.dart';
import 'package:nammabus/live_status_screen.dart';
import 'package:nammabus/search_tab.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  // --- State ---
  List<List<dynamic>> _allRows = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  // --- Suggestions ---
  List<String> _locationSuggestions = [];

  @override
  void initState() {
    super.initState();
    _loadExcelData();
  }

  String _safeVal(dynamic cell) {
    if (cell is Data) {
      if (cell.value == null) return "";
      String val = cell.value.toString();
      if (val.toLowerCase() == 'null') return "";
      return val;
    }
    return cell?.toString() ?? "";
  }

  Future<void> _loadExcelData() async {
    try {
      final ByteData data = await rootBundle.load('assets/FQR.xlsx');
      final bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      final excel = Excel.decodeBytes(bytes);

      final allRows = excel.tables[excel.tables.keys.first]?.rows ?? [];

      if (allRows.isNotEmpty) {
        _allRows = allRows.skip(1).toList();

        // --- Populate Suggestions ---
        final Set<String> locations = {};
        for (var row in _allRows) {
          if (row.length > 3) locations.add(_safeVal(row[3])); // Source
          if (row.length > 4) locations.add(_safeVal(row[4])); // Destination
        }
        _locationSuggestions = locations.toList();
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error loading Excel: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: Localization.appLanguageNotifier,
      builder: (context, language, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF0F4F8),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 800),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Text(
                'NAMMA BUS',
                style: GoogleFonts.publicSans(
                  color: const Color(0xFF005EA2),
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            centerTitle: false,
            actions: [
              TextButton(
                onPressed: () {
                  Localization.toggleLanguage();
                },
                child: Text(
                  Localization.getLanguageName(),
                  style: GoogleFonts.publicSans(
                    color: const Color(0xFF005EA2),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : IndexedStack(
                  index: _currentIndex,
                  children: [
                    SearchTab(
                      allRows: _allRows,
                      locationSuggestions: _locationSuggestions,
                    ),
                    LiveStatusTab(
                      allRows: _allRows,
                      locationSuggestions: _locationSuggestions,
                    ),
                  ],
                ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            selectedItemColor: const Color(0xFF005EA2),
            unselectedItemColor: const Color(0xFF71767A),
            backgroundColor: Colors.white,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.search),
                label: Localization.getStr('home'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.timelapse),
                label: Localization.getStr('live_status'),
              ),
            ],
          ),
        );
      },
    );
  }
}
