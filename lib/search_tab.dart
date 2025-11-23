import 'package:flutter/material.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:google_fonts/google_fonts.dart';
import 'package:nammabus/bus_detail_screen.dart';
import 'package:nammabus/localization.dart';

class SearchTab extends StatefulWidget {
  final List<List<dynamic>> allRows;
  final List<String> locationSuggestions;

  const SearchTab({
    super.key,
    required this.allRows,
    required this.locationSuggestions,
  });

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  // --- State ---
  List<List<dynamic>> _filteredRows = [];
  bool _isSearchPerformed = false;

  // --- Controllers ---
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destController = TextEditingController();
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _sourceController.dispose();
    _destController.dispose();
    super.dispose();
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

  TimeOfDay? _parseTime(String timeStr) {
    try {
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

  void _runFilter() {
    final sourceQuery = _sourceController.text.toLowerCase().trim();
    final destQuery = _destController.text.toLowerCase().trim();

    setState(() {
      _isSearchPerformed = true;
      _filteredRows = widget.allRows.where((row) {
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

  LinearGradient _getTimeGradient(String timeStr) {
    final time = _parseTime(timeStr);
    if (time == null) {
      return const LinearGradient(
        colors: [Color(0xFFE0E0E0), Color(0xFFBDBDBD)],
      );
    }

    final hour = time.hour;

    if (hour >= 4 && hour < 17) {
      // Morning & Afternoon: Warm Yellow/Orange
      return const LinearGradient(
        colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (hour >= 17 && hour < 20) {
      // Evening: Orangish (Deep Orange)
      return const LinearGradient(
        colors: [Color(0xFFFF8A65), Color(0xFFE64A19)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      // Night: Dark Blue/Indigo
      return const LinearGradient(
        colors: [Color(0xFF3F51B5), Color(0xFF1A237E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInputSection(),
        Expanded(
          child: _filteredRows.isNotEmpty
              ? ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _filteredRows.length,
                  itemBuilder: (context, index) {
                    return _buildCivicBusCard(_filteredRows[index], index);
                  },
                )
              : _buildEmptyState(
                  _isSearchPerformed
                      ? Localization.getStr('no_buses_found')
                      : Localization.getStr('search_for_buses'),
                ),
        ),
      ],
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
            color: Colors.black.withOpacity(0.05),
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
                      return widget.locationSuggestions.where((String option) {
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
                      if (fieldTextEditingController.text !=
                          _sourceController.text) {
                        fieldTextEditingController.text =
                            _sourceController.text;
                      }
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
                      return widget.locationSuggestions.where((String option) {
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
                      if (fieldTextEditingController.text !=
                          _destController.text) {
                        fieldTextEditingController.text =
                            _destController.text;
                      }
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005EA2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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

  Widget _buildCivicBusCard(List<dynamic> rowData, int index) {
    String busNo = _safeVal(rowData.length > 2 ? rowData[2] : null);
    String source = _safeVal(rowData.length > 3 ? rowData[3] : null);
    String dest = _safeVal(rowData.length > 4 ? rowData[4] : null);
    String time = _safeVal(rowData.length > 6 ? rowData[6] : null);

    return InkWell(
      onTap: () {
        String distance = "0";
        if (rowData.length > 5) {
          distance = _safeVal(rowData[5]);
        }

        final selectedBusTime = _parseTime(time);
        final currentMinutes = selectedBusTime != null
            ? selectedBusTime.hour * 60 + selectedBusTime.minute
            : (TimeOfDay.now().hour * 60 + TimeOfDay.now().minute);

        String nextBusTime = "";
        int minDiffNextBus = 9999;
        int totalTrips = 0;
        String nextTripTime = "";
        int minDiffNextTrip = 9999;

        for (var row in widget.allRows) {
          String rBusNo = _safeVal(row.length > 2 ? row[2] : null);
          String rSource = _safeVal(row.length > 3 ? row[3] : null);
          String rDest = _safeVal(row.length > 4 ? row[4] : null);
          String rTimeStr = _safeVal(row.length > 6 ? row[6] : null);

          final rTime = _parseTime(rTimeStr);
          if (rTime == null) continue;
          final rMinutes = rTime.hour * 60 + rTime.minute;

          if (rSource == source && rDest == dest) {
            if (rMinutes > currentMinutes) {
              int diff = rMinutes - currentMinutes;
              if (diff < minDiffNextBus) {
                minDiffNextBus = diff;
                nextBusTime = rTimeStr;
              }
            }
          }

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

        if (nextBusTime.isEmpty)
          nextBusTime = Localization.getStr('no_more_buses');
        if (nextTripTime.isEmpty)
          nextTripTime = Localization.getStr('no_more_trips');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BusDetailScreen(
              busNo: busNo.isEmpty ? Localization.getStr('bus') : busNo,
              source:
                  source.isEmpty ? Localization.getStr('start_point') : source,
              destination:
                  dest.isEmpty ? Localization.getStr('end_point') : dest,
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
              color: Colors.black.withOpacity(0.05),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: _getTimeGradient(time),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule,
                              size: 14, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            time.isEmpty
                                ? Localization.getStr('scheduled')
                                : time,
                            style: GoogleFonts.publicSans(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
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
                    const Icon(Icons.circle,
                        size: 10, color: Color(0xFF005EA2)),
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
                        source.isEmpty
                            ? Localization.getStr('start_point')
                            : source,
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
