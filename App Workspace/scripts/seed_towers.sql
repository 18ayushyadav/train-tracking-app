-- Indian Railways Cell Tower Seed Data
-- MCC 404 = India (Airtel/BSNL/Jio share same tower hardware)
-- Columns: mcc, mnc, cid, lac, lat, lon, route_code, station_near

CREATE TABLE IF NOT EXISTS cell_towers (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  mcc         INTEGER NOT NULL,
  mnc         INTEGER NOT NULL,
  cid         INTEGER NOT NULL,
  lac         INTEGER NOT NULL,
  lat         REAL    NOT NULL,
  lon         REAL    NOT NULL,
  route_code  TEXT,
  station_near TEXT
);

CREATE INDEX IF NOT EXISTS idx_towers_cid ON cell_towers(cid);
CREATE INDEX IF NOT EXISTS idx_towers_lac ON cell_towers(lac);

INSERT INTO cell_towers (mcc,mnc,cid,lac,lat,lon,route_code,station_near) VALUES
(404,20,12345,1001,28.6419,77.2194,'DEL-MBI','New Delhi'),
(404,20,12346,1001,28.5888,77.2490,'DEL-MBI','Hazrat Nizamuddin'),
(404,20,22201,1002,27.4924,77.6737,'DEL-MBI','Mathura Junction'),
(404,20,22202,1002,27.1591,77.9860,'DEL-MBI','Agra Cantt'),
(404,20,22203,1002,26.4499,80.3319,'DEL-CNB','Kanpur Central'),
(404,20,22204,1003,25.4358,81.8463,'DEL-HWH','Prayagraj Junction'),
(404,20,22205,1003,25.2765,83.1188,'DEL-HWH','Pt. DDU Junction'),
(404,20,22206,1003,24.7914,84.9994,'DEL-HWH','Gaya Junction'),
(404,20,22207,1003,25.6100,85.1749,'DEL-HWH','Patna Junction'),
(404,20,22208,1004,22.5830,88.3421,'DEL-HWH','Howrah Junction'),
(404,20,33301,2001,22.3007,73.2088,'MBI-DEL','Vadodara Junction'),
(404,20,33302,2001,23.3441,75.0379,'MBI-DEL','Ratlam Junction'),
(404,20,33303,2001,25.1460,75.8492,'MBI-DEL','Kota Junction'),
(404,20,33304,2001,26.9220,75.7874,'MBI-JP','Jaipur Junction'),
(404,20,33305,2002,21.2090,72.8390,'MBI-ADI','Surat'),
(404,20,33306,2002,23.0258,72.6014,'MBI-ADI','Ahmedabad Junction'),
(404,20,33307,2002,18.9691,72.8193,'MBI-PUNE','Mumbai Central'),
(404,20,33308,2003,18.5236,73.8478,'MBI-PUNE','Pune Junction'),
(404,20,44401,3001,13.0827,80.2707,'MAS-SBC','Chennai Central'),
(404,20,44402,3001,12.9767,77.5713,'MAS-SBC','Bengaluru City'),
(404,20,44403,3001,11.0168,76.9558,'MAS-TVC','Coimbatore Junction'),
(404,20,44404,3001, 9.9193,78.1197,'MAS-TVC','Madurai Junction'),
(404,20,44405,3002, 8.4900,76.9525,'MAS-TVC','Thiruvananthapuram Central'),
(404,20,44406,3002, 9.9837,76.2974,'ERS-MAS','Ernakulam Junction'),
(404,20,55501,4001,17.4339,78.5025,'SC-NDLS','Secunderabad Junction'),
(404,20,55502,4001,21.1458,79.0882,'SC-NDLS','Nagpur'),
(404,20,55503,4001,21.2336,81.6337,'BSP-NDLS','Raipur Junction'),
(404,20,55504,4001,22.0882,82.1505,'BSP-NDLS','Bilaspur Junction'),
(404,20,55505,4002,16.5144,80.6396,'MAS-HWH','Vijayawada Junction'),
(404,20,55506,4002,17.6868,83.2185,'MAS-HWH','Visakhapatnam'),
(404,20,66601,5001,26.8467,80.9462,'DEL-LKO','Lucknow Charbagh'),
(404,20,66602,5001,31.6342,74.8723,'DEL-ASR','Amritsar Junction'),
(404,20,66603,5001,30.9002,75.8573,'DEL-ASR','Ludhiana Junction'),
(404,20,66604,5001,30.3675,76.7789,'DEL-ASR','Ambala Cantonment'),
(404,20,66605,5002,23.2681,77.4089,'BPL-NDLS','Bhopal Junction'),
(404,20,66606,5002,22.7196,75.8577,'INDB-BPL','Indore Junction'),
(404,20,77701,6001,26.1833,91.7458,'GHY-NDLS','Guwahati'),
(404,20,77702,6001,27.4728,94.9120,'GHY-DBRG','Dibrugarh'),
(404,20,88801,7001,19.0227,72.8423,'DR-PUNE','Dadar'),
(404,20,88802,7001,19.0671,72.9129,'LTT-NGP','Lokmanya Tilak Terminus');
