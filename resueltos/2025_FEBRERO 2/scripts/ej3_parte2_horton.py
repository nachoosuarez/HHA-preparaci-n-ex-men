"""
Ejercicio 3, Parte 2 - Examen HHA 5/feb/2025 (2025_FEBRERO 2)
Tiempo de encharcamiento (Horton) para el evento de precipitacion registrado
en la cuenca, y esquema de tasa de infiltracion / intensidad de lluvia vs
tiempo, con los volumenes de infiltracion acumulada y de escurrimiento.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ---------- Datos ----------
# Hietograma (bloques de 10 min)
P_mm   = np.array([2.2, 6.0, 11.1, 4.6, 3.3, 1.8])   # mm por bloque de 10 min
t0_min = np.array([0, 10, 20, 30, 40, 50])            # inicio de cada bloque (min)
dt_min = 10.0
i_mmh  = P_mm/(dt_min/60)                             # intensidad media de cada bloque (mm/h)

# Horton
f0 = 44.0   # mm/h
fc = 11.0   # mm/h
K  = 2.55   # 1/h

def f_horton(t_h):
    """Capacidad de infiltracion de Horton (mm/h), t en horas desde el inicio de la lluvia."""
    return fc + (f0-fc)*np.exp(-K*t_h)

print("Bloque  t(min)   P(mm)   i(mm/h)   f(t_ini)(mm/h)")
for k in range(6):
    tt = t0_min[k]/60
    print(f"  {k+1}     {t0_min[k]:5.0f}   {P_mm[k]:5.1f}   {i_mmh[k]:7.2f}      {f_horton(tt):7.2f}")

# ---------- 2.1) Tiempo de encharcamiento ----------
# Se compara, al inicio de cada bloque, la intensidad de lluvia con la
# capacidad de infiltracion de Horton evaluada en el tiempo transcurrido
# desde el inicio de la lluvia (hipotesis simple: sin corregir tiempo por
# encharcamiento tardio, valida porque el encharcamiento ocurre apenas
# comienza el bloque 2).
t_ench = None
for k in range(6):
    tt = t0_min[k]/60
    f_t = f_horton(tt)
    if i_mmh[k] > f_t:
        t_ench = t0_min[k]
        f_ench = f_t
        i_ench = i_mmh[k]
        break

print(f"\n--- TIEMPO DE ENCHARCAMIENTO ---")
print(f"En t={t_ench:.0f} min: i={i_ench:.2f} mm/h > f(t)={f_ench:.2f} mm/h => comienza el encharcamiento")
print(f"\nTiempo de encharcamiento t_ench = {t_ench:.0f} min")

# ---------- 2.2) Volumenes de infiltracion acumulada y de escorrentia ----------
# Antes del encharcamiento (bloque 1): toda la lluvia infiltra (i<f0 siempre).
# Entre t_ench y el bloque donde la intensidad vuelve a ser menor que f(t)
# (aqui, el bloque 6, ya que f(t)>=fc=11mm/h > i6=10.8mm/h): infiltracion
# a capacidad, integrando f(t) analitricamente.
# En el/los bloque(s) donde i<f(t) (bloque 1 y bloque 6 en este caso):
# infiltra toda la lluvia de esos bloques (limitado por lluvia, no por
# capacidad).

# Verificacion de qué bloques son capacidad-limitados (ponded) y cuales no:
capacity_limited = []
for k in range(6):
    tt = t0_min[k]/60
    capacity_limited.append(i_mmh[k] > f_horton(tt))
print(f"\nBloques capacidad-limitados (encharcados): {[k+1 for k,v in enumerate(capacity_limited) if v]}")
print(f"Bloques limitados por la lluvia (toda la lluvia infiltra): {[k+1 for k,v in enumerate(capacity_limited) if not v]}")

# Integral de f(t) entre el primer y ultimo bloque capacidad-limitado (10 a 50 min)
t1_h = 10/60
t2_h = 50/60
V_ponded = fc*(t2_h-t1_h) + (f0-fc)/K*(np.exp(-K*t1_h)-np.exp(-K*t2_h))

V_bloque1 = P_mm[0]   # 2.2 mm, infiltra completo (antes del encharcamiento)
V_bloque6 = P_mm[5]   # 1.8 mm, infiltra completo (i6 < f(t) siempre)

Vinf = V_bloque1 + V_ponded + V_bloque6
Ptotal = P_mm.sum()
Vesc = Ptotal - Vinf

print(f"\nV_infiltrado bloque 1 (0-10min, sin encharcar)   = {V_bloque1:.3f} mm")
print(f"V_infiltrado capacidad (10-50min, integral Horton) = {V_ponded:.3f} mm")
print(f"V_infiltrado bloque 6 (50-60min, i<f, sin encharcar)= {V_bloque6:.3f} mm")
print(f"\nVOLUMEN DE INFILTRACION ACUMULADA Vinf = {Vinf:.3f} mm")
print(f"Precipitacion total del evento = {Ptotal:.3f} mm")
print(f"VOLUMEN DE ESCORRENTIA Vesc = Ptotal - Vinf = {Ptotal:.1f} - {Vinf:.2f} = {Vesc:.3f} mm")

# ---------- Grafico: tasa de infiltracion e intensidad vs tiempo ----------
t_plot = np.linspace(0, 60, 601)  # min
f_plot = f_horton(t_plot/60)

fig, ax = plt.subplots(figsize=(9,5.5))
# escalon de intensidad de lluvia (funcion escalonada)
for k in range(6):
    ax.bar(t0_min[k]+dt_min/2, i_mmh[k], width=dt_min, color='steelblue', alpha=0.5,
           edgecolor='k', align='center', label='Intensidad de lluvia i(t)' if k==0 else None)
ax.plot(t_plot, f_plot, 'r-', linewidth=2.2, label='Capacidad de infiltracion f(t) (Horton)')
ax.axvline(t_ench, color='g', linestyle='--', linewidth=1.5, label=f'Tiempo de encharcamiento (t={t_ench:.0f} min)')
ax.set_xlabel('t (min)')
ax.set_ylabel('mm/h')
ax.set_title('Ejercicio 3 - Intensidad de lluvia y capacidad de infiltracion de Horton')
ax.grid(True, alpha=0.4)
ax.legend(loc='upper right')
ax.set_xlim(0,60)
plt.tight_layout()
plt.savefig('ej3_horton_infiltracion.png', dpi=120)
print("\nGrafico guardado en ej3_horton_infiltracion.png")
