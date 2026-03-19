class PNRStatus {
  final String pnrNo;
  final String trainNo;
  final String trainName;
  final String journeyDate;
  final String from;
  final String to;
  final String travelClass;
  final List<Passenger> passengers;
  final String chartStatus;
  final String? boardingStation;
  final String? reservationUpto;

  const PNRStatus({
    required this.pnrNo,
    required this.trainNo,
    required this.trainName,
    required this.journeyDate,
    required this.from,
    required this.to,
    required this.travelClass,
    required this.passengers,
    required this.chartStatus,
    this.boardingStation,
    this.reservationUpto,
  });

  factory PNRStatus.fromJson(Map<String, dynamic> json) => PNRStatus(
        pnrNo: json['pnrNo'] ?? '',
        trainNo: json['trainNo'] ?? '',
        trainName: json['trainName'] ?? '',
        journeyDate: json['journeyDate'] ?? '',
        from: json['from'] ?? '',
        to: json['to'] ?? '',
        travelClass: json['class'] ?? '',
        passengers: (json['passengers'] as List? ?? [])
            .map((p) => Passenger.fromJson(p as Map<String, dynamic>))
            .toList(),
        chartStatus: json['chartStatus'] ?? 'Not Prepared',
        boardingStation: json['boardingStation'],
        reservationUpto: json['reservationUpto'],
      );
}

class Passenger {
  final String name;
  final String bookingStatus;
  final String currentStatus;

  const Passenger({
    required this.name,
    required this.bookingStatus,
    required this.currentStatus,
  });

  factory Passenger.fromJson(Map<String, dynamic> json) => Passenger(
        name: json['name'] ?? 'Passenger',
        bookingStatus: json['bookingStatus'] ?? 'UNKNOWN',
        currentStatus: json['currentStatus'] ?? 'UNKNOWN',
      );

  bool get isConfirmed => currentStatus.startsWith('CNF');
  bool get isWaitlisted => currentStatus.startsWith('WL');
  bool get isRAC => currentStatus.startsWith('RAC');
}
