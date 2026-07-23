% yconj_rect.m — devuelve solo el tirante conjugado (sequent depth) de
% Mom_rect.m, para poder usarlo directo dentro de fzero (Octave no
% permite pasarle una funcion con 2 salidas a fzero, y tampoco permite
% llamar a una funcion local definida al pie de un script antes de que
% termine de parsear el script si se usa dentro de un anonymous function
% evaluado en el cuerpo). Entradas/salidas: ver Mom_rect.m.
function yc_ = yconj_rect(y,b,Q)
  [~,yc_] = Mom_rect(y,b,Q);
end
