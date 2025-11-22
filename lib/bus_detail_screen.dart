import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nammabus/localization.dart';

class BusDetailScreen extends StatelessWidget {
  final String busNo;
  final String source;
  final String destination;
  final String time;
  final String distance;
  final String nextBusTime;
  final String totalTrips;
  final String nextTripTime;
  final int heroTagIndex;

  const BusDetailScreen({
    super.key,
    required this.busNo,
    required this.source,
    required this.destination,
    required this.time,
    required this.distance,
    required this.nextBusTime,
    required this.totalTrips,
    required this.nextTripTime,
    required this.heroTagIndex,
  });

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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Color(0xFF005EA2)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              Localization.getStr('route_details'),
              style: GoogleFonts.publicSans(
                color: const Color(0xFF005EA2),
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HERO BUS NUMBER ---
                  Center(
                    child: Hero(
                      tag: 'bus_no_$heroTagIndex',
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF005EA2),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF005EA2).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: Text(
                            busNo,
                            style: GoogleFonts.publicSans(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- ROUTE CARD ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                        _buildLocationItem(
                          context,
                          icon: Icons.trip_origin,
                          color: const Color(0xFF005EA2),
                          label: Localization.getStr('starting_from'),
                          value: source,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 11), // Adjusted for center alignment
                          child: Container(
                            height: 40,
                            width: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0xFF005EA2),
                                  const Color(0xFFD32F2F).withOpacity(0.5),
                                ],
                              ),
                            ),
                          ),
                        ),
                        _buildLocationItem(
                          context,
                          icon: Icons.place,
                          color: const Color(0xFFD32F2F),
                          label: Localization.getStr('destination'),
                          value: destination,
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoColumn(Localization.getStr('distance'),
                                "$distance km"),
                            _buildInfoColumn(Localization.getStr('total_trips'),
                                totalTrips),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- SCHEDULE INFO ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                        _buildScheduleRow(
                          icon: Icons.access_time_filled,
                          label: Localization.getStr('departure_time'),
                          value: time.isEmpty
                              ? Localization.getStr('scheduled')
                              : time,
                          color: const Color(0xFF005EA2),
                        ),
                        if (nextTripTime.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildScheduleRow(
                            icon: Icons.update,
                            label: Localization.getStr('next_trip_same'),
                            value: nextTripTime,
                            color: const Color(0xFF565C65),
                            isSecondary: true,
                          ),
                        ],
                        if (nextBusTime.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildScheduleRow(
                            icon: Icons.directions_bus,
                            label: Localization.getStr('next_bus_any'),
                            value: nextBusTime,
                            color: const Color(0xFFD32F2F),
                            isSecondary: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationItem(BuildContext context,
      {required IconData icon,
      required Color color,
      required String label,
      required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.publicSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF565C65),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.publicSans(
                  fontSize: 22, // Large text for readability
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1B1B1B),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.publicSans(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF565C65),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.publicSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1B1B1B),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isSecondary = false,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isSecondary ? 12 : 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: isSecondary ? 24 : 32),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.publicSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF565C65),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.publicSans(
                fontSize: isSecondary ? 20 : 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B1B1B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
