"""
Ejercicio 3 - Examen HHA 17/dic/2018

Cuenca con Area<200 ha y tc<20 min, cobertura original pastizales,
se proyecta urbanizar (concreto/techo) una zona sin modificar el resto.

1) A) Metodologia para el caudal maximo en condiciones (a) (original).
   B) Sigue siendo valida en condiciones (b) (parcialmente urbanizada)?
2) Expresion para el % de urbanizacion maximo admitido en (b) si Qb no
   supera en mas de 20% a Qa, para un Tr dado (tc no cambia).
3) Estimar el caudal maximo para Tr=10 anios, cuenca en Jose Pedro Varela
   (X=615km, Y=6300km), Area=190 ha, pendiente de cuenca 3%, tc=18 min,
   zona urbanizada = 20% de la superficie.

Metodologia (RESUMEN_TEORICO B4, "Metodo Racional y criterio de
seleccion segun tc" + "Coeficiente de escorrentia ponderado y area
urbanizable maxima"): replica las formulas IDF de Uruguay P(d,Tr,A)=
P310*CT(Tr)*CD(d)*CA(A,d) y Q=C*i*A/360 de la hoja "Calculos (grande)"
de Eventos extremos.xlsx (documentadas en COMO_USAR_EVENTOS_EXTREMOS.md),
mismo patron que resueltos/2024 marzo/scripts/Ejercicio3_racional.py y
resueltos/2023 diciembre/scripts/Ejercicio2_racional_NRCS.py (parte c,
area urbanizable maxima).
"""
import math


def CT(Tr):
    return 0.5786 - 0.4312 * math.log10(math.log(Tr / (Tr - 1)))


def CD(d_h):
    if d_h < 3:
        return 0.6208 * d_h / (d_h + 0.0137) ** 0.5639
    return 1.0287 * d_h / (d_h + 1.0293) ** 0.8083


def CA(A_km2, d_h):
    return 1.0 - (0.3549 * d_h ** -0.4272) * (1.0 - math.exp(-0.005792 * A_km2))


def Q_racional(C, P310, Tr, d_h, A_km2):
    P = P310 * CT(Tr) * CD(d_h) * CA(A_km2, d_h)
    i = P / d_h  # mm/h
    A_ha = A_km2 * 100
    Q = C * i * A_ha / 360
    return Q, P, i


print("=== 1) Metodologia ===")
print("A) Area<200ha y tc<20min => Teorico 3.1.5: tc<20min => usar SOLO el")
print("   metodo Racional (cuenca chica, respuesta rapida, hipotesis de")
print("   tormenta de intensidad constante=i(tc) uniforme en toda el area")
print("   valida sin objecion para un area tan chica).")
print("B) Con la urbanizacion (b), tc NO cambia (dato del enunciado) => el")
print("   mismo criterio tc<20min sigue exigiendo/permitiendo SOLO Racional.")
print("   La hipotesis de 'intensidad uniforme en el espacio' sobre la lluvia")
print("   sigue siendo valida (no depende del uso del suelo); lo que deja de")
print("   ser uniforme es el coeficiente de escorrentia C -> se usa un C")
print("   PONDERADO por area entre pastizal (C1) y concreto/techo (C2), que")
print("   es la practica estandar del curso -- el metodo Racional en si sigue")
print("   siendo aplicable, solo cambia el C de entrada.\n")

print("=== 2) Expresion del % de urbanizacion maximo admitido ===")
print("Como tc no cambia => i y A fijos en Q=C*i*A/360 => Q es proporcional a C.")
print("Cb = C1*(1-p) + C2*p  (p=fraccion urbanizada, C1=pastizal, C2=concreto/techo)")
print("Qb <= (1+x)*Qa  <=>  Cb <= (1+x)*C1")
print("C1*(1-p) + C2*p <= (1+x)*C1  =>  p*(C2-C1) <= x*C1")
print("p_max = x*C1 / (C2-C1)          (x=0.20 en este examen)\n")

print("=== 3) Estimacion Qmax, Tr=10 anios, Jose Pedro Varela ===")
A_km2 = 190 / 100.0   # 190 ha = 1.90 km2
A_ha = 190.0
Tr = 10
tc_h = 18 / 60.0      # 18 min = 0.3 h
p_urb = 0.20

P310 = 78.0  # mm, isoyeta Fig 3.1.10 en X=615km,Y=6300km (Jose Pedro Varela)
print(f"P(3,10) = {P310} mm  (leido de isoyetas, ver ej3_isoyeta_P310.png:")
print("el punto (615,6300) cae practicamente sobre la isoyeta '78', a mitad")
print("de camino entre la linea gruesa '80' y la siguiente linea fina '76')")

C1 = 0.38   # Tabla 3.1.4: Pastizales, pendiente promedio 2-7% (S=3% cae en ese tramo), Tr=10
C2 = 0.83   # Tabla 3.1.4: Concreto/techo, Tr=10
print(f"C1 (pastizal, pendiente 2-7%, Tr=10) = {C1}")
print(f"C2 (concreto/techo, Tr=10) = {C2}")

C_pond = C1 * (1 - p_urb) + C2 * p_urb
print(f"C ponderado = {1-p_urb:.2f}*{C1} + {p_urb:.2f}*{C2} = {C_pond:.4f}")

Q, P, i = Q_racional(C_pond, P310, Tr, tc_h, A_km2)
print(f"CT({Tr})={CT(Tr):.4f} ; CD({tc_h:.3f}h)={CD(tc_h):.4f} ; CA({A_km2:.2f}km2,{tc_h:.3f}h)={CA(A_km2, tc_h):.4f}")
print(f"P(d=tc,Tr=10,A) = {P310}*{CT(Tr):.3f}*{CD(tc_h):.4f}*{CA(A_km2, tc_h):.4f} = {P:.2f} mm")
print(f"i = P/tc = {P:.2f}/{tc_h:.3f} = {i:.2f} mm/h")
print(f"\n=== RESULTADO: Qmax = C_pond*i*A_ha/360 = {C_pond:.3f}*{i:.2f}*{A_ha}/360 = {Q:.2f} m3/s ===")

pmax = 0.20 * C1 / (C2 - C1)
print(f"\n(Nota: el % de urbanizacion MAXIMO admisible por la condicion de la")
print(f"parte 2, para este mismo C1/C2, seria p_max = 0.20*{C1}/({C2}-{C1}) = {pmax*100:.1f}%")
print(f"-- menor que el 20% real de este enunciado, es decir, la urbanizacion")
print(f"dada en la parte 3 YA excede el limite del +20% de caudal admisible.)")
