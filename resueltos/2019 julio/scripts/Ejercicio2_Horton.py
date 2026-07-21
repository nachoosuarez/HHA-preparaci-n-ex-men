"""
Ejercicio 2 - Examen HHA 22/jul/2019

1) Definicion de tiempo de encharcamiento de una cuenca.
2) Cuenca de 5.3 km2, Lcp=2.3km, dH=45m. Evento de precipitacion en
   bloques de 30 min (0-30,30-60,60-90,90-120,120-150,150-180 min):
   P = 3, 5, 31, 6, 3, 1 mm.
   Modelo de Horton: f0=7.6 mm/h, fc=0.4 mm/h, k=0.5 1/h.
   a) tiempo de encharcamiento del evento.
   b) evolucion temporal de la tasa de infiltracion REAL (graficar).
   c) volumen de escorrentia (mm).

Metodologia (Resumen Teorico B8, "Infiltracion de Horton y tiempo de
encharcamiento"): se compara, al INICIO de cada bloque, la intensidad
media del bloque I con la capacidad de infiltracion f(t) evaluada en
ese instante. Mientras I(t)<f(t): el bloque es "lluvia-limitado" (toda
la lluvia infiltra, tasa real=I). Desde el primer bloque donde I(t)>=f(t)
en adelante: el bloque es "capacidad-limitado" (infiltra a la tasa
f(t), integrada analiticamente en el intervalo; el resto escurre).
Mismo patron que resueltos/2023 febrero_2/scripts/ej2.py (parte 2.2),
generalizado acá a calcular ademas el volumen infiltrado total (b) y el
volumen de escorrentia por balance simple (c) — B7/B8 del Resumen
Teorico. No requiere ningun toolkit de Octave (formula cerrada de
Horton, sin geometria de canal ni cuenca de por medio).
"""
import math

print("=== 1) Definicion de tiempo de encharcamiento ===")
print("Lapso de tiempo entre el inicio de la lluvia y el instante en que el")
print("agua comienza a encharcar en la superficie del terreno, a partir del")
print("cual la intensidad de precipitacion supera la tasa de infiltracion")
print("potencial del suelo (Resumen Teorico B8).\n")

print("=== 2) Datos del evento e infiltracion de Horton ===")
f0 = 7.6   # mm/h
fc = 0.4   # mm/h
k  = 0.5   # 1/h

def f(t):
    return fc + (f0 - fc) * math.exp(-k * t)

# bloques: (t_ini_h, t_fin_h, P_mm)
bloques = [(0.0, 0.5, 3.0), (0.5, 1.0, 5.0), (1.0, 1.5, 31.0),
           (1.5, 2.0, 6.0), (2.0, 2.5, 3.0), (2.5, 3.0, 1.0)]
dt = 0.5

print(f"{'t_ini(h)':>9} | {'P(mm)':>6} | {'I=P/dt(mm/h)':>13} | {'f(t_ini)(mm/h)':>15} | Estado")
t_enc = None
for (t_ini, t_fin, P) in bloques:
    I = P / dt
    ft = f(t_ini)
    encharca = I >= ft
    estado = 'CAPACIDAD-LIMITADO (I>=f)' if encharca else 'lluvia-limitado (I<f)'
    print(f"{t_ini:9.1f} | {P:6.1f} | {I:13.2f} | {ft:15.2f} | {estado}")
    if encharca and t_enc is None:
        t_enc = t_ini

print(f"\n=== 2.a) Tiempo de encharcamiento: t_enc = {t_enc:.1f} hs ===")
print("(bloque 0-0.5h: I=6.0 mm/h < f(0)=7.6 mm/h -> no encharca todavia;")
print(" bloque 0.5-1h: I=10.0 mm/h >= f(0.5)=6.0 mm/h -> ENCHARCA desde t=0.5h)")
print("\nNota: una vez que ocurre el encharcamiento, se adopta la convencion")
print("estandar del curso (ver solucion oficial, grafico manuscrito) de que")
print("el suelo queda 'capacidad-limitado' el resto del evento (tasa real=f(t))")
print("aun en el ultimo bloque (2.5-3.0h), donde I=2.0<f(2.5)=2.46 mm/h: no se")
print("revierte a lluvia-limitado por una caida puntual de intensidad, porque")
print("ya hay agua encharcada en superficie infiltrando a la capacidad del suelo.")

