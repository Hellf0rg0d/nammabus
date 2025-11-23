import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nammabus/localization.dart';
import 'package:nammabus/trip_service.dart';

class LiveStatusTab extends StatefulWidget {
  final List<List<dynamic>> allRows;
  final List<String> locationSuggestions;

  const LiveStatusTab({
    super.key,
    required this.allRows,
    required this.locationSuggestions,
  });

  @override
  State<LiveStatusTab> createState() => _LiveStatusTabState();
}

class _LiveStatusTabState extends State<LiveStatusTab> {
  List<TripResult> _allTrips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculateLiveStatus();
  }

  void _calculateLiveStatus() {
    final now = TimeOfDay.now();
    List<TripResult> trips = [];

    for (var row in widget.allRows) {
      final result = TripService.getTripProgress(row: row, currentTime: now);
      if (result != null) {
        trips.add(result);
      }
    }

    // Sort: Active first, then Scheduled (soonest first), then Completed (recent first)
    trips.sort((a, b) {
      if (a.tripStatus.status == TripStatusEnum.ACTIVE &&
          b.tripStatus.status != TripStatusEnum.ACTIVE) return -1;
      if (a.tripStatus.status != TripStatusEnum.ACTIVE &&
          b.tripStatus.status == TripStatusEnum.ACTIVE) return 1;

      if (a.tripStatus.status == TripStatusEnum.SCHEDULED &&
          b.tripStatus.status == TripStatusEnum.SCHEDULED) {
        return a.timeInfo.time_remaining_min.compareTo(b.timeInfo.time_remaining_min);
      }
      
      if (a.tripStatus.status == TripStatusEnum.ACTIVE &&
          b.tripStatus.status == TripStatusEnum.ACTIVE) {
         return b.tripStatus.progress_percentage.compareTo(a.tripStatus.progress_percentage);
      }

      return 0;
    });

    if (mounted) {
      setState(() {
        _allTrips = trips;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _allTrips.isEmpty
            ? Center(
                child: Text(
                  "No buses found.",
                  style: GoogleFonts.publicSans(
                    fontSize: 16,
                    color: const Color(0xFF565C65),
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _allTrips.length,
                itemBuilder: (context, index) {
                  final trip = _allTrips[index];
                  return _buildLiveBusCard(trip);
                },
              );
  }

  Widget _buildLiveBusCard(TripResult trip) {
    Color statusColor = const Color(0xFF565C65); // Default Grey
    String statusText = "";
    
    switch (trip.tripStatus.status) {
      case TripStatusEnum.ACTIVE:
        statusColor = const Color(0xFF2E7D32); // Green
        statusText = Localization.getStr('status_active');
        break;
      case TripStatusEnum.SCHEDULED:
        statusColor = const Color(0xFF005EA2); // Blue
        statusText = Localization.getStr('status_scheduled');
        break;
      case TripStatusEnum.COMPLETED:
        statusColor = const Color(0xFF71767A); // Grey
        statusText = Localization.getStr('status_completed');
        break;
      case TripStatusEnum.IDLE:
        statusText = "Idle";
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Bus No & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF005EA2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trip.tripStatus.bus_id,
                  style: GoogleFonts.publicSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: statusColor.withOpacity(0.5)),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.publicSans(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Route
          Row(
            children: [
              const Icon(Icons.route, size: 16, color: Color(0xFF71767A)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  trip.tripStatus.route,
                  style: GoogleFonts.publicSans(
                      fontSize: 14, color: const Color(0xFF1B1B1B), fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar (Only for Active)
          if (trip.tripStatus.status == TripStatusEnum.ACTIVE) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: trip.tripStatus.progress_percentage / 100,
                backgroundColor: const Color(0xFFE6EFFC),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${trip.tripStatus.progress_percentage.toStringAsFixed(0)}% ${Localization.getStr('progress')}",
                  style: GoogleFonts.publicSans(fontSize: 12, color: statusColor),
                ),
                Text(
                  "${trip.timeInfo.time_remaining_min} min ${Localization.getStr('time_remaining')}",
                  style: GoogleFonts.publicSans(fontSize: 12, color: const Color(0xFF1B1B1B), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ] else if (trip.tripStatus.status == TripStatusEnum.SCHEDULED) ...[
             Text(
                  "${Localization.getStr('starts_in')} ${trip.timeInfo.time_remaining_min} min",
                  style: GoogleFonts.publicSans(fontSize: 12, color: const Color(0xFF005EA2), fontStyle: FontStyle.italic),
                ),
          ] else if (trip.tripStatus.status == TripStatusEnum.COMPLETED) ...[
             Text(
                  "${Localization.getStr('arrived_ago')} ${trip.timeInfo.time_elapsed_min - trip.tripDetails.estimated_duration_min} min ago", // Rough estimate
                  style: GoogleFonts.publicSans(fontSize: 12, color: const Color(0xFF71767A), fontStyle: FontStyle.italic),
                ),
          ],

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),

          // Times
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Localization.getStr('departure_time'),
                    style: GoogleFonts.publicSans(fontSize: 10, color: const Color(0xFF71767A)),
                  ),
                  Text(
                    trip.timeInfo.scheduled_departure,
                    style: GoogleFonts.publicSans(fontSize: 14, color: const Color(0xFF1B1B1B), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Localization.getStr('est_arrival'),
                    style: GoogleFonts.publicSans(fontSize: 10, color: const Color(0xFF71767A)),
                  ),
                  Text(
                    trip.timeInfo.estimated_arrival,
                    style: GoogleFonts.publicSans(fontSize: 14, color: const Color(0xFF1B1B1B), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
