% Funçãoo que recebe aposição do Satelite em xyz, o pseudorange e a posição da Ground Station em xyz. Devolve o erro do pesudo-range para este satelite.
function satellites_prerror = gs_error(sat_pos,pr,base_pos)
for i=1:size(sat_pos,1)
    for j=1:size(pr,1)
        if sat_pos(i,1) == pr(j,1)
            r=[sat_pos(i,1),norm(base_pos-sat_pos(2:4))];
            satellites_prerror(i,:)=[sat_pos(i,1),r(2)-pr(j,2)];
            end
    end
end
end

           