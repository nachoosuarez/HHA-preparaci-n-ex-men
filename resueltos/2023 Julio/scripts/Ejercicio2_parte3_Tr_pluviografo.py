"""
Ejercicio 2, Parte 3 - Examen HHA 24/jul/2023
Periodo de retorno de la intensidad maxima de precipitacion registrada en
un pluviografo durante el evento (bloque de 15.3 mm en 7 min, el mayor
del hietograma observado de la Parte 2).

Se invierte la relacion IDF de Uruguay: dado un punto (d, P) YA REGISTRADO
(no una tormenta de diseno sobre un area), se despeja CT = P/(P310*CD(d))
(CA=1, es un dato puntual del pluviografo, no hay area que promediar) y se
invierte numericamente CT(Tr) (fzero/biseccion, no tiene forma cerrada).
"""
import math

def brentq(f, a, b, tol=1e-10):
    fa, fb = f(a), f(b)
    for _ in range(200):
        m = (a+b)/2
        fm = f(m)
        if abs(fm) < tol:
            return m
        if (fa < 0) == (fm < 0):
            a, fa = m, fm
        else:
            b, fb = m, fm
    return (a+b)/2

P310 = 80.0     # mm, dato del enunciado
d_h = 7/60      # horas, duracion del bloque de mayor intensidad
P_obs = 15.3    # mm, precipitacion de ese bloque (pluviografo)

def CD(d):
    if d <= 3:
        return 0.6208*d/((d+0.0137)**0.5639)
    else:
        return 1.0287*d/((d+1.0293)**0.8083)

def CT(Tr):
    return 0.5786 - 0.4312*math.log10(math.log(Tr/(Tr-1)))

CD_d = CD(d_h)
print(f"d = {d_h*60:.0f} min = {d_h:.4f} hs ; CD(d) = {CD_d:.4f}")

CT_target = P_obs/(P310*CD_d)   # CA=1 (dato puntual, sin correccion por area)
print(f"CT objetivo = P_obs/(P310*CD*CA) = {P_obs}/({P310}*{CD_d:.4f}*1) = {CT_target:.4f}")

Tr = brentq(lambda x: CT(x)-CT_target, 1.001, 500)
print(f"\nTr (invirtiendo CT(Tr)=CT objetivo, fzero) = {Tr:.3f} anios")
