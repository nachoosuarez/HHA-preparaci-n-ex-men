"""
Utilidad de "descreening" para cartas topograficas escaneadas como imagen
bitonal CCITTFax (1 bit blanco/negro, sin escala de grises real).

Que hace: el escaner original convierte grises (curvas de nivel finas,
sombreado) en una trama de semitonos (halftone) de puntos blanco/negro.
Con eso, escalar hacia ARRIBA (upscaling, LANCZOS, sharpen, autocontraste
directo) no ayuda: cada punto de la trama ya es 100% blanco o 100% negro,
no hay informacion de gris que "recuperar" ampliando.

En cambio, promediar hacia ABAJO (downsampling con filtro de caja/area)
SI reconstruye el gris real: agrupa varios puntos de la trama en un
pixel de salida y promedia su densidad blanco/negro, que es exactamente
la operacion inversa del halftoning. Con eso las curvas de nivel y el
relieve vuelven a ser legibles (aunque los rotulos de texto muy chicos
siguen perdidos: el trazo de una letra es mas fino que el periodo de la
trama y no sobrevive ni promediando).

Uso: render la pagina del PDF a alta resolucion (300-600 dpi) con
PyMuPDF, despues aplicar este descreen con factor 4-8 y autocontraste.

Aplicado a `EXAMENES/2018 diciembre.pdf` pagina 3 (carta SGM del
Ejercicio 2): con esto las curvas de nivel y cotas quedan legibles
(ver `ej2_carta_descreened.png`), pero la carta esta recortada sin los
margenes con los rotulos numericos de la grilla UTM/Gauss-Kruger (no se
ve ningun numero de coordenada en los 4 bordes), asi que sigue sin poder
anclarse el punto de cierre X=382.5 km, Y=6408.5 km de forma verificable
-- ver nota en RESOLUCION.md, Ejercicio 2.
"""

import fitz
from PIL import Image, ImageOps


def descreen_pdf_page(pdf_path, page_index, out_path, dpi=600, factor=6):
    doc = fitz.open(pdf_path)
    page = doc[page_index]
    pix = page.get_pixmap(dpi=dpi)
    tmp = out_path + ".raw.png"
    pix.save(tmp)

    im = Image.open(tmp).convert("L")
    w, h = im.size
    small = im.resize((w // factor, h // factor), Image.BOX)
    small = ImageOps.autocontrast(small, cutoff=1)
    small.save(out_path)
    return out_path


if __name__ == "__main__":
    descreen_pdf_page(
        "../../EXAMENES/2018 diciembre.pdf",
        page_index=2,  # pagina 3 (0-indexed)
        out_path="ej2_carta_descreened.png",
        dpi=600,
        factor=6,
    )
