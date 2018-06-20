function [ output_args ] = intrusion_detection(position_llh,restricted_area)
%INTRUSION_DETECTION Used to detect if the user has intruded on a
%restricted area
%   Input1: Position of the receiver in LLH coordinates
%   Input2: restricted area data structure
%   Output: list of positions (in LLH) where there was an intrusion

for i=1:size(position_points,1)
xyz=llh2xyz([deg2rad(position_points(i,1:2)),position_points(i,3)],const.a,const.f);
bool1=[0 0 0 0 0 0];


%xyz=[4.918523463012178e+06,-7.912275986372186e+05,3.969641699700131e+06];
if i==553
    i=553;
end

corner1=llh2xyz([dirchk(dms2rad([38,44,10.10]),'N')...
                               dirchk(dms2rad([9,08,23.25]),'W')...
                               95],const.a,const.f);
                           
corner1_lat=rad2deg(dirchk(dms2rad([38,44,10.10]),'N'));
corner1_lon=rad2deg(dirchk(dms2rad([9,08,23.25]),'W'));
                           
corner3=llh2xyz([dirchk(dms2rad([38,44,14.34]),'N')...
                               dirchk(dms2rad([9,08,17.78]),'W')...
                               95],const.a,const.f);

h_box=150;



corner1_ENU=[0,0,0];
corner3_ENU=ECEF2ENU(corner3-corner1,rad2deg(dirchk(dms2rad([38,44,12.00]),'N')),...
                               rad2deg(dirchk(dms2rad([9,08,19.13]),'W')));
xyz_ENU=ECEF2ENU(xyz-corner1,rad2deg(dirchk(dms2rad([38,44,12.00]),'N')),...
                               rad2deg(dirchk(dms2rad([9,08,19.13]),'W')));
                           

                           

if corner1_ENU(3)>corner3_ENU(3)
    corner1_ENU(3)=corner3_ENU(3);
else
    corner3_ENU(3)=corner1_ENU(3);
end

%Get the other corners
corner2_ENU=[corner3_ENU(1),corner1_ENU(2),corner1_ENU(3)];
corner4_ENU=[corner1_ENU(1),corner3_ENU(2),corner1_ENU(3)];
corner5_ENU=[corner1_ENU(1),corner1_ENU(2),corner1_ENU(3)+h_box];
corner6_ENU=[corner2_ENU(1),corner2_ENU(2),corner2_ENU(3)+h_box];
corner7_ENU=[corner3_ENU(1),corner1_ENU(2),corner1_ENU(3)+h_box];
corner8_ENU=[corner4_ENU(1),corner4_ENU(2),corner4_ENU(3)+h_box];


corner1_ECEF=ENU2ECEF(corner1_ENU,corner1_lat,corner1_lon)+corner1;
corner2_ECEF=ENU2ECEF(corner2_ENU,corner1_lat,corner1_lon)+corner1;
corner3_ECEF=ENU2ECEF(corner3_ENU,corner1_lat,corner1_lon)+corner1;
corner4_ECEF=ENU2ECEF(corner4_ENU,corner1_lat,corner1_lon)+corner1;
corner5_ECEF=ENU2ECEF(corner5_ENU,corner1_lat,corner1_lon)+corner1;
corner6_ECEF=ENU2ECEF(corner6_ENU,corner1_lat,corner1_lon)+corner1;
corner7_ECEF=ENU2ECEF(corner7_ENU,corner1_lat,corner1_lon)+corner1;
corner8_ECEF=ENU2ECEF(corner8_ENU,corner1_lat,corner1_lon)+corner1;

corners=[corner1_ECEF;corner2_ECEF;corner3_ECEF;corner4_ECEF;corner5_ECEF...
    ;corner6_ECEF;corner7_ECEF;corner8_ECEF];
corners_ENU=[corner1_ENU;corner2_ENU;corner3_ENU;corner4_ENU;corner5_ENU...
    ;corner6_ENU;corner7_ENU;corner8_ENU];

u=corners(1,:)-corners(2,:);
v=corners(1,:)-corners(4,:);
w=corners(1,:)-corners(5,:);

u_ENU=corners_ENU(2,:)-corners_ENU(1,:);
v_ENU=corners_ENU(4,:)-corners_ENU(1,:);
w_ENU=corners_ENU(5,:)-corners_ENU(1,:);

% u_ENU=corners_ENU(1,:)-corners_ENU(2,:);
% v_ENU=corners_ENU(1,:)-corners_ENU(4,:);
% w_ENU=corners_ENU(1,:)-corners_ENU(5,:);
% 
% u=cross(corners(1,:)-corners(4,:),corners(1,:)-corners(5,:));
% v=cross(corners(1,:)-corners(2,:),corners(1,:)-corners(5,:));
% w=cross(corners(1,:)-corners(2,:),corners(1,:)-corners(4,:));
% 
% u=cross(corners(4,:)-corners(1,:),corners(5,:)-corners(1,:));
% v=cross(corners(2,:)-corners(1,:),corners(5,:)-corners(1,:));
% w=cross(corners(2,:)-corners(1,:),corners(4,:)-corners(1,:));

% dot(u,xyz)<=dot(u,corners(1,:))
% dot(u,xyz)>=dot(u,corners(2,:))
% dot(v,xyz)<=dot(v,corners(1,:))
% dot(v,xyz)>=dot(v,corners(4,:))
% dot(w,xyz)<=dot(w,corners(1,:))
% dot(w,xyz)>=dot(w,corners(5,:))

