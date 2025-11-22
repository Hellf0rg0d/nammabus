import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:excel/excel.dart' hide Border;
import 'package:google_fonts/google_fonts.dart';
import 'package:nammabus/bus_detail_screen.dart';
import 'package:nammabus/localization.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  // --- State ---
  List<List<Data?>> _allRows = [];
  List<List<Data?>> _filteredRows = [];
  bool _isLoading = true;
  bool _isSearchPerformed = false; // To track if search has been run

  // --- Suggestions ---
  List<String> _locationSuggestions = [];


  // --- Controllers ---
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destController = TextEditingController();
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _loadExcelData();
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _destController.dispose();
    super.dispose();
  }

  String _safeVal(Data? cell) {
    if (cell == null || cell.value == null) return "";
    String val = cell.value.toString();
    if (val.toLowerCase() == 'null') return "";
    return val;
  }

  TimeOfDay? _parseTime(String timeStr) {
    try {
      // Expected format: HH:MM:SS or HH:MM
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      // debugPrint("Error parsing time: $timeStr");
    }
    return null;
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
        // Initially, no routes are shown
        _filteredRows = [];

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

  void _runFilter() {
    final sourceQuery = _sourceController.text.toLowerCase().trim();
    final destQuery = _destController.text.toLowerCase().trim();

    setState(() {
      _isSearchPerformed = true; // Mark that a search has been attempted
      _filteredRows = _allRows.where((row) {
        String sourceVal = "";
        String destVal = "";
        String timeVal = "";
        if (row.length > 3) sourceVal = _safeVal(row[3]).toLowerCase();
        if (row.length > 4) destVal = _safeVal(row[4]).toLowerCase();
        if (row.length > 6) timeVal = _safeVal(row[6]);

        final matchSource =
            sourceQuery.isEmpty || sourceVal.contains(sourceQuery);
        final matchDest = destQuery.isEmpty || destVal.contains(destQuery);

        bool matchTime = true;
        if (_selectedTime != null) {
          final busTime = _parseTime(timeVal);
          if (busTime != null) {
            final selectedMinutes =
                _selectedTime!.hour * 60 + _selectedTime!.minute;
            final busMinutes = busTime.hour * 60 + busTime.minute;
            matchTime = busMinutes >= selectedMinutes;
          } else {
            // If bus time is invalid/missing, decide whether to show it.
            // For now, let's hide it if we are strictly filtering by time.
            matchTime = false;
          }
        }

        return matchSource && matchDest && matchTime;
      }).toList();
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF005EA2),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
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
              : Column(
                  children: [
                    _buildInputSection(),
                    Expanded(
                      child: _filteredRows.isNotEmpty
                          ? ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: _filteredRows.length,
                              itemBuilder: (context, index) {
                                return _buildCivicBusCard(
                                    _filteredRows[index], index);
                              },
                            )
                          : _buildEmptyState(
                              _isSearchPerformed
                                  ? Localization.getStr('no_buses_found')
                                  : Localization.getStr('search_for_buses'),
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 4.0,
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return const Iterable<String>.empty();
                      }
                      return _locationSuggestions.where((String option) {
                        return option
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      _sourceController.text = selection;
                    },
                    fieldViewBuilder: (BuildContext context,
                        TextEditingController fieldTextEditingController,
                        FocusNode fieldFocusNode,
                        VoidCallback onFieldSubmitted) {
                      // Sync the controller
                      if (fieldTextEditingController.text !=
                          _sourceController.text) {
                        fieldTextEditingController.text =
                            _sourceController.text;
                      }
                      // Listen to changes to update our main controller
                      fieldTextEditingController.addListener(() {
                        _sourceController.text =
                            fieldTextEditingController.text;
                      });

                      return TextField(
                        controller: fieldTextEditingController,
                        focusNode: fieldFocusNode,
                        decoration: InputDecoration(
                          labelText: Localization.getStr('source'),
                          prefixIcon: const Icon(Icons.trip_origin,
                              color: Color(0xFF71767A), size: 20),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFF71767A)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  elevation: 4.0,
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return const Iterable<String>.empty();
                      }
                      return _locationSuggestions.where((String option) {
                        return option
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      _destController.text = selection;
                    },
                    fieldViewBuilder: (BuildContext context,
                        TextEditingController fieldTextEditingController,
                        FocusNode fieldFocusNode,
                        VoidCallback onFieldSubmitted) {
                      // Sync the controller
                      if (fieldTextEditingController.text !=
                          _destController.text) {
                        fieldTextEditingController.text =
                            _destController.text;
                      }
                      // Listen to changes to update our main controller
                      fieldTextEditingController.addListener(() {
                        _destController.text = fieldTextEditingController.text;
                      });

                      return TextField(
                        controller: fieldTextEditingController,
                        focusNode: fieldFocusNode,
                        decoration: InputDecoration(
                          labelText: Localization.getStr('destination'),
                          prefixIcon: const Icon(Icons.place,
                              color: Color(0xFF71767A), size: 20),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFF71767A)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: () => _selectTime(context),
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF71767A)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time,
                            color: Color(0xFF71767A), size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _selectedTime == null
                              ? Localization.getStr('select_time')
                              : _selectedTime!.format(context),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _runFilter,
                    child: Text(
                      Localization.getStr('search'),
                      style: GoogleFonts.publicSans(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader() {
    // Only show header if a search has been performed
    if (!_isSearchPerformed) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(Localization.getStr('available_schedules'),
            style: Theme.of(context).textTheme.titleMedium),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE6EFFC),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('${_filteredRows.length} ${Localization.getStr('found')}',
              style: GoogleFonts.publicSans(
                  color: const Color(0xFF005EA2),
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ),
      ],
    );
  }
  
  Widget _buildCivicBusCard(List<Data?> rowData, int index) {
    String busNo = _safeVal(rowData.length > 2 ? rowData[2] : null);
    String source = _safeVal(rowData.length > 3 ? rowData[3] : null);
    String dest = _safeVal(rowData.length > 4 ? rowData[4] : null);
    String time = _safeVal(rowData.length > 6 ? rowData[6] : null);

    return InkWell(
      onTap: () {
        // --- CALCULATE STATS ---
        String distance = "0";
        if (rowData.length > 5) {
          distance = _safeVal(rowData[5]);
        }

        // Current Time (approximate for demo, or use actual current time)
        // FIX: Use the selected bus's time as the reference point, not the system time.
        final selectedBusTime = _parseTime(time);
        final currentMinutes = selectedBusTime != null
            ? selectedBusTime.hour * 60 + selectedBusTime.minute
            : (TimeOfDay.now().hour * 60 + TimeOfDay.now().minute);

        // 1. Next Bus (Same Route, Any Bus)
        String nextBusTime = "";
        int minDiffNextBus = 9999;

        // 2. Total Trips (Same Bus No)
        int totalTrips = 0;

        // 3. Next Trip (Same Bus No)
        String nextTripTime = "";
        int minDiffNextTrip = 9999;

        for (var row in _allRows) {
          // Extract data
          String rBusNo = _safeVal(row.length > 2 ? row[2] : null);
          String rSource = _safeVal(row.length > 3 ? row[3] : null);
          String rDest = _safeVal(row.length > 4 ? row[4] : null);
          String rTimeStr = _safeVal(row.length > 6 ? row[6] : null);

          // Parse time
          final rTime = _parseTime(rTimeStr);
          if (rTime == null) continue;
          final rMinutes = rTime.hour * 60 + rTime.minute;

          // Next Bus Logic (Same Route)
          if (rSource == source && rDest == dest) {
            if (rMinutes > currentMinutes) {
              int diff = rMinutes - currentMinutes;
              if (diff < minDiffNextBus) {
                minDiffNextBus = diff;
                nextBusTime = rTimeStr;
              }
            }
          }

          // Trip Stats Logic (Same Bus No)
          if (rBusNo == busNo) {
            totalTrips++;
            if (rMinutes > currentMinutes) {
              int diff = rMinutes - currentMinutes;
              if (diff < minDiffNextTrip) {
                minDiffNextTrip = diff;
                nextTripTime = rTimeStr;
              }
            }
          }
        }

        if (nextBusTime.isEmpty) nextBusTime = Localization.getStr('no_more_buses');
        if (nextTripTime.isEmpty) nextTripTime = Localization.getStr('no_more_trips');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BusDetailScreen(
              busNo: busNo.isEmpty ? Localization.getStr('bus') : busNo,
              source: source.isEmpty ? Localization.getStr('start_point') : source,
              destination: dest.isEmpty ? Localization.getStr('end_point') : dest,
              time: time.isEmpty ? Localization.getStr('scheduled') : time,
              distance: distance,
              nextBusTime: nextBusTime,
              totalTrips: totalTrips.toString(),
              nextTripTime: nextTripTime,
              heroTagIndex: index,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE6E6E6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF005EA2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Hero(
                    tag: 'bus_no_$index',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        busNo.isEmpty ? Localization.getStr('bus') : busNo,
                        style: GoogleFonts.publicSans(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.schedule,
                        size: 16, color: Color(0xFF565C65)),
                    const SizedBox(width: 6),
                    Text(
                      time.isEmpty ? Localization.getStr('scheduled') : time,
                      style: GoogleFonts.publicSans(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1B1B1B),
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Icon(Icons.circle, size: 10, color: Color(0xFF005EA2)),
                    Container(
                        width: 2, height: 25, color: const Color(0xFFDDE1E6)),
                    const Icon(Icons.location_on,
                        size: 14, color: Color(0xFFD32F2F)),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source.isEmpty ? Localization.getStr('start_point') : source,
                        style: GoogleFonts.publicSans(
                            fontSize: 14, color: const Color(0xFF1B1B1B)),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        dest.isEmpty ? Localization.getStr('end_point') : dest,
                        style: GoogleFonts.publicSans(
                            fontSize: 14,
                            color: const Color(0xFF1B1B1B),
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 48, color: Color(0xFFC9C9C9)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.publicSans(color: const Color(0xFF565C65)),
          ),
        ],
      ),
    );
  }
}

