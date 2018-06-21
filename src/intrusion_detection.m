function [overlap_out] = intrusion_detection(position_points,area)
%INTRUSION_DETECTION Used to detect if the user has intruded on a
%restricted area
%   Input1: Position of the receiver in LLH coordinates (degrees) as a
%   vector of columns [lat,lon,h]
%   Input2: restricted area data structure
%   Output: list of positions (in LLH) where there was an intrusion as well
%   as the area ID, in the format [Lat,Lon,h,ID]

global const

n=1;

for i=1:size(position_points,1)
    xyz=llh2xyz([deg2rad(position_points(i,1:2)),position_points(i,3)],const.a,const.f);
    
    if area.type=="sphere"
        dist = norm(xyz - area.center);
        if dist <= area.radius
            overlap_out(n,:)=[position_points(i,:) i area.id];
            n=n+1;
        end
    end
    
    if i==520
        i=520;
    end
    
    
    if area.type == "cylinder"
        %Fazer a divisão do cilindro em fatias, e usar a altitude do receptor móvel para
        %determinar a intrusão
        bottom_llh=xyz2llh(area.center,const.a,const.f);
        bottom_llh=[rad2deg(bottom_llh(1)) rad2deg(bottom_llh(2)) bottom_llh(3)];
        if position_points(i,3)<=area.height+bottom_llh(3)
            %Define the slice height
            slice_center=([deg2rad(bottom_llh(1)) deg2rad(bottom_llh(2)) position_points(i,3)]);
            slice_center_xyz=llh2xyz(slice_center,const.a,const.f);
            dist = norm(xyz - slice_center_xyz);
            if dist <= area.radius
                overlap_out(n,:)=[position_points(i,:) i area.id];
                n=n+1;
            end
        end
    end
    
    
    if area.type == "box"
        bool1=[0 0 0 0 0 0];
        
        %corner1_llh=xyz2llh(area.corner1,const.a,const.f);
        corner1_llh=area.corner1;
        corner1_xyz=llh2xyz(area.corner1,const.a,const.f);
        
        xyz_ENU=ECEF2ENU(xyz-corner1_xyz,rad2deg(corner1_llh(1)),rad2deg(corner1_llh(2)));
        
        u_ENU=area.corners_ENU(2,:)-area.corners_ENU(1,:);
        v_ENU=area.corners_ENU(4,:)-area.corners_ENU(1,:);
        w_ENU=area.corners_ENU(5,:)-area.corners_ENU(1,:);
        
        
        bool1(1)=dot(u_ENU,xyz_ENU)>=dot(u_ENU,area.corners_ENU(1,:));
        bool1(2)=dot(u_ENU,xyz_ENU)<=dot(u_ENU,area.corners_ENU(2,:));
        bool1(3)=dot(v_ENU,xyz_ENU)>=dot(v_ENU,area.corners_ENU(1,:));
        bool1(4)=dot(v_ENU,xyz_ENU)<=dot(v_ENU,area.corners_ENU(4,:));
        bool1(5)=dot(w_ENU,xyz_ENU)>=dot(w_ENU,area.corners_ENU(1,:));
        bool1(6)=dot(w_ENU,xyz_ENU)<=dot(w_ENU,area.corners_ENU(5,:));
        
        disp(bool1);
        fprintf("Coordenadas: %f %f\n",position_points(i,1),position_points(i,2));
        
        if dot(u_ENU,xyz_ENU)>=dot(u_ENU,area.corners_ENU(1,:)) && dot(u_ENU,xyz_ENU)<=dot(u_ENU,area.corners_ENU(2,:))
            if dot(v_ENU,xyz_ENU)>=dot(v_ENU,area.corners_ENU(1,:)) && dot(v_ENU,xyz_ENU)<=dot(v_ENU,area.corners_ENU(4,:))
                if dot(w_ENU,xyz_ENU)>=dot(w_ENU,area.corners_ENU(1,:)) && dot(w_ENU,xyz_ENU)<=dot(w_ENU,area.corners_ENU(5,:))
%                     disp("Warning");
%                     disp(bool1)
%                     disp(position_points(i,1:3))
%                     
%                     plot(xyz(1)-corners(1,1),xyz(2)-corners(1,2),'-c*');
%                     hold on
%                     plot(corners(1,1)-corners(1,1),corners(1,2)-corners(1,2),'-r+');
%                     plot(corners(2,1)-corners(1,1),corners(2,2)-corners(1,2),'-ro');
%                     plot(corners(3,1)-corners(1,1),corners(3,2)-corners(1,2),'-rd');
%                     plot(corners(4,1)-corners(1,1),corners(4,2)-corners(1,2),'-rs');
%                     hold off
                    
                    overlap_out(n,:)=[position_points(i,:) i area.id];
                    n=n+1;
                    
                end
            end
        end
    end
end
