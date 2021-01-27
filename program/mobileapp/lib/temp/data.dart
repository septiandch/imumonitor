import 'package:imumonitor/widget/linechart.dart';

MultiSeriesData owasData = MultiSeriesData(
  <SeriesData>[
    SeriesData("Back", owasDataBack),
    SeriesData("Arms", owasDataArms),
    SeriesData("Legs", owasDataLegs),
    SeriesData("Load", owasDataLoad)
  ],
);

MultiSeriesData sensorData_1 = MultiSeriesData(
  <SeriesData>[
    SeriesData("Roll", owasDataBack),
    SeriesData("Pitch", owasDataArms),
    SeriesData("Yaw", owasDataLoad),
  ],
);
MultiSeriesData sensorData_2 = MultiSeriesData(
  <SeriesData>[
    SeriesData("Roll", owasDataLegs),
    SeriesData("Pitch", owasDataLoad),
    SeriesData("Yaw", owasDataBack),
  ],
);
MultiSeriesData sensorData_3 = MultiSeriesData(
  <SeriesData>[
    SeriesData("Roll", owasDataLoad),
    SeriesData("Pitch", owasDataArms),
    SeriesData("Yaw", owasDataLegs),
  ],
);
MultiSeriesData sensorData_4 = MultiSeriesData(
  <SeriesData>[
    SeriesData("Roll", owasDataArms),
    SeriesData("Pitch", owasDataLoad),
    SeriesData("Yaw", owasDataBack),
  ],
);
MultiSeriesData sensorData_5 = MultiSeriesData(
  <SeriesData>[
    SeriesData("Roll", owasDataLegs),
    SeriesData("Pitch", owasDataLoad),
    SeriesData("Yaw", owasDataBack),
  ],
);
MultiSeriesData sensorData_6 = MultiSeriesData(
  <SeriesData>[
    SeriesData("Roll", owasDataArms),
    SeriesData("Pitch", owasDataBack),
    SeriesData("Yaw", owasDataLegs),
  ],
);
MultiSeriesData sensorData_7 = MultiSeriesData(
  <SeriesData>[
    SeriesData("Roll", owasDataBack),
    SeriesData("Pitch", owasDataLegs),
    SeriesData("Yaw", owasDataArms),
  ],
);

List<SingleData> owasDataBack = [
  SingleData("07:00", 10),
  SingleData("07:05", 90),
  SingleData("07:10", 90),
  SingleData("07:15", 160),
  SingleData("07:20", 30),
  SingleData("07:25", 10),
  SingleData("07:30", 90),
  SingleData("07:35", 120),
  SingleData("07:40", 120),
  SingleData("07:45", 10),
  SingleData("07:50", 20)
];
List<SingleData> owasDataArms = [
  SingleData("07:00", 20),
  SingleData("07:05", 60),
  SingleData("07:10", 30),
  SingleData("07:15", 10),
  SingleData("07:20", 80),
  SingleData("07:25", 160),
  SingleData("07:30", 190),
  SingleData("07:35", 100),
  SingleData("07:40", 90),
  SingleData("07:45", 20),
  SingleData("07:50", 40)
];
List<SingleData> owasDataLegs = [
  SingleData("07:00", 90),
  SingleData("07:05", 10),
  SingleData("07:10", 20),
  SingleData("07:15", 60),
  SingleData("07:20", 40),
  SingleData("07:25", 60),
  SingleData("07:30", 10),
  SingleData("07:35", 190),
  SingleData("07:40", 230),
  SingleData("07:45", 180),
  SingleData("07:50", 120)
];
List<SingleData> owasDataLoad = [
  SingleData("07:00", 10),
  SingleData("07:05", 70),
  SingleData("07:10", 45),
  SingleData("07:15", 20),
  SingleData("07:20", 120),
  SingleData("07:25", 180),
  SingleData("07:30", 190),
  SingleData("07:35", 10),
  SingleData("07:40", 60),
  SingleData("07:45", 70),
  SingleData("07:50", 40)
];
List<SingleData> sensorDataRoll = [
  SingleData("07:00", 0),
  SingleData("07:05", 90),
  SingleData("07:10", 90),
  SingleData("07:15", 160),
  SingleData("07:20", 30),
  SingleData("07:25", 10),
  SingleData("07:30", 90),
  SingleData("07:35", 120),
  SingleData("07:40", 120),
  SingleData("07:45", 10),
  SingleData("07:50", 20)
];
List<SingleData> sensorDataPitch = [
  SingleData("07:00", 10),
  SingleData("07:05", 90),
  SingleData("07:10", 90),
  SingleData("07:15", 160),
  SingleData("07:20", 30),
  SingleData("07:25", 10),
  SingleData("07:30", 90),
  SingleData("07:35", 120),
  SingleData("07:40", 120),
  SingleData("07:45", 10),
  SingleData("07:50", 20)
];

List<SingleData> sensorDataYaw = [
  SingleData("07:00", 10),
  SingleData("07:05", 90),
  SingleData("07:10", 90),
  SingleData("07:15", 160),
  SingleData("07:20", 30),
  SingleData("07:25", 10),
  SingleData("07:30", 90),
  SingleData("07:35", 120),
  SingleData("07:40", 120),
  SingleData("07:45", 10),
  SingleData("07:50", 20)
];
