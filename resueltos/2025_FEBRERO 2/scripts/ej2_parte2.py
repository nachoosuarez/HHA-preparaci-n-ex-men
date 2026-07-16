"""
Ejercicio 2, Parte 2 - Examen HHA 5/feb/2025 (2025_FEBRERO 2)
Volumen de escorrentia del evento de diseño (Tr=10, uso de suelo actual) y
grafico del hidrograma resultante, con Qmax y tiempo pico.
Reutiliza los resultados guardados por ej2_parte1.py (part1.npz).
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

d = np.load('part1.npz')
t = d['t']; Qtot = d['Qtot']
Qmax = float(d['Qmax_NRCS']); tQmax = float(d['tQmax'])
Vesc_m3 = float(d['Vesc_m3'])

print(f"Volumen de escorrentia del evento de diseño = {Vesc_m3:.0f} m3")
print(f"Caudal maximo (pico del hidrograma)          = {Qmax:.2f} m3/s")
print(f"Tiempo al pico (desde el inicio de la tormenta) = {tQmax:.3f} hs = {tQmax*60:.1f} min")

# verificacion cruzada: integrar el hidrograma (regla trapezoidal) en m3 y
# comparar con el volumen de precipitacion efectiva acumulada (deben coincidir)
V_integrado = np.trapezoid(Qtot, t*3600)   # t en hs -> s
print(f"\nVerificacion: volumen integrado del hidrograma Q(t) = {V_integrado:.0f} m3 "
      f"(vs. Vesc por Pe = {Vesc_m3:.0f} m3, diferencia {100*(V_integrado/Vesc_m3-1):.2f}%)")

plt.figure(figsize=(9,5))
plt.plot(t, Qtot, 'b-', linewidth=2)
plt.plot(tQmax, Qmax, 'ro', markersize=8)
plt.annotate(f'Qp={Qmax:.1f} m3/s\ntp={tQmax:.2f} hs', xy=(tQmax, Qmax),
             xytext=(tQmax+0.3, Qmax*0.85),
             arrowprops=dict(arrowstyle='->'))
plt.xlabel('t (hs) desde el inicio de la tormenta de diseño')
plt.ylabel('Q (m3/s)')
plt.title('Ejercicio 2 - Hidrograma de diseño (Tr=10 años, uso de suelo actual)')
plt.grid(True)
plt.tight_layout()
plt.savefig('ej2_hidrograma_parte2.png', dpi=120)
print("\nGrafico guardado en ej2_hidrograma_parte2.png")
