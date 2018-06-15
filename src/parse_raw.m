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
        
        %Compute the checksum - NOT WORKING
%         CK_A = 0;
%         CK_B = 0;
%         for j=2:message_length-2
%             CK_A=CK_A + hex2dec(bitstream(i+j,:));
%             CK_B=CK_B+CK_A;
%         end
%         
%         CK_A=dec2hex(CK_A)
%         CK_B=dec2hex(CK_B)
% %         For(I=0;I<N;I++)
% %         {
% %             CK_A = CK_A + Buffer[I]
% %             CK_B = CK_B + CK_A
% %             }
        
        %Decode the message
        if strcmp(bitstream(i+2:i+3,:),['02';'10']) %If RXM-RAW message
            raw(n1,:)=parse_RXM_RAW(bitstream(i+6:i+message_length-2,:));
            n1=n1+1;
        end
        eph=0;
        hui=0;
            
        
        %disp(i)
        %disp(message_length);
        %disp(bitstream(i:i+message_length-1,:))
        i=i+message_length;
        if i==5034993
            i=5034993;
        end
        if i>=i_max
            stop=0;
        end
        
        %disp(bitstream(i:i+1,:))
    end %Pode ser substituido por um incremento do indice de bitstream se 
        %não encontrar o bloco de sync
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