print("\n=== 2.b) Evolucion temporal de la tasa de infiltracion real ===")
print(f"{'t_ini(h)':>9} | {'Infiltracion real (mm/h)':>25}")
real_rate = []
for (t_ini, t_fin, P) in bloques:
    I = P / dt
    if t_ini < t_enc:
        tasa = I                      # lluvia-limitado: infiltra el 100% de la lluvia
    else:
        tasa = f(t_ini)                # capacidad-limitado: infiltra a la tasa f(t)
    real_rate.append((t_ini, t_fin, tasa))
    print(f"{t_ini:9.1f} | {tasa:25.2f}")

print("\n=== 2.c) Volumen de escorrentia ===")
Ptot = sum(P for (_, _, P) in bloques)
Vinf = 0.0
print(f"{'bloque (h)':>12} | {'tipo':>18} | {'Inf. bloque (mm)':>17}")
for (t_ini, t_fin, P) in bloques:
    I = P / dt
    if t_ini < t_enc:
        inf_bloque = I * dt            # = P (lluvia-limitado: infiltra toda la lluvia)
        tipo = 'lluvia-limitado'
    else:
        # integral analitica de f(t) entre t_ini y t_fin (capacidad-limitado)
        inf_bloque = fc * (t_fin - t_ini) + (f0 - fc) / k * (math.exp(-k * t_ini) - math.exp(-k * t_fin))
        tipo = 'capacidad-limitado'
    Vinf += inf_bloque
    print(f"{t_ini:4.1f}-{t_fin:<6.1f} | {tipo:>18} | {inf_bloque:17.3f}")

Vesc = Ptot - Vinf
print(f"\nP total = {Ptot:.1f} mm ; Infiltracion total = {Vinf:.2f} mm")
print(f"Vesc = P_total - Inf_total = {Ptot:.1f} - {Vinf:.2f} = {Vesc:.2f} mm")
print(f"\n=== RESULTADO 2.c) Vesc = {Vesc:.1f} mm ===")

# --- grafico de la tasa de infiltracion real ---
try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import numpy as np

    fig, ax = plt.subplots(figsize=(7, 4.5))
    # curva f(t) continua de referencia (solo a partir de t_enc tiene sentido fisico como tasa real)
    tt = np.linspace(0, 3, 300)
    ax.plot(tt, [f(t) for t in tt], 'gray', linestyle='--', linewidth=1, label='f(t) (capacidad potencial, Horton)')
    # tasa real: escalon en el primer bloque (lluvia-limitado), luego f(t) desde t_enc
    for (t_ini, t_fin, tasa) in real_rate:
        if t_ini < t_enc:
            ax.plot([t_ini, t_fin], [tasa, tasa], 'b-', linewidth=2.5)
    tt2 = np.linspace(t_enc, 3, 200)
    ax.plot(tt2, [f(t) for t in tt2], 'b-', linewidth=2.5, label='Infiltracion real')
    for (t_ini, t_fin, tasa) in real_rate:
        ax.plot(t_ini, tasa, 'ko', markersize=4)
    ax.axvline(t_enc, color='r', linestyle=':', label=f'tenc={t_enc:.1f} h')
    ax.set_xlabel('t (h)')
    ax.set_ylabel('Tasa de infiltracion real (mm/h)')
    ax.set_title('Ejercicio 2 - Evolucion temporal de la infiltracion real')
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('infiltracion_real.png', dpi=120)
    print("\nGrafico guardado en infiltracion_real.png")
except ImportError:
    print("\n(matplotlib no disponible, se omite el grafico)")