% dot(u_ENU,xyz_ENU)<=dot(u_ENU,corners_ENU(1,:))
% dot(u_ENU,xyz_ENU)>=dot(u_ENU,corners_ENU(2,:))
% dot(v_ENU,xyz_ENU)<=dot(v_ENU,corners_ENU(1,:))
% dot(v_ENU,xyz_ENU)>=dot(v_ENU,corners_ENU(4,:))
% dot(w_ENU,xyz_ENU)<=dot(w_ENU,corners_ENU(1,:))
% dot(w_ENU,xyz_ENU)>=dot(w_ENU,corners_ENU(5,:))

    bool1(1)=dot(u_ENU,xyz_ENU)>=dot(u_ENU,corners_ENU(1,:));
    bool1(2)=dot(u_ENU,xyz_ENU)<=dot(u_ENU,corners_ENU(2,:));
    bool1(3)=dot(v_ENU,xyz_ENU)>=dot(v_ENU,corners_ENU(1,:));
    bool1(4)=dot(v_ENU,xyz_ENU)<=dot(v_ENU,corners_ENU(4,:));
    bool1(5)=dot(w_ENU,xyz_ENU)>=dot(w_ENU,corners_ENU(1,:));
    bool1(6)=dot(w_ENU,xyz_ENU)<=dot(w_ENU,corners_ENU(5,:));



% plot(xyz(1)-corners(1,1),xyz(2)-corners(1,2),'-c*');
% hold on
% plot(corners(1,1)-corners(1,1),corners(1,2)-corners(1,2),'-r+');
% plot(corners(1,1)-corners(2,1),corners(1,2)-corners(2,2),'-ro');
% plot(corners(1,1)-corners(3,1),corners(1,2)-corners(3,2),'-rd');
% plot(corners(1,1)-corners(4,1),corners(1,2)-corners(4,2),'-rs');

% plot(xyz_ENU(1)-corners_ENU(1,1),xyz_ENU(2)-corners_ENU(1,2),'-c*');
% hold on
% plot(corners_ENU(1,1)-corners_ENU(1,1),corners_ENU(1,2)-corners_ENU(1,2),'-r+');
% plot(corners_ENU(1,1)-corners_ENU(2,1),corners_ENU(1,2)-corners_ENU(2,2),'-ro');
% plot(corners_ENU(1,1)-corners_ENU(3,1),corners_ENU(1,2)-corners_ENU(3,2),'-rd');
% plot(corners_ENU(1,1)-corners_ENU(4,1),corners_ENU(1,2)-corners_ENU(4,2),'-rs');

% if i>=553
%     plot(corners(1,1)-xyz(1),corners(1,2)-xyz(2),'-c*');
%     hold on
%     plot(corners(1,1)-corners(1,1),corners(1,2)-corners(1,2),'-r+');
%     plot(corners(2,1)-corners(1,1),corners(2,2)-corners(1,2),'-ro');
%     plot(corners(3,1)-corners(1,1),corners(3,2)-corners(1,2),'-rd');
%     plot(corners(4,1)-corners(1,1),corners(4,2)-corners(1,2),'-rs');
%     hold off
%     
%     bool1(1)=dot(u_ENU,xyz_ENU)>=dot(u_ENU,corners_ENU(1,:));
%     bool1(2)=dot(u_ENU,xyz_ENU)<=dot(u_ENU,corners_ENU(2,:));
%     bool1(3)=dot(v_ENU,xyz_ENU)>=dot(v_ENU,corners_ENU(1,:));
%     bool1(4)=dot(v_ENU,xyz_ENU)<=dot(v_ENU,corners_ENU(4,:));
%     bool1(5)=dot(w_ENU,xyz_ENU)>=dot(w_ENU,corners_ENU(1,:));
%     bool1(6)=dot(w_ENU,xyz_ENU)<=dot(w_ENU,corners_ENU(5,:));
%     
%     %disp(bool1)
% end

if dot(u_ENU,xyz_ENU)>=dot(u_ENU,corners_ENU(1,:)) && dot(u_ENU,xyz_ENU)<=dot(u_ENU,corners_ENU(2,:))
    if dot(v_ENU,xyz_ENU)>=dot(v_ENU,corners_ENU(1,:)) && dot(v_ENU,xyz_ENU)<=dot(v_ENU,corners_ENU(4,:))
        if dot(w_ENU,xyz_ENU)>=dot(w_ENU,corners_ENU(1,:)) && dot(w_ENU,xyz_ENU)<=dot(w_ENU,corners_ENU(5,:))
            disp("Warning");
            disp(bool1)
            disp(position_points(i,1:3))
            
                plot(xyz(1)-corners(1,1),xyz(2)-corners(1,2),'-c*');
                hold on
                plot(corners(1,1)-corners(1,1),corners(1,2)-corners(1,2),'-r+');
                plot(corners(2,1)-corners(1,1),corners(2,2)-corners(1,2),'-ro');
                plot(corners(3,1)-corners(1,1),corners(3,2)-corners(1,2),'-rd');
                plot(corners(4,1)-corners(1,1),corners(4,2)-corners(1,2),'-rs');
                hold off
        end
    end
end


end


end

