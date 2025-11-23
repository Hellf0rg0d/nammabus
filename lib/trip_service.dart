import 'package:flutter/material.dart';

enum TripStatusEnum {
  ACTIVE,
  SCHEDULED,
  COMPLETED,
  IDLE,
}

class TripStatus {
  final String bus_id;
  final String route;
  final TripStatusEnum status;
  final double progress_percentage;
  final bool? is_delayed;

  TripStatus({
    required this.bus_id,
    required this.route,
    required this.status,
    required this.progress_percentage,
    this.is_delayed,
  });
}

class TimeInfo {
  final String scheduled_departure;
  final String estimated_arrival;
  final int time_elapsed_min;
  final int time_remaining_min;

  TimeInfo({
    required this.scheduled_departure,
    required this.estimated_arrival,
    required this.time_elapsed_min,
    required this.time_remaining_min,
  });
}

class TripDetails {
  final double total_distance_km;
  final int estimated_duration_min;

  TripDetails({
    required this.total_distance_km,
    required this.estimated_duration_min,
  });
}

class TripResult {
  final TripStatus tripStatus;
  final TimeInfo timeInfo;
  final TripDetails tripDetails;

  TripResult({
    required this.tripStatus,
    required this.timeInfo,
    required this.tripDetails,
  });
}

class TripService {
  static TripResult? getTripProgress({
    required List<dynamic> row,
    required TimeOfDay currentTime,
  }) {
    if (row.length <= 6) return null;

    String busId = _safeVal(row[2]);
    String source = _safeVal(row[3]);
    String dest = _safeVal(row[4]);
    String distanceStr = _safeVal(row[5]);
    String timeStr = _safeVal(row[6]);

    final depTime = _parseTime(timeStr);
    if (depTime == null) return null;

    double distance = double.tryParse(distanceStr) ?? 0;
    if (distance == 0) return null;

    // --- Duration Formula ---
    // trip_duration_minutes = (KMS * 3) + 5
    int duration = (distance * 3).round() + 5;

    // --- Time Normalization ---
    int currentMinutes = currentTime.hour * 60 + currentTime.minute;
    int depMinutes = depTime.hour * 60 + depTime.minute;
    int arrivalMinutes = depMinutes + duration;

    // --- Status Determination ---
    TripStatusEnum status;
    double progress = 0.0;
    int elapsed = 0;
    int remaining = duration;

    bool isOvernight = arrivalMinutes >= 1440;

    if (isOvernight) {
      int arrivalNextDay = arrivalMinutes - 1440;
      
      if (currentMinutes >= depMinutes) {
        // Late night, same day (e.g. 23:30 >= 23:00)
        status = TripStatusEnum.ACTIVE;
        elapsed = currentMinutes - depMinutes;
        remaining = arrivalMinutes - currentMinutes;
      } else if (currentMinutes <= arrivalNextDay) {
        // Early morning, next day (e.g. 00:30 <= 01:00)
        status = TripStatusEnum.ACTIVE;
        elapsed = (1440 - depMinutes) + currentMinutes;
        remaining = arrivalNextDay - currentMinutes;
      } else {
        // Between arrival (next day) and departure (today)
        status = TripStatusEnum.SCHEDULED;
        elapsed = 0;
        remaining = (depMinutes - currentMinutes) + duration;
      }
    } else {
      // Normal Day Trip
      if (currentMinutes < depMinutes) {
        status = TripStatusEnum.SCHEDULED;
        elapsed = 0;
        remaining = (depMinutes - currentMinutes) + duration;
      } else if (currentMinutes <= arrivalMinutes) {
        status = TripStatusEnum.ACTIVE;
        elapsed = currentMinutes - depMinutes;
        remaining = arrivalMinutes - currentMinutes;
      } else {
        status = TripStatusEnum.COMPLETED;
        elapsed = duration;
        remaining = 0;
      }
    }

    if (status == TripStatusEnum.ACTIVE) {
      progress = (elapsed / duration) * 100;
    } else if (status == TripStatusEnum.COMPLETED) {
      progress = 100.0;
    } else {
      progress = 0.0;
    }

    // Constraint: Cap at 100% and Floor at 0%
    if (progress < 0) progress = 0;
    if (progress > 100) progress = 100;

    // --- Formatting ---
    final arrivalTime = _minutesToTime(arrivalMinutes);
    String arrivalStr =
        "${arrivalTime.hour.toString().padLeft(2, '0')}:${arrivalTime.minute.toString().padLeft(2, '0')}";

    return TripResult(
      tripStatus: TripStatus(
        bus_id: busId,
        route: "$source → $dest",
        status: status,
        progress_percentage: progress,
        is_delayed: null, // No GPS data
      ),
      timeInfo: TimeInfo(
        scheduled_departure: timeStr,
        estimated_arrival: arrivalStr,
        time_elapsed_min: elapsed,
        time_remaining_min: remaining,
      ),
      tripDetails: TripDetails(
        total_distance_km: distance,
        estimated_duration_min: duration,
      ),
    );
  }

  static String _safeVal(dynamic val) {
    // Handle Data objects from excel package
    if (val != null && val.runtimeType.toString().contains('Data')) {
      try {
        // Access the value property of Data objects
        final value = (val as dynamic).value;
        if (value == null) return "";
        String str = value.toString();
        if (str.toLowerCase() == 'null') return "";
        return str;
      } catch (e) {
        return "";
      }
    }
    return val?.toString() ?? "";
  }

  static TimeOfDay? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        return TimeOfDay(
            hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  static TimeOfDay _minutesToTime(int totalMinutes) {
    int hour = totalMinutes ~/ 60;
    int minute = totalMinutes % 60;
    if (hour >= 24) hour -= 24;
    return TimeOfDay(hour: hour, minute: minute);
  }
}
