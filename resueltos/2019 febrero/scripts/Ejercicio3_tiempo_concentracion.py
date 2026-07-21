"""
Ejercicio 3 - Examen HHA 7/feb/2019
Tiempo de concentracion de una cuenca de 2.7 km2 (Jose Pedro Varela),
cultivos en linea recta en la parte alta, pasturas en la parte baja,
por dos alternativas:
 1) Flujo NO concentrado (mantiforme, formula NRCS por tramos) en la
    parte alta (progresiva 0-575 m) + flujo concentrado (Ramser-Kirpich)
    en la parte baja (575-2376 m, punto de cierre).
 2) Flujo concentrado (Ramser-Kirpich) en todo el recorrido (0-2376 m).
"""
import math

# Perfil del cauce principal (progresiva m, cota m) - dato del enunciado
prog = [0, 175, 295, 575, 726, 1321, 1850, 2376]
cota = [237, 230, 220, 210, 200, 190, 180, 176]

K = 1.111  # coeficiente de cobertura del suelo (cultivos en linea recta) - sol. oficial

def kirpich(L_km, dH_m):
    S_pct = dH_m/L_km/10
    tc = 0.4*(L_km**0.77)/(S_pct**0.385)
    return tc, S_pct

# ---------- Alternativa 1: mantiforme (0-575) + concentrado (575-2376) ----------
print("=== ALTERNATIVA 1: no concentrado en parte alta + concentrado en parte baja ===")
segmentos_altos = [(0,1),(1,2),(2,3)]  # indices en prog/cota: 0-175,175-295,295-575
suma = 0.0
for i,j in segmentos_altos:
    L_km = (prog[j]-prog[i])/1000
    dH = cota[i]-cota[j]
    S_pct = dH/L_km/10
    termino = K*L_km/math.sqrt(S_pct)
    suma += termino
    print(f"  tramo {prog[i]}-{prog[j]} m: L={L_km:.3f} km, dH={dH} m, S={S_pct:.3f}%, "
          f"K*L/sqrt(S)={termino:.5f}")
Tc1 = 0.91134*suma
print(f"Tc1 (NRCS mantiforme, parte alta) = 0.91134*{suma:.5f} = {Tc1:.4f} hs")

L2_km = (prog[-1]-prog[3])/1000   # 575 a 2376
dH2 = cota[3]-cota[-1]
Tc2, S2 = kirpich(L2_km, dH2)
print(f"\n  tramo {prog[3]}-{prog[-1]} m (parte baja, concentrado): L={L2_km:.3f} km, "
      f"dH={dH2} m, S={S2:.3f}%")
print(f"Tc2 (Ramser-Kirpich, parte baja) = {Tc2:.4f} hs")

Tca = Tc1+Tc2
print(f"\nTca = Tc1+Tc2 = {Tc1:.4f}+{Tc2:.4f} = {Tca:.4f} hs")

# ---------- Alternativa 2: concentrado en todo el recorrido ----------
print("\n=== ALTERNATIVA 2: concentrado en todo el recorrido (0-2376 m) ===")
Ltot_km = (prog[-1]-prog[0])/1000
dHtot = cota[0]-cota[-1]
Tcb, Stot = kirpich(Ltot_km, dHtot)
print(f"L={Ltot_km:.3f} km, dH={dHtot} m, S={Stot:.3f}%")
print(f"Tcb (Ramser-Kirpich, todo concentrado) = {Tcb:.4f} hs")

print("\n=====================================================")
print(f"RESULTADO: Tca (alternativa 1, mixto) = {Tca:.2f} hs")
print(f"           Tcb (alternativa 2, todo concentrado) = {Tcb:.2f} hs")
print("=> Suponer flujo no concentrado en el tramo alto da un tc MAYOR")
print("   (el flujo mantiforme es mas lento que el flujo concentrado equivalente).")
