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
            end
            hui=0;
            if i>=i_max
                stop=0;
            end
            
            %disp(bitstream(i:i+message_length-1,:))
            i=i+message_length;
        end %Pode ser substituido por um incremento do indice de bitstream se
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
        raw(1,13+10*(N-1))=sprintf("%.11e",hex2num(do_hex));
        
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
    eph(9)=sprintf('0x%02s',dec2base(str2double(eph(10)),16));
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
    eph(20)=sprintf('0x%04s',dec2base(str2double(eph(21)),16));
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
    eph(30)=bin2dec(af0_bin(2:end))*(-1)^af0_bin(1);
    eph(29)=sprintf('0x%06s',dec2base(bin2dec(af0_bin),16));
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
    eph(69)=bin2dec(crs_bin(2:end))*(-1)^crs_bin(1);
    eph(68)=sprintf('0x%04s',dec2base(bin2dec(crs_bin),16));
    eph(70)=sprintf("%.11e",str2double(eph(69))*2^-31);

    
    %Word 4
    word_hex_aux=bitstream(45:48,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get delta_n
    delta_n_bin=word_bin(1:16);
    eph(36)=bin2dec(delta_n_bin(2:end))*(-1)^delta_n_bin(1);
    eph(35)=sprintf('0x%04s',dec2base(bin2dec(delta_n_bin),16));
    %Convert semicircles/s to radians/s
    
    eph(37)=sprintf("%.11e",str2double(delta_n_aux)*2^-43);
    %Get first 8 bits of M0
    M0_bin_aux=word_bin(17:24);
    
    %Word 5
    word_hex_aux=bitstream(49:52,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get last 24 bits of M0
    M0_bin=[M0_bin_aux,word_bin(1:24)];
    eph(39)=bin2dec(M0_bin(2:end))*(-1)^M0_bin(1);
    eph(38)=sprintf('0x%08s',dec2base(bin2dec(M0_bin),16));
    eph(40)=sprintf("%.11e",str2double(eph(39))*2^-31);
    
    %Word 6
    word_hex_aux=bitstream(53:56,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get Cuc
    cuc_bin=word_bin(1:16);
    eph(60)=bin2dec(cuc_bin(2:end))*(-1)^cuc_bin(1);
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
    eph(41)=sprintf('0x%08s',dec2base(str2double(eph(42)),16));
    eph(43)=sprintf("%.11e",str2double(eph(42))*2^-33);
    
    
    %Word 8
    word_hex_aux=bitstream(61:64,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get Cus
    cus_bin=word_bin(1:16);
    eph(63)=bin2dec(cus_bin(2:end))*(-1)^cus_bin(1);
    eph(62)=sprintf('0x%04s',dec2base(bin2dec(cus_bin),16));
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
    eph(32)=sprintf('0x%08s',dec2base(str2double(eph(33)),16));
    eph(34)=sprintf("%.11e",str2double(eph(33))*2^-19);
    
    
    %Word 10
    word_hex_aux=bitstream(69:72,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get toe
    toe_bin=word_bin(1:16);
    eph(6)=bin2dec(toe_bin);
    eph(5)=sprintf('0x%04s',dec2base(str2double(eph(6)),16));
    eph(7)=sprintf("%d",str2double(eph(6))*2^4);
    %Get fit interval flag
    eph(8)=word_bin(17);
    %Get AODO
    aodo_bin=word_bin(18:22);
    eph(78)=bin2dec(aodo_bin);
    eph(77)=sprintf('0x%03s',dec2base(str2double(eph(78)),16));
    eph(79)=sprintf("%d",str2double(eph(78))*9000);
    
    
    %--Subframe 3--%
    %Word 3
    word_hex_aux=bitstream(73:76,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get Cic
    cic_bin=word_bin(1:16);
    eph(72)=bin2dec(cic_bin);
    eph(71)=sprintf('0x%04s',dec2base(str2double(eph(72)),16));
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
    eph(54)=bin2dec(omega0_bin(2:end))*(-1)^omega0_bin(1);
    eph(53)=sprintf('0x%08s',dec2base(bin2dec(omega0_bin),16));
    eph(55)=sprintf("%.11e",str2double(eph(54))*2^-31);
    
    %Word 5
    word_hex_aux=bitstream(81:84,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get Cis
    cis_bin=word_bin(1:16);
    eph(75)=bin2dec(cis_bin(2:end))*(-1)^cis_bin(1);
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
    eph(48)=bin2dec(i0_bin(2:end))*(-1)^i0_bin(1);
    eph(47)=sprintf('0x%08s',dec2base(bin2dec(i0_bin),16));
    eph(49)=sprintf("%.11e",str2double(eph(48))*2^-31);
    
    %Word 7
    word_hex_aux=bitstream(89:92,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get Crc
    crc_bin=word_bin(1:16);
    eph(66)=bin2dec(crc_bin(2:end))*(-1)^crc_bin(1);
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
    eph(45)=bin2dec(argper_bin);
    eph(44)=sprintf('0x%08s',dec2base(str2double(eph(45)),16));
    eph(46)=sprintf("%.11e",str2double(eph(45))*2^-31);
    
    %Word 9
    word_hex_aux=bitstream(97:100,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %get OmegaDot
    OmegaDot_bin=word_bin(1:24);
    eph(57)=bin2dec(OmegaDot_bin(2:end))*(-1)^OmegaDot_bin(1);
    eph(56)=sprintf('0x%06s',dec2base(bin2dec(OmegaDot_bin),16));
    eph(58)=sprintf("%.11e",str2double(eph(57))*2^-43);
    
    %Word 10
    word_hex_aux=bitstream(101:104,:);
    word_hex=sprintf('%s%s%s%s',word_hex_aux(4,:),word_hex_aux(3,:),word_hex_aux(2,:),word_hex_aux(1,:));
    word_aux=hex2dec(word_hex);
    word_bin=dec2bin(word_aux,24);
    %Get IODE SF3
    eph(3)=bin2dec(word_bin(1:8));
    %Get IDOT
    IDOT_bin=word_bin(9:24);
    eph(51)=bin2dec(IDOT_bin(2:end))*(-1)^IDOT_bin(1);
    eph(50)=sprintf('0x%04s',dec2base(bin2dec(IDOT_bin),16));
    eph(52)=sprintf("%.11e",str2double(eph(51))*2^-43);
    
    
    
    

end