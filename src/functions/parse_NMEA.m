function [points] = parse_NMEA(NMEA_raw_input)
%PARSE_NMEA Reads raw NMEA data and outputs a vector of (Lat,Lon,Height,time) points
%   Detailed explanation goes here

line=fgetl(NMEA_raw_input);
i=0;
points=[];
while ischar(line)
    switch line(2:6)
        case ('GPGGA')
            [UTC,~,~,Lat_deg,~,~,Lon_deg,Quality,~,~,h_msl,~,h_g,~,~,~,checksum] = parse_GGA(line);
            i=i+1;
            points(i,:)=[Lat_deg,Lon_deg,h_msl+h_g,UTC];
            
        case ('GPGLL')
        %    [Lat1,Lat2,Lat_deg,Lon1,Lon2,Lon_deg,UTC,Status,Mode,checksum] = parse_GLL(line);
            
        case ('GPGSA')
        %    [Mode1,Mode2,ID1,ID2,ID3,ID4,ID5,ID6,ID7,ID8,ID9,ID10,ID11,ID12,PDOP,HDOP,VDOP,checksum]= parse_GSA(line);
            
        case ('GPGSV')
        %     [total_messages, total_sats, sat_info, checksum_result, file_handle] = parse_GSV(line, fin);
        case ('GPRMC')
        %    [UTC,status,Lat1,Lat2,Lat_deg,Lon1,Lon2,Lon_deg,speed,TC,date,mag_var1,mag_var2,mode,checksum] = parse_RMC(line);
            
        case ('GPVTG')
        %    [TC,MagC,speed_kts,speed_kph,mode,checksum] = parse_VTG(line);
            
        case ('GPZDA')
        %    [time,day,month,year,localzone_hours,localzone_minutes,checksum] = parse_ZDA(line);
    end
    
    line=fgetl(NMEA_raw_input);

end

