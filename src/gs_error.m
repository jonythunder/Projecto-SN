% Fun��oo que recebe aposi��o do Satelite em xyz, o pseudorange e a posi��o da Ground Station em xyz. Devolve o erro do pesudo-range para este satelite.
function satellites_prerror = gs_error(sat_pos,pr,base_pos)
r=norm(base_pos-sat_pos);
satellites_prerror=r-pr;
end
