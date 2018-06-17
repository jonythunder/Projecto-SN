function [raw,eph,hui] = parse_raw(bitstream)
%PARSE_RAW reads a synced bitstream and outputs the parsed data
%   Reads a bitstream that starts with the sync block (0xB5 0x62), parses
%   its data and returns it in a processable format

i_max=size(bitstream,1);
i=1;
n1=1;
n2=1;
n3=1;
stop=1;

raw=strings(1,503);
eph=strings(1,79);
hui=strings(1,27);

while stop
    if strcmp(bitstream(i:i+1,:),['B5';'62'])%Checks if the first block is the sync block
        %Get the message length
        message_length=(bitstream(i+4:i+5,:));
        message_length=hex2dec(sprintf('%c%c%c%c',message_length(2,1),message_length(2,2),...
            message_length(1,1),message_length(1,2)));
        message_length=message_length+8;%Include the remaining bits
        
        %disp(bitstream(i:i+message_length-1,:))
        
        %Compute the checksum
        CK_A = 0;
        CK_B = 0;
        for j=2:message_length-3
            CK_A=CK_A + hex2dec(bitstream(i+j,:));
            CK_B=CK_B+CK_A;
        end
        CK_A=(bitand(CK_A,hex2dec('FF')));
        CK_B=(bitand(CK_B,hex2dec('FF')));
        
        
        %Check if checksum is valid
        if CK_A==hex2dec(bitstream(i+message_length-2,:)) && CK_B==hex2dec(bitstream(i+message_length-1,:))
            
            
            %Decode the message
            if strcmp(bitstream(i+2:i+3,:),['02';'10']) %If RXM-RAW message
                raw(n1,:)=parse_RXM_RAW(bitstream(i+6:i+message_length-2,:));
                n1=n1+1;
                
            elseif strcmp(bitstream(i+2:i+3,:),['0B';'31']) %If AID-EPH message
                if message_length == 112 %If contains actual data

                    eph(n2,:)=parse_AID_EPH(bitstream(i+6:i+message_length-2,:));
                    n2=n2+1;
                end
                
            elseif strcmp(bitstream(i+2:i+3,:),['0B';'02']) %If AID-HUI message
                hui(n3,:)=parse_AID_HUI(bitstream(i+6:i+message_length-2,:));
                n3=n3+1;
            end
        end
        
        %disp(bitstream(i:i+message_length-1,:))
        i=i+message_length;
        if i>=i_max
            stop=0;
        end
        %Pode ser substituido por um incremento do indice de bitstream se
        %não encontrar o bloco de sync
    end
end
end


