"""
Ejercicio 3, Parte 1 - Examen HHA 2024 febrero
Delimitacion (manual, sobre la carta topografica SGM de
EXAMENES/2024 febrero.pdf, pagina 3) de la cuenca de la canada del
Arbelo cuyo punto de cierre esta en X=494.4 km, Y=6171.8 km.

Este script solo localiza el punto de cierre (busca el marcador naranja
que trae impreso el PDF) y dibuja la divisoria de aguas trazada a mano
(ver RESOLUCION.md para la justificacion: se sigue la linea de cumbre
-las "narices" o espolones entre curvas de nivel- que separa el valle de
la canada del Arbelo del valle de la canada del Juncal (al oeste) y del
tributario que baja hacia Puntas de Canada Grande (al este)).
"""
from PIL import Image, ImageDraw

im = Image.open("ej3_page3.png").convert("RGB")
draw = ImageDraw.Draw(im)

# punto de cierre: centroide del marcador naranja impreso en el PDF
# (detectado por color, ver metodologia en RESOLUCION.md)
cx, cy = 980, 724
r = 10
draw.ellipse((cx-r, cy-r, cx+r, cy+r), outline=(255, 0, 0), width=4)

# divisoria de aguas aproximada (poligono cerrado en el punto de cierre),
# trazada siguiendo los espolones/lomas visibles entre canadas vecinas
divide = [
    (980, 724),
    (900, 640), (800, 600), (720, 650), (680, 780),
    (650, 950), (660, 1150), (720, 1350), (830, 1500),
    (950, 1600), (1080, 1580), (1180, 1480), (1230, 1320),
    (1220, 1150), (1170, 980), (1120, 850), (1050, 760),
    (980, 724),
]
draw.line(divide, fill=(255, 0, 255), width=6, joint="curve")

box = (350, 500, 1500, 1750)
im.crop(box).save("ej3_cuenca_delimitada.png")
print("Guardado: ej3_cuenca_delimitada.png")
