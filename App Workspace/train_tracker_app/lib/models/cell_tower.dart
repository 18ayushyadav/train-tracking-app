class CellTower {
  final int mcc;
  final int mnc;
  final int cid;
  final int lac;
  final double lat;
  final double lon;
  final String routeCode;
  final String stationNear;
  final int? signalStrength;

  const CellTower({
    required this.mcc,
    required this.mnc,
    required this.cid,
    required this.lac,
    required this.lat,
    required this.lon,
    this.routeCode = 'UNKNOWN',
    this.stationNear = '',
    this.signalStrength,
  });

  factory CellTower.fromMap(Map<String, dynamic> map) => CellTower(
        mcc: map['mcc'] as int,
        mnc: map['mnc'] as int,
        cid: map['cid'] as int,
        lac: map['lac'] as int,
        lat: (map['lat'] as num).toDouble(),
        lon: (map['lon'] as num).toDouble(),
        routeCode: map['route_code'] as String? ?? 'UNKNOWN',
        stationNear: map['station_near'] as String? ?? '',
        signalStrength: map['signal_strength'] as int?,
      );

  Map<String, dynamic> toMap() => {
        'mcc': mcc,
        'mnc': mnc,
        'cid': cid,
        'lac': lac,
        'lat': lat,
        'lon': lon,
        'route_code': routeCode,
        'station_near': stationNear,
        'signal_strength': signalStrength,
      };
}
