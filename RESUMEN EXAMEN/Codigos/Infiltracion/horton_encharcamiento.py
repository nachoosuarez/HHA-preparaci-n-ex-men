"""
Infiltracion de Horton: tiempo de encharcamiento, evolucion de la tasa
real de infiltracion y volumen de escorrentia de un evento de lluvia en
bloques.

Que hace: dado un hietograma en bloques de duracion fija (cada bloque
con su intensidad media I en mm/h, o su lamina P en mm) y los 3
parametros del modelo de Horton (f0, fc, k), calcula:
  1) el tiempo de encharcamiento t_enc (primer bloque donde la
     intensidad supera la capacidad de infiltracion del suelo);
  2) la tasa de infiltracion REAL bloque a bloque (I si el bloque es
     lluvia-limitado, f(t) integrada si es capacidad-limitado);
  3) el volumen total infiltrado y el volumen de escorrentia del evento
     (balance simple Vesc = P_total - Vinf).

Que entradas pide: f0 (mm/h, capacidad inicial), fc (mm/h, capacidad
final/asintotica), k (1/h, constante de decaimiento), y la lista de
bloques (t_ini, t_fin, valor), donde `valor` puede ser la intensidad I
del bloque (mm/h) o su lamina P (mm) segun el enunciado -- ver el
parametro `bloques_en` de encharcamiento().

Que tipo de ejercicio resuelve: "definir/calcular tiempo de
encharcamiento de una cuenca/evento", "evolucion temporal de la
infiltracion real (graficar)", "volumen de escorrentia de un evento con
modelo de Horton". Ver RESUMEN EXAMEN/Teorico/RESUMEN_TEORICO.md §B8.

Convencion del curso (validada contra 3 soluciones oficiales: 2019 jul,
2023 feb 2, 2018 dic): una vez que un bloque encharca (I>=f(t_ini)), el
resto del evento se trata como capacidad-limitado (tasa real=f(t)) aunque
la intensidad vuelva a caer por debajo de f(t) en un bloque posterior --
no se revierte a lluvia-limitado por una caida puntual de intensidad.
"""
import math


def f_horton(t, f0, fc, k):
    """Capacidad de infiltracion de Horton en el instante t (horas)."""
    return fc + (f0 - fc) * math.exp(-k * t)


def encharcamiento(bloques, f0, fc, k, bloques_en='I'):
    """
    bloques: lista de tuplas (t_ini_h, t_fin_h, valor), en orden creciente
             de t_ini y todas con la MISMA duracion dt.
    bloques_en: 'I' si `valor` es la intensidad media del bloque (mm/h);
                'P' si `valor` es la lamina de lluvia del bloque (mm)
                (se divide por dt para obtener I).

    Devuelve un dict con:
      t_enc      : tiempo de encharcamiento (h), o None si no encharca
      tabla      : lista de (t_ini, I, f(t_ini), encharca_bool)
      tasa_real  : lista de (t_ini, t_fin, tasa_mm_h) -- parte 2
      Vinf, Vesc, Ptot : balance del evento (mm) -- parte 3
    """
    dt = bloques[0][1] - bloques[0][0]

    tabla = []
    t_enc = None
    for (t_ini, t_fin, valor) in bloques:
        I = valor if bloques_en == 'I' else valor / dt
        ft = f_horton(t_ini, f0, fc, k)
        encharca = I >= ft
        tabla.append((t_ini, I, ft, encharca))
        if encharca and t_enc is None:
            t_enc = t_ini

    tasa_real = []
    Vinf = 0.0
    Ptot = 0.0
    for (t_ini, t_fin, valor) in bloques:
        I = valor if bloques_en == 'I' else valor / dt
        Ptot += I * dt
        capacidad_limitado = (t_enc is not None) and (t_ini >= t_enc)
        if capacidad_limitado:
            # integral analitica de f(t) entre t_ini y t_fin
            inf_bloque = fc * (t_fin - t_ini) + (f0 - fc) / k * (
                math.exp(-k * t_ini) - math.exp(-k * t_fin))
            tasa = f_horton(t_ini, f0, fc, k)
        else:
            inf_bloque = I * dt
            tasa = I
        Vinf += inf_bloque
        tasa_real.append((t_ini, t_fin, tasa))

    return {
        't_enc': t_enc,
        'tabla': tabla,
        'tasa_real': tasa_real,
        'Vinf': Vinf,
        'Vesc': Ptot - Vinf,
        'Ptot': Ptot,
    }


if __name__ == '__main__':
    # ==== EJEMPLO (Examen 2018 diciembre, Ejercicio 2 parte final) ====
    f0, fc, k = 24.0, 4.4, 2.5
    bloques = [
        (0.00, 0.25, 5.0), (0.25, 0.50, 10.0), (0.50, 0.75, 15.0),
        (0.75, 1.00, 10.0), (1.00, 1.25, 5.0), (1.25, 1.50, 1.0),
        (1.50, 1.75, 0.5), (1.75, 2.00, 0.3), (2.00, 2.25, 0.1),
        (2.25, 2.50, 0.05),
    ]
    r = encharcamiento(bloques, f0, fc, k, bloques_en='I')

    print(f"{'t_ini(h)':>9} | {'I(mm/h)':>8} | {'f(t_ini)(mm/h)':>15} | Estado")
    for (t_ini, I, ft, enc) in r['tabla']:
        estado = 'ENCHARCA (I>=f)' if enc else 'lluvia-limitado (I<f)'
        print(f"{t_ini:9.2f} | {I:8.2f} | {ft:15.2f} | {estado}")

    print(f"\nt_enc = {r['t_enc']:.2f} h = {r['t_enc']*60:.0f} min")
    print(f"P_total = {r['Ptot']:.2f} mm ; Infiltracion total = {r['Vinf']:.2f} mm ; "
          f"Vesc = {r['Vesc']:.2f} mm")
