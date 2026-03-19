class Train {
  final String trainNo;
  final String trainName;
  final String from;
  final String to;
  final String departure;
  final String arrival;
  final String status;
  final String currentStation;
  final String currentStationCode;
  final String? nextStation;
  final String? nextStationCode;
  final int delayMinutes;
  final double speed;
  final double? lat;
  final double? lon;
  final DateTime lastUpdated;
  final bool isOffline;

  const Train({
    required this.trainNo,
    required this.trainName,
    required this.from,
    required this.to,
    this.departure = '--',
    this.arrival = '--',
    required this.status,
    required this.currentStation,
    required this.currentStationCode,
    this.nextStation,
    this.nextStationCode,
    this.delayMinutes = 0,
    this.speed = 0,
    this.lat,
    this.lon,
    required this.lastUpdated,
    this.isOffline = false,
  });

  factory Train.fromJson(Map<String, dynamic> json) => Train(
        trainNo: json['trainNo'] ?? '',
        trainName: json['trainName'] ?? 'Unknown Train',
        from: json['from'] ?? '',
        to: json['to'] ?? '',
        departure: json['departure'] ?? '--',
        arrival: json['arrival'] ?? '--',
        status: json['status'] ?? 'Unknown',
        currentStation: json['currentStation'] ?? '',
        currentStationCode: json['currentStationCode'] ?? '',
        nextStation: json['nextStation'],
        nextStationCode: json['nextStationCode'],
        delayMinutes: (json['delay'] ?? json['delayMinutes'] ?? 0) as int,
        speed: ((json['speed'] ?? 0) as num).toDouble(),
        lat: json['lat'] != null ? (json['lat'] as num).toDouble() : null,
        lon: json['lon'] != null ? (json['lon'] as num).toDouble() : null,
        lastUpdated: json['lastUpdated'] != null
            ? DateTime.parse(json['lastUpdated'] as String)
            : DateTime.now(),
        isOffline: json['isOffline'] == true,
      );

  Map<String, dynamic> toJson() => {
        'trainNo': trainNo,
        'trainName': trainName,
        'from': from,
        'to': to,
        'departure': departure,
        'arrival': arrival,
        'status': status,
        'currentStation': currentStation,
        'currentStationCode': currentStationCode,
        'nextStation': nextStation,
        'nextStationCode': nextStationCode,
        'delay': delayMinutes,
        'speed': speed,
        'lat': lat,
        'lon': lon,
        'lastUpdated': lastUpdated.toIso8601String(),
        'isOffline': isOffline,
      };

  String get etaDisplay {
    if (delayMinutes == 0) return arrival;
    final base = arrival.split(':');
    if (base.length < 2) return arrival;
    final h = int.tryParse(base[0]) ?? 0;
    final m = int.tryParse(base[1]) ?? 0;
    final total = h * 60 + m + delayMinutes;
    return '${(total ~/ 60).toString().padLeft(2, '0')}:${(total % 60).toString().padLeft(2, '0')} (+${delayMinutes}m)';
  }

  bool get isOnTime => delayMinutes == 0;
  bool get isLate => delayMinutes > 0;
}