function [raw]=parse_RXM_RAW(bitstream)
    raw=strings(1,503);
    for i=1:53
        raw(i)="0";
    end
    
    %Get itow
    itow_hex=sprintf('%s%s%s%s',bitstream(4,:),bitstream(3,:),...
            bitstream(2,:),bitstream(1,:));
    raw(1,1)=sprintf("%d",typecast( uint32( hex2dec(itow_hex) ), 'int32'));
    
    %Get week
    week_hex=sprintf('%s%s',bitstream(6,:),bitstream(5,:));
    raw(1,2)=sprintf("%d",typecast( uint16( hex2dec(week_hex) ), 'int16'));
    
    %Get numSV
    numSV_hex=bitstream(7,:);
    raw(1,3)=sprintf("%d",hex2dec(numSV_hex));
    
    %Get the repeated block of satellite data
    for N=1:hex2dec(numSV_hex) %Iterate for all satellites
        %Get SVN
        SVN_hex=bitstream(29+24*(N-1),:);
        raw(1,4+10*(N-1))=sprintf("%d",hex2dec(SVN_hex));
        
        %Get mesQI
        mesQI_hex=bitstream(30+24*(N-1),:);
        raw(1,5+10*(N-1))=sprintf("%d",typecast( uint16( hex2dec(mesQI_hex) ), 'int16'));
        
        %Get C/No
        CNo_hex=bitstream(31+24*(N-1),:);
        raw(1,6+10*(N-1))=sprintf("%d",typecast( uint16( hex2dec(CNo_hex) ), 'int16'));
        
        %Get LLI
        LLI_hex=bitstream(32+24*(N-1),:);
        raw(1,7+10*(N-1))=sprintf("%d",hex2dec(LLI_hex));
        
        %Get cp
        cp_hex_aux=bitstream(9+24*(N-1):16+24*(N-1),:);
        cp_hex=sprintf('%s%s%s%s%s%s%s%s',cp_hex_aux(8,:),cp_hex_aux(7,:),...
            cp_hex_aux(6,:),cp_hex_aux(5,:),cp_hex_aux(4,:),cp_hex_aux(3,:),...
            cp_hex_aux(2,:),cp_hex_aux(1,:));
        raw(1,8+10*(N-1))=sprintf('0x%s',cp_hex);
        raw(1,9+10*(N-1))=sprintf("%.11e",hex2num(cp_hex));
        
        %Get pr
        pr_hex_aux=bitstream(17+24*(N-1):24+24*(N-1),:);
        pr_hex=sprintf('%s%s%s%s%s%s%s%s',pr_hex_aux(8,:),pr_hex_aux(7,:),...
            pr_hex_aux(6,:),pr_hex_aux(5,:),pr_hex_aux(4,:),pr_hex_aux(3,:),...
            pr_hex_aux(2,:),pr_hex_aux(1,:));
        raw(1,10+10*(N-1))=sprintf('0x%s',pr_hex);
        raw(1,11+10*(N-1))=sprintf("%.11e",hex2num(pr_hex));
        
        %Get do
        do_hex_aux=bitstream(25+24*(N-1):28+24*(N-1),:);
        do_hex=sprintf('%s%s%s%s',do_hex_aux(4,:),do_hex_aux(3,:),...
            do_hex_aux(2,:),do_hex_aux(1,:));
        raw(1,12+10*(N-1))=sprintf('0x%s',do_hex);
        raw(1,13+10*(N-1))=sprintf("%.11e",typecast(uint32(hex2dec(do_hex)),'single'));
    end
    for N=hex2dec(numSV_hex)+1:50
        raw(1,4+10*(N-1))="0";
        raw(1,5+10*(N-1))="0";
        raw(1,6+10*(N-1))="0";
        raw(1,7+10*(N-1))="0";
        raw(1,8+10*(N-1))="0";
        raw(1,9+10*(N-1))="0";
        raw(1,10+10*(N-1))="0";
        raw(1,11+10*(N-1))="0";
        raw(1,12+10*(N-1))="0";
        raw(1,13+10*(N-1))="0";
    end
end

