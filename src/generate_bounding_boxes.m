clc

const.a = 6378137;
const.f = 1/298.257223563;

%Obter o número de zonas de restrição pretendidas
n_zonas_rest=input('Introduza o número de zonas de restrição pretendidas: ');

%Obter os dados referentes a cada zona
area=[];
for j=1:n_zonas_rest
    fprintf("\n\nPara a zona %d\n",j);
    type=input('Qual o tipo de zona pretendida? (sphere,cylinder,box): ','s');
    
    
    
    if type=="sphere"
        area(j).id=j;
        area(j).type="sphere";
        
        %Obter o raio e o centro da esfera a usar
        area(j).radius=input('Introduza o raio da esfera: ');
        
        lat_input=input('Introduza a latitude do centro da esfera (DDºMM''SS'''' N/S): ','s');
        aux1=strsplit(lat_input,["º","'","''"," "]);
        aux2=[str2double(aux1{1}),str2double(aux1{2}),str2double(aux1{3})];
        center(1)=dirchk(dms2rad(aux2),aux1{4});
        
        lon_input=input('Introduza a longitude do centro da esfera (DDºMM''SS'''' E/W): ','s');
        aux1=strsplit(lon_input,["º","'","''"," "]);
        aux2=[str2double(aux1{1}),str2double(aux1{2}),str2double(aux1{3})];
        center(2)=dirchk(dms2rad(aux2),aux1{4});
        
        h_input=input('Introduza a altitude do centro da esfera (em metros acima do elipsóide): ');
        center(3)=h_input;
        area(j).center=llh2xyz(center,const.a,const.f);
    end
    
    if type=="cylinder"
        area(j).id=j;
        area(j).type="cylinder";
        
        %Obter o raio e a altura do cilindro
        area(j).radius=input('Introduza o raio do cilindro: ');
        area(j).height=input('Introduza a altura do cilindro: ');
        
        lat_input=input('Introduza a latitude do centro da base do cilindro (DDºMM''SS'''' N/S): ','s');
        aux1=strsplit(lat_input,["º","'","''"," "]);
        aux2=[str2double(aux1{1}),str2double(aux1{2}),str2double(aux1{3})];
        bottom(1)=dirchk(dms2rad(aux2),aux1{4});
        
        lon_input=input('Introduza a longitude do centro da base do cilindro (DDºMM''SS'''' E/W): ','s');
        aux1=strsplit(lon_input,["º","'","''"," "]);
        aux2=[str2double(aux1{1}),str2double(aux1{2}),str2double(aux1{3})];
        bottom(2)=dirchk(dms2rad(aux2),aux1{4});
        
        h_input=input('Introduza a altitude do centro da base do cilindro (em metros acima do elipsóide): ');
        bottom(3)=h_input;
        area(j).center=llh2xyz(bottom,const.a,const.f);
    end
    
    
    if type=="box"
        area(j).id=j;
        area(j).type="box";
        
        %Obter as coordenadas de dois pontos, 1 e 3, necessários para
        %definir o rectângulo da base do paralelepípedo
        lat_input=input('Introduza a latitude do primeiro ponto (DDºMM''SS'''' N/S): ','s');
        aux1=strsplit(lat_input,["º","'","''"," "]);
        aux2=[str2double(aux1{1}),str2double(aux1{2}),str2double(aux1{3})];
        corner1(1)=dirchk(dms2rad(aux2),aux1{4});
        
        lon_input=input('Introduza a longitude do primeiro ponto (DDºMM''SS'''' E/W): ','s');
        aux1=strsplit(lon_input,["º","'","''"," "]);
        aux2=[str2double(aux1{1}),str2double(aux1{2}),str2double(aux1{3})];
        corner1(2)=dirchk(dms2rad(aux2),aux1{4});
        
        h_input=input('Introduza a altitude do primeiro ponto (em metros acima do elipsóide): ');
        corner1(3)=h_input;
        
        %Gravar a variável corner1 na estrutura para uso futuro como
        %referência do referencial ENU
        area(j).corner1=corner1;
        
        lat_input=input('Introduza a latitude do segundo ponto (DDºMM''SS'''' N/S): ','s');
        aux1=strsplit(lat_input,["º","'","''"," "]);
        aux2=[str2double(aux1{1}),str2double(aux1{2}),str2double(aux1{3})];
        corner3(1)=dirchk(dms2rad(aux2),aux1{4});
        
        lon_input=input('Introduza a longitude do segundo ponto (DDºMM''SS'''' E/W): ','s');
        aux1=strsplit(lon_input,["º","'","''"," "]);
        aux2=[str2double(aux1{1}),str2double(aux1{2}),str2double(aux1{3})];
        corner3(2)=dirchk(dms2rad(aux2),aux1{4});
        
        h_input=input('Introduza a altitude do segundo ponto (em metros acima do elipsóide): ');
        corner3(3)=h_input;
        
        %Obter a altura do paralelepípedo
        height_box=input('Introduza a altura do paralelepípedo (em metros): ');
        
        
        %Converter os pontos para ECEF
        corner1_ECEF=llh2xyz(corner1,const.a,const.f);
        corner3_ECEF=llh2xyz(corner3,const.a,const.f);
        
        
        %Converter os pontos para ENU, de forma a determinar um
        %paralelepípedo ortonormado
        corner1_ENU=[0,0,0];
        corner3_ENU=ECEF2ENU(corner3_ECEF-corner1_ECEF,corner1(1),corner1(2));
        
        %Para evitar efeitos de a Terra não ser plana, ajustar o ponto 1 ou
        %3 de forma a que a base do paralelepípedo seja o mais baixa
        %possível
        if corner1_ENU(3)>corner3_ENU(3)
            corner1_ENU(3)=corner3_ENU(3);
        else
            corner3_ENU(3)=corner1_ENU(3);
        end
        
        %Get the other corners
        corner2_ENU=[corner3_ENU(1),corner1_ENU(2),corner1_ENU(3)];
        corner4_ENU=[corner1_ENU(1),corner3_ENU(2),corner1_ENU(3)];
        corner5_ENU=[corner1_ENU(1),corner1_ENU(2),corner1_ENU(3)+height_box];
        corner6_ENU=[corner2_ENU(1),corner2_ENU(2),corner2_ENU(3)+height_box];
        corner7_ENU=[corner3_ENU(1),corner1_ENU(2),corner1_ENU(3)+height_box];
        corner8_ENU=[corner4_ENU(1),corner4_ENU(2),corner4_ENU(3)+height_box];
        
        
        corner1_ECEF=ENU2ECEF(corner1_ENU,corner1(1),corner1(2))+corner1;
        corner2_ECEF=ENU2ECEF(corner2_ENU,corner1(1),corner1(2))+corner1;
        corner3_ECEF=ENU2ECEF(corner3_ENU,corner1(1),corner1(2))+corner1;
        corner4_ECEF=ENU2ECEF(corner4_ENU,corner1(1),corner1(2))+corner1;
        corner5_ECEF=ENU2ECEF(corner5_ENU,corner1(1),corner1(2))+corner1;
        corner6_ECEF=ENU2ECEF(corner6_ENU,corner1(1),corner1(2))+corner1;
        corner7_ECEF=ENU2ECEF(corner7_ENU,corner1(1),corner1(2))+corner1;
        corner8_ECEF=ENU2ECEF(corner8_ENU,corner1(1),corner1(2))+corner1;
        
        area(j).corners=[corner1_ECEF;corner2_ECEF;corner3_ECEF;corner4_ECEF;corner5_ECEF...
            ;corner6_ECEF;corner7_ECEF;corner8_ECEF];
        area(j).corners_ENU=[corner1_ENU;corner2_ENU;corner3_ENU;corner4_ENU;corner5_ENU...
            ;corner6_ENU;corner7_ENU;corner8_ENU];
    end
    
    
    
    
end
