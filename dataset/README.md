# Polydome

## Author & Date 

Jicheng Shi, November 2021.

## Brief Description 

HVAC system data from an entire building, called Polydome. The time-series dataset is composed of continuous features. The database is built based on risk-br's structure by Emilio Maddalena.

## Long Description 
Polydome is a freestanding $600 m^2$ single-zone building on the EPFL campus. It is regularly used for lectures/exams and accommodates up to 200 people.

In the Polydome, a roof-top heat pump, AERMEC RTY-04, serves as an HVAC system. It can execute ventilation (~2.4kW), heating (~6kW), and cooling (~4.6kW). The heat pump collects both the external air and the return air from the room side. When the heat pump is open, it keeps pumping the air to the room for ventilation. At the same time, it can heat or cool the air before pumping.
The heating and cooling procedure is switched on/off according to the difference between the return air temperature (room side) and the corresponding setpoint. By setting the heating (cooling) setpoint 1 degree higher (lower) than the return air temperature, one compressor in the heat pump starts to heat (cool) the air. If this difference is more than 2 degrees, two compressors begin to work together. But this condition should be avoided because the internal controller for the two compressors is not well designed. 


**From a control perspective**: The system inputs are ``power``, ``(return_temp-supply_temp)*supply_flow``. The outputs are ``sensor_temp_1``, ``sensor_temp_2``, ``sensor_temp_3``, ``sensor_temp_4``. The disturbances are ``weather_temp``, ``weather_rad``.

The electrical power of the heat pump is measured every one minute. The value of ``power`` represents the average electrical power within each sampling period. When ``mode``=1 (0), the heat pump executes the heating (cooling) mode, and the  ``power`` is negative (positive). One may also compute the heating or cooling energy by ``(return_temp-supply_temp)*supply_flow``.  Four temperature sensors are installed in different places: two on the 1.5-meter-high walls, two on the top of the small rooms (>2.5m) in the Polydome. In system identification, one may use the average to attenuate the measurement noises. The external weather data are collected from a weather API, tomorrow.io. It offers an accurate weather estimation at 2 meters above the ground for any specific longitude and latitude. The current dataset was collected during the summer vacation, so occupancy should be zero.


**When was it collected?** From July 15, 2021, to September 8, 2021.

**Sampling period**: 15 minutes.

## Folders/Files

:file_folder: **data**: contains the data files.

``raw_2021-07-015_2021-09-02.csv``: original dataset from the local database

``raw_2021-07-015_2021-09-02.mat`: a structure ``exp` in Matlab that contains the same data as the '.csv' file.

:file_folder: **docs**: contains some pictures to illustrate the system architecture.

## Measurements

``time_str`` \[GMT-0\]: date and time of the current measurements. Note it records the time of UTC, not the Swiss time.

``time`` \[GMT-0\]: datenum(time_str) in Matlab. Note it records the time of UTC, not the Swiss time.

``sensor_temp_1`` \[deg Celsius\]: temperature inside room: 1.5-meter-high wall.

``sensor_temp_2`` \[deg Celsius\]: temperature inside room: 1.5-meter-high wall.

``sensor_temp_3`` \[deg Celsius\]: temperature inside room: top of a small room in the polydome (>2.5m).

``sensor_temp_4`` \[deg Celsius\]: temperature inside room: top of a small room in the polydome (>2.5m).

``power`` \[kW\]: the average electrical power of the heat pump within each sampling period. Positive: cooling; negative: heating.

``supply_temp`` \[/10*deg Celsius (this value should be divided by 10 when transformed to 'deg Celsius') \]: the supply air temperature of the heat pump on the room side.

``return_temp`` \[/10*deg Celsius (this value should be divided by 10 when transformed to 'deg Celsius') \]: the return air temperature of the heat pump on the room side.

``supply_flow`` \[*10m^3/h (this value should be multiplied by 10 when transformed to 'm^3/h' )]: the supply air flowrate of the heat pump on the room side.

``weather_temp`` \[deg Celsiu\]: outdoor temperature measured by the weather API: tomorrow.io.

``weather_rad`` \[W/m^2\]: solar radiation (global horizontal irradiance) measured by the weather API: tomorrow.io.

``mode`` : 1: heat pump in heating mode; 0: heat pump in cooling mode.

``setpoint_cool`` \[deg Celsius\]: temperature setpoint of the heating mode for the heat pump.

``setpoint_heat`` \[deg Celsius\]: temperature setpoint of the cooling mode for the heat pump.