function [eph]=parse_AID_EPH(bitstream)
    eph=strings(1,79);
    
    %Get SVN
    SVN_hex_aux=bitstream(1:4,:);
    SVN_hex=sprintf('%s%s%s%s',SVN_hex_aux(4,:),SVN_hex_aux(3,:),SVN_hex_aux(2,:),SVN_hex_aux(1,:));
    eph(1)=sprintf("%d",hex2dec(SVN_hex));
    
    
    %--Subframe 1--%
    %Word 3
    word_hex_aux=bitstream(9:12,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get WN
    WN_bin=word_bin(1:10);
    eph(4)=bin2dec(WN_bin);
    %Get Code on L2 Channel
    eph(14)=bin2dec(word_bin(11:12));
    %Get URA index
    eph(11)=bin2dec(word_bin(13:16));
    %Get SV Health
    SV_health_bin=word_bin(17:22);
    eph(10)=bin2dec(SV_health_bin);
    eph(9)=sprintf('0x%02s',dec2base(bin2dec(SV_health_bin),16));
    %Get 2 MSBs of IODC
    IODC_bin=word_bin(23:24);
    
    %Word 4
    word_hex_aux=bitstream(13:16,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get L2 P data flag
    eph(15)=word_bin(1);
    
    %Word 7
    word_hex_aux=bitstream(25:28,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get TGD
    TGD_bin=word_bin(17:24);
    eph(17)=typecast(uint8(bin2dec(TGD_bin)),'int8');
    eph(16)=sprintf('0x%02s',dec2base(bin2dec(TGD_bin),16));
    eph(18)=sprintf("%.11e",str2double(eph(17))*2^-31);
    
    %Word 8
    word_hex_aux=bitstream(29:32,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get rest of IODC
    IODC_bin=[IODC_bin,word_bin(1:8)];
    eph(19)=bin2dec(IODC_bin);
    %Get toc
    TOC_bin=word_bin(9:24);
    eph(21)=bin2dec(TOC_bin);
    eph(20)=sprintf('0x%04s',dec2base(bin2dec(TOC_bin),16));
    eph(22)=sprintf("%d",str2double(eph(21))*2^4);
    
    
    %Word 9
    word_hex_aux=bitstream(33:36,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get af2
    af2_bin=word_bin(1:8);
    eph(24)=typecast(uint8(bin2dec(af2_bin)),'int8');
    eph(23)=sprintf('0x%02s',dec2base(bin2dec(af2_bin),16));
    eph(25)=sprintf("%.11e",str2double(eph(24))*2^-55);
    %Get af1
    af1_bin=word_bin(9:24);
    eph(27)=typecast(uint16(bin2dec(af1_bin)),'int16');
    eph(26)=sprintf('0x%04s',dec2base(bin2dec(af1_bin),16));
    eph(28)=sprintf("%.11e",str2double(eph(27))*2^-43);
    
    %Word 10
    word_hex_aux=bitstream(37:40,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get af0
    af0_bin=word_bin(1:22);
    [af0_dec,af0_hex]=uint2sigint(af0_bin);
    eph(30)=af0_dec;
    eph(29)=sprintf('0x%06s',af0_hex);
    eph(31)=sprintf("%.11e",str2double(eph(30))*2^-31);
    
    
    %--Subframe 2--%
    %Word 3
    word_hex_aux=bitstream(41:44,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get IODE SF2
    eph(2)=bin2dec(word_bin(1:8));
    %Get Crs
    crs_bin=word_bin(9:24);
    eph(69)=typecast(uint16(bin2dec(crs_bin)),'int16');
    eph(68)=sprintf('0x%04s',dec2base(bin2dec(crs_bin),16));
    eph(70)=sprintf("%.11e",str2double(eph(69))*2^-5);

    
    %Word 4
    word_hex_aux=bitstream(45:48,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get delta_n
    delta_n_bin=word_bin(1:16);
    eph(36)=typecast(uint16(bin2dec(delta_n_bin)),'int16');
    eph(35)=sprintf('0x%04s',dec2base(bin2dec(delta_n_bin),16));
    eph(37)=sprintf("%.11e",semicircles2rad(str2double(eph(36)))*2^-(43-31));
    %Get first 8 bits of M0
    M0_bin_aux=word_bin(17:24);
    
    %Word 5
    word_hex_aux=bitstream(49:52,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get last 24 bits of M0
    M0_bin=[M0_bin_aux,word_bin(1:24)];
    eph(39)=typecast(uint32(bin2dec(M0_bin)),'int32');
    eph(38)=sprintf('0x%08s',dec2base(bin2dec(M0_bin),16));
    eph(40)=sprintf("%.11e",semicircles2rad(str2double(eph(39)))*2^-(31-31));
    
    %Word 6
    word_hex_aux=bitstream(53:56,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get Cuc
    cuc_bin=word_bin(1:16);
    eph(60)=typecast(uint16(bin2dec(cuc_bin)),'int16');
    eph(59)=sprintf('0x%04s',dec2base(bin2dec(cuc_bin),16));
    eph(61)=sprintf("%.11e",str2double(eph(60))*2^-29);
    %Get first 8 bits of e
    e_bin_aux=word_bin(17:24);
    
    %Word 7
    word_hex_aux=bitstream(57:60,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get rest of e
    e_bin=[e_bin_aux,word_bin(1:24)];
    eph(42)=bin2dec(e_bin);
    eph(41)=sprintf('0x%08s',dec2base(bin2dec(e_bin),16));
    eph(43)=sprintf("%.11e",str2double(eph(42))*2^-33);
    
    
    %Word 8
    word_hex_aux=bitstream(61:64,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get Cus
    cus_bin=word_bin(1:16);
    [cus_dec,cus_hex]=uint2sigint(cus_bin);
    eph(63)=cus_dec;
    eph(62)=sprintf('0x%04s',cus_hex);
    eph(64)=sprintf("%.11e",str2double(eph(63))*2^-29);
    %Get the first 8 bits of sqrt(A)
    sqrt_A_bin_aux=word_bin(17:24);
    
    
    %Word 9
    word_hex_aux=bitstream(65:68,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get the rest of sqrt(A)
    sqrt_A_bin=[sqrt_A_bin_aux,word_bin];
    eph(33)=bin2dec(sqrt_A_bin);
    eph(32)=sprintf('0x%08s',dec2base(bin2dec(sqrt_A_bin),16));
    eph(34)=sprintf("%.11e",str2double(eph(33))*2^-19);
    
    
    %Word 10
    word_hex_aux=bitstream(69:72,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get toe
    toe_bin=word_bin(1:16);
    eph(6)=bin2dec(toe_bin);
    eph(5)=sprintf('0x%04s',dec2base(bin2dec(toe_bin),16));
    eph(7)=sprintf("%d",str2double(eph(6))*2^4);
    %Get fit interval flag
    eph(8)=word_bin(17);
    %Get AODO
    aodo_bin=word_bin(18:22);
    eph(78)=bin2dec(aodo_bin);
    eph(77)=sprintf('0x%03s',dec2base(bin2dec(aodo_bin),16));
    eph(79)=sprintf("%d",str2double(eph(78))*9000);
    
    
    %--Subframe 3--%
    %Word 3
    word_hex_aux=bitstream(73:76,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get Cic
    cic_bin=word_bin(1:16);
    eph(72)=typecast(uint16(bin2dec(cic_bin)),'int16');
    eph(71)=sprintf('0x%04s',dec2base(bin2dec(cic_bin),16));
    eph(73)=sprintf("%.11e",str2double(eph(72))*2^-29);
    %Get first 8 bits of Omega0
    omega0_bin_aux=word_bin(17:24);
    
    %Word 4
    word_hex_aux=bitstream(77:80,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get rest of Omega0
    omega0_bin=[omega0_bin_aux,word_bin(1:24)];
    eph(54)=typecast(uint32(bin2dec(omega0_bin)),'int32');
    eph(53)=sprintf('0x%08s',dec2base(bin2dec(omega0_bin),16));
    eph(55)=sprintf("%.11e",semicircles2rad(str2double(eph(54)))*2^-(31-31));
    
    %Word 5
    word_hex_aux=bitstream(81:84,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get Cis
    cis_bin=word_bin(1:16);
    eph(75)=typecast(uint16(bin2dec(cis_bin)),'int16');
    eph(74)=sprintf('0x%04s',dec2base(bin2dec(cis_bin),16));
    eph(76)=sprintf("%.11e",str2double(eph(75))*2^-29);
    %Get first 8 bits of i0
    i0_bin_aux=word_bin(17:24);
    
    %Word 6
    word_hex_aux=bitstream(85:88,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get the rest of i0
    i0_bin=[i0_bin_aux,word_bin(1:24)];
    eph(48)=typecast(uint32(bin2dec(i0_bin)),'int32');
    eph(47)=sprintf('0x%08s',dec2base(bin2dec(i0_bin),16));
    eph(49)=sprintf("%.11e",semicircles2rad(str2double(eph(48)))*2^-(31-31));
    
    %Word 7
    word_hex_aux=bitstream(89:92,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get Crc
    crc_bin=word_bin(1:16);
    eph(66)=typecast(uint16(bin2dec(crc_bin)),'int16');
    eph(65)=sprintf('0x%04s',dec2base(bin2dec(crc_bin),16));
    eph(67)=sprintf("%.11e",str2double(eph(66))*2^-5);
    %Get the first 8 bits of the argument of perigee
    argper_bin_aux=word_bin(17:24);
    
    %Word 8
    word_hex_aux=bitstream(93:96,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get the rest of the argument of perigee
    argper_bin=[argper_bin_aux,word_bin(1:24)];
    eph(45)=typecast(uint32(bin2dec(argper_bin)),'int32');
    eph(44)=sprintf('0x%08s',dec2base(bin2dec(argper_bin),16));
    eph(46)=sprintf("%.11e",semicircles2rad(str2double(eph(45)))*2^-(31-31));
    
    %Word 9
    word_hex_aux=bitstream(97:100,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %get OmegaDot
    OmegaDot_bin=word_bin(1:24);
    [OmegaDot_dec,OmegaDot_hex]=uint2sigint(OmegaDot_bin);
    eph(57)=OmegaDot_dec;
    eph(56)=sprintf('0x%06s',OmegaDot_hex);
    eph(58)=sprintf("%.11e",semicircles2rad(str2double(eph(57)))*2^-(43-31));
    
    %Word 10
    word_hex_aux=bitstream(101:104,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get IODE SF3
    eph(3)=bin2dec(word_bin(1:8));
    %Get IDOT
    IDOT_bin=word_bin(9:22);
    [IDOT_dec,IDOT_hex]=uint2sigint(IDOT_bin);
    eph(51)=IDOT_dec;
    eph(50)=sprintf('0x%04s',IDOT_hex);
    eph(52)=sprintf("%.11e",semicircles2rad(str2double(eph(51)))*2^-(43-31));
end


function [hui]=parse_AID_HUI(bitstream)
    hui=strings(1,27);
    
    %Get SVN Health bitfield
    SVN_health_aux=bitstream(1:4,:);
    SVN_health_hex=sprintf('%s%s%s%s',SVN_health_aux(4,:),SVN_health_aux(3,:),SVN_health_aux(2,:),SVN_health_aux(1,:));
    hui(1)=sprintf('0x%08s',SVN_health_hex);
    
    %Get UTC parameter A0
    a0_aux=bitstream(5:12,:);
    a0_hex=sprintf('%s%s%s%s%s%s%s%s',a0_aux(8,:),a0_aux(7,:),a0_aux(6,:),a0_aux(5,:),a0_aux(4,:),a0_aux(3,:),a0_aux(2,:),a0_aux(1,:));
    hui(2)=sprintf('0x%016s',a0_hex);
    hui(3)=sprintf("%.11e",hex2num(a0_hex));
    
    %Get UTC parameter A1
    a1_aux=bitstream(13:20,:);
    a1_hex=sprintf('%s%s%s%s%s%s%s%s',a1_aux(8,:),a1_aux(7,:),a1_aux(6,:),a1_aux(5,:),a1_aux(4,:),a1_aux(3,:),a1_aux(2,:),a1_aux(1,:));
    hui(4)=sprintf('0x%016s',a1_hex);
    hui(5)=sprintf("%.11e",hex2num(a1_hex));
    
    %Get UTC reference time
    tow_hex=sprintf('%s%s%s%s',bitstream(24,:),bitstream(23,:),bitstream(22,:),bitstream(21,:));
    hui(7)=sprintf("%d",typecast( uint32( hex2dec(tow_hex) ), 'int32'));
    
    %Get UTC reference week number
    week_hex=sprintf('%s%s',bitstream(26,:),bitstream(25,:));
    hui(6)=sprintf("%d",typecast( uint16( hex2dec(week_hex) ), 'int16'));
    
    %Get delta_tLS
    delta_tLS_hex=sprintf('%s%s',bitstream(28,:),bitstream(27,:));
    hui(8)=sprintf("%d",typecast( uint16( hex2dec(delta_tLS_hex) ), 'int16'));
    
    %Get WNLSF
    WNLSF_hex=sprintf('%s%s',bitstream(30,:),bitstream(29,:));
    hui(9)=sprintf("%d",typecast( uint16( hex2dec(WNLSF_hex) ), 'int16'));
    
    %Get DN
    DN_hex=sprintf('%s%s',bitstream(32,:),bitstream(31,:));
    hui(10)=sprintf("%d",typecast( uint16( hex2dec(DN_hex) ), 'int16'));
    
    %Get delta_tLSF
    delta_tLSF=sprintf('%s%s',bitstream(34,:),bitstream(33,:));
    hui(11)=sprintf("%d",typecast( uint16( hex2dec(delta_tLSF) ), 'int16'));
    
    %Get alpha0
    alpha0_hex=sprintf('%s%s%s%s',bitstream(40,:),bitstream(39,:),bitstream(38,:),bitstream(37,:));
    hui(12)=sprintf('0x%08s',alpha0_hex);
    hui(13)=sprintf("%.11e",typecast(uint32(hex2dec(alpha0_hex)),'single'));
    
    %Get alpha1
    alpha1_hex=sprintf('%s%s%s%s',bitstream(44,:),bitstream(43,:),bitstream(42,:),bitstream(41,:));
    hui(14)=sprintf('0x%08s',alpha1_hex);
    hui(15)=sprintf("%.11e",typecast(uint32(hex2dec(alpha1_hex)),'single'));
    
    %Get alpha2
    alpha2_hex=sprintf('%s%s%s%s',bitstream(48,:),bitstream(47,:),bitstream(46,:),bitstream(45,:));
    hui(16)=sprintf('0x%08s',alpha2_hex);
    hui(17)=sprintf("%.11e",typecast(uint32(hex2dec(alpha2_hex)),'single'));
    
    %Get alpha3
    alpha3_hex=sprintf('%s%s%s%s',bitstream(52,:),bitstream(51,:),bitstream(50,:),bitstream(49,:));
    hui(18)=sprintf('0x%08s',alpha3_hex);
    hui(19)=sprintf("%.11e",typecast(uint32(hex2dec(alpha3_hex)),'single'));
    
    %Get beta0
    beta0_hex=sprintf('%s%s%s%s',bitstream(56,:),bitstream(55,:),bitstream(54,:),bitstream(53,:));
    hui(20)=sprintf('0x%08s',beta0_hex);
    hui(21)=sprintf("%.11e",typecast(uint32(hex2dec(beta0_hex)),'single'));
    
    %Get beta1
    beta1_hex=sprintf('%s%s%s%s',bitstream(60,:),bitstream(59,:),bitstream(58,:),bitstream(57,:));
    hui(22)=sprintf('0x%08s',beta1_hex);
    hui(23)=sprintf("%.11e",typecast(uint32(hex2dec(beta1_hex)),'single'));
    
    %Get beta2
    beta2_hex=sprintf('%s%s%s%s',bitstream(64,:),bitstream(63,:),bitstream(62,:),bitstream(61,:));
    hui(24)=sprintf('0x%08s',beta2_hex);
    hui(25)=sprintf("%.11e",typecast(uint32(hex2dec(beta2_hex)),'single'));
    
    %Get beta3
    beta3_hex=sprintf('%s%s%s%s',bitstream(68,:),bitstream(67,:),bitstream(66,:),bitstream(65,:));
    hui(26)=sprintf('0x%08s',beta3_hex);
    hui(27)=sprintf("%.11e",typecast(uint32(hex2dec(beta3_hex)),'single'));
    
    %consistency check to be done!!
end


function [output_dec,output_hex]=uint2sigint(input)
%UINT2SIGINT converts a binary number to it's signed decimal and
%hexadecimal representation
    
    %Get size of input value for signal expansion
    input_length=size(input,2);
    
    %Perform sign expansion
    if input(1)=='0'
        padding_source='0';
    else
        padding_source='1';
    end
    padding=[];
    
    if input_length == 8
        input_padded=input;
    elseif input_length <16
        
        for i=input_length:15
            padding=[padding,padding_source];
        end
        input_padded=[padding input];
    elseif input_length == 16
        input_padded=input;
    elseif input_length < 32
        for i=input_length:31
            padding=[padding,padding_source];
        end
        input_padded=[padding input];
    else %length==32
        input_padded=input;
    end
    
    if size(input_padded,2) == 8
        output_dec=typecast(uint8(bin2dec(input_padded)),'int8');
    elseif size(input_padded,2) == 16
        output_dec=typecast(uint16(bin2dec(input_padded)),'int16');
    elseif size(input_padded,2) == 32
        output_dec=typecast(uint32(bin2dec(input_padded)),'int32');
    end
    
    output_hex=dec2base(bin2dec(input),16);
    

end