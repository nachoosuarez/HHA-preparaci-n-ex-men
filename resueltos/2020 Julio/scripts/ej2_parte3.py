"""
Ejercicio 2, Parte 3 - Examen HHA 7/jul/2020
Con las condiciones de uso de suelo de la Parte 2 (Aurb_max=0.896 km2
urbanizado, resto pastizal), se registra en un pluviografo de la cuenca un
evento con intensidad constante i=77 mm/h durante 60 minutos, uniforme en
el area.
3.1) Determinar si la alcantarilla (disenada para Tr=5, Qdis=50.13 m3/s,
     ej2_parte1.py) fue sobrepasada.
3.2) Determinar el periodo de retorno del evento registrado.
"""
import math

# ---------- datos ----------
Area_km2 = 7.3
Aurb_max = 0.8959
C_past = 0.36
C_urban = 0.80
Q_diseno = 50.130   # de ej2_parte1.py (metodo racional, adoptado)
tc_hs = 0.6050
P310 = 100.0

def CD(d):
    if d <= 3:
        return 0.6208*d/((d+0.0137)**0.5639)
    else:
        return 1.0287*d/((d+1.0293)**0.8083)

def CT(Tr):
    return 0.5786 - 0.4312*math.log10(math.log(Tr/(Tr-1)))

def CA(d, Ac_km2):
    return 1 - (0.3549*(d**-0.4272))*(1-math.exp(-0.005792*Ac_km2))

# ---------- 3.1: caudal del evento observado ----------
print("=== 3.1: Q del evento observado ===")
i_event = 77.0   # mm/h
d_event = 1.0    # hs (60 min)
print(f"d_event={d_event} h > tc={tc_hs} h => toda la cuenca aporta simultaneamente,")
print("la formula racional Q=C*i*A/360 sigue siendo valida con la intensidad REAL")
print("del evento (no hace falta pasar por la IDF de diseno).")

C_mixed = (C_urban*Aurb_max + C_past*(Area_km2-Aurb_max))/Area_km2
Ac_ha = Area_km2*100
Q_event = C_mixed*i_event*Ac_ha/360
print(f"\nC ponderado (con Aurb_max de la Parte 2) = {C_mixed:.4f}")
print(f"Q_event = C*i*A/360 = {Q_event:.3f} m3/s")
print(f"Q_diseno (capacidad de la obra, Parte 1) = {Q_diseno:.3f} m3/s")
print(f"=> {'SI' if Q_event>Q_diseno else 'NO'} fue sobrepasada la alcantarilla "
      f"({100*(Q_event/Q_diseno-1):.1f}% por encima de la capacidad de diseno)")

# ---------- 3.2: periodo de retorno del evento ----------
print("\n=== 3.2: Periodo de retorno del evento ===")
P_event = i_event*d_event
CD1 = CD(d_event)
CA1 = CA(d_event, Area_km2)
print(f"P_event = i*d = {P_event:.1f} mm")
print(f"CD(d=1h) = {CD1:.4f}")
print("Se usa CA=1 porque el dato es de un pluviografo puntual de la cuenca, no una",
      "lluvia de diseno de area (mismo criterio que en otros examenes, ver",
      "RESUMEN_TEORICO.md S B3).")

CT_needed = P_event/(P310*CD1*1.0)
print(f"CT necesario = P_event/(P310*CD*CA) = {CT_needed:.4f}")

lo, hi = 1.001, 1000
for _ in range(200):
    mid = (lo+hi)/2
    if (CT(lo)-CT_needed)*(CT(mid)-CT_needed) <= 0:
        hi = mid
    else:
        lo = mid
Tr_sol = (lo+hi)/2
print(f"Tr = {Tr_sol:.2f} anios")
for Trc in [30,35,36,40]:
    print(f"  check Tr={Trc}: CT={CT(Trc):.4f}, P={P310*CD1*CT(Trc):.2f} mm")
