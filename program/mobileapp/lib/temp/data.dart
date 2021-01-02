import 'package:imumonitor/widget/linechart.dart';

MultiSeriesData owasData = MultiSeriesData(
  <SeriesData>[
    SeriesData("Back", owasData_back),
    SeriesData("Arms", owasData_arms),
    SeriesData("Legs", owasData_legs),
    SeriesData("Load", owasData_load)
  ],
);

MultiSeriesData sensorData_1 = MultiSeriesData(
  <SeriesData>[
    SeriesData("Roll", owasData_back),
    SeriesData("Pitch", owasData_arms),
    SeriesData("Yaw", owasData_load),
  ],
);
MultiSeriesData sensorData_2 = MultiSeriesData(
  <SeriesData>[
    SeriesData("Roll", owasData_legs),
    SeriesData("Pitch", owasData_load),
    SeriesData("Yaw", owasData_back),
  ],
);
MultiSeriesData sensorData_3 = MultiSeriesData(
  <SeriesData>[
    SeriesData("Roll", owasData_load),
    SeriesData("Pitch", owasData_arms),
    SeriesData("Yaw", owasData_legs),
  ],
);
MultiSeriesData sensorData_4 = MultiSeriesData(
  <SeriesData>[
    SeriesData("Roll", owasData_arms),
    SeriesData("Pitch", owasData_load),
    SeriesData("Yaw", owasData_back),
  ],
);
MultiSeriesData sensorData_5 = MultiSeriesData(
  <SeriesData>[
    SeriesData("Roll", owasData_legs),
    SeriesData("Pitch", owasData_load),
    SeriesData("Yaw", owasData_back),
  ],
);
MultiSeriesData sensorData_6 = MultiSeriesData(
  <SeriesData>[
    SeriesData("Roll", owasData_arms),
    SeriesData("Pitch", owasData_back),
    SeriesData("Yaw", owasData_legs),
  ],
);
MultiSeriesData sensorData_7 = MultiSeriesData(
  <SeriesData>[
    SeriesData("Roll", owasData_back),
    SeriesData("Pitch", owasData_legs),
    SeriesData("Yaw", owasData_arms),
  ],
);

List<SingleData> owasData_back = [
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
List<SingleData> owasData_arms = [
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
List<SingleData> owasData_legs = [
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
List<SingleData> owasData_load = [
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
List<SingleData> sensorData_roll = [
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
List<SingleData> sensorData_pitch = [
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

List<SingleData> sensorData_yaw = [
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
