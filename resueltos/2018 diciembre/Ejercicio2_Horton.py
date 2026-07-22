"""
Ejercicio 2, parte final (encharcamiento) - Examen HHA 17/dic/2018

Cuenca San Fructuoso (Rio Negro). Tormenta dada como hietograma de
INTENSIDADES en bloques de 0.25 h (no como lamina P a repartir):
T(h):      0-0.25  0.25-0.5  0.5-0.75  0.75-1  1-1.25  1.25-1.5  1.5-1.75  1.75-2  2-2.25  2.25-2.5
I(mm/h):     5        10        15       10       5        1        0.5      0.3     0.1     0.05

Modelo de Horton: f0=24 mm/h, fc=4.4 mm/h, k=2.5 1/h.
Pregunta: tiempo de encharcamiento de la tormenta.

Metodologia (RESUMEN_TEORICO.md B8): se compara, al INICIO de cada
bloque, la intensidad del bloque I (aqui dada directamente, no hay que
dividir P/dt) contra la capacidad de infiltracion de Horton f(t)
evaluada en ese instante. El primer bloque con I(t_ini) >= f(t_ini) es
el bloque de encharcamiento -> t_enc = t_ini de ese bloque. Mismo patron
que resueltos/2019 julio/scripts/Ejercicio2_Horton.py y
resueltos/2023 febrero_2/scripts/ej2.py.
"""
import math

f0 = 24.0   # mm/h
fc = 4.4    # mm/h
k = 2.5     # 1/h


def f(t):
    return fc + (f0 - fc) * math.exp(-k * t)


# bloques: (t_ini_h, t_fin_h, I_mm_h)  -- intensidad dada directamente por el enunciado
bloques = [
    (0.00, 0.25, 5.0),
    (0.25, 0.50, 10.0),
    (0.50, 0.75, 15.0),
    (0.75, 1.00, 10.0),
    (1.00, 1.25, 5.0),
    (1.25, 1.50, 1.0),
    (1.50, 1.75, 0.5),
    (1.75, 2.00, 0.3),
    (2.00, 2.25, 0.1),
    (2.25, 2.50, 0.05),
]

print("=== Infiltracion de Horton: f(t) = fc + (f0-fc)*exp(-k*t) ===")
print(f"f0={f0} mm/h, fc={fc} mm/h, k={k} 1/h\n")

print(f"{'t_ini(h)':>9} | {'I bloque(mm/h)':>15} | {'f(t_ini)(mm/h)':>15} | Estado")
t_enc = None
for (t_ini, t_fin, I) in bloques:
    ft = f(t_ini)
    encharca = I >= ft
    estado = 'CAPACIDAD-LIMITADO (I>=f) -> ENCHARCA' if encharca else 'lluvia-limitado (I<f)'
    print(f"{t_ini:9.2f} | {I:15.2f} | {ft:15.2f} | {estado}")
    if encharca and t_enc is None:
        t_enc = t_ini

print(f"\n=== RESULTADO: tiempo de encharcamiento t_enc = {t_enc:.2f} h = {t_enc*60:.0f} min ===")
