#!/usr/bin/env python3
"""
Convertidor de GIF a archivos HEX para matriz LED (soporta frames parciales).
Uso:
  python gif_to_hex.py input.gif [max_frames] [width] [height]

Ejemplo (por defecto width=64 height=32):
  python gif_to_hex.py animation.gif 4 64 32
"""

from PIL import Image, ImageSequence
import sys
import os

def rgb_to_4bit(r, g, b):
    """Convierte RGB de 8 bits a 4 bits por canal"""
    r4 = (r >> 4) & 0xF
    g4 = (g >> 4) & 0xF
    b4 = (b >> 4) & 0xF
    return r4, g4, b4

def process_gif_frame(frame, width=64, height=32):
    """
    Procesa un frame completo (ya compuesto) y genera dos listas:
    - image0_data para la mitad superior
    - image1_data para la mitad inferior
    width x height: dimensiones finales del frame
    """
    # Redimensionar si hace falta (resample LANCZOS)
    if frame.size != (width, height):
        frame = frame.resize((width, height), Image.Resampling.LANCZOS)

    # Asegurar modo RGB
    if frame.mode != 'RGB':
        frame = frame.convert('RGB')

    pixels = frame.load()

    image0_data = []  # Mitad superior
    image1_data = []  # Mitad inferior

    half_h = height // 2
    # Recorremos fila por fila de la mitad superior
    for row in range(half_h):
        for col in range(width):
            # píxel superior
            r0, g0, b0 = pixels[col, row]
            r0_4, g0_4, b0_4 = rgb_to_4bit(r0, g0, b0)
            pixel0 = (r0_4 << 8) | (g0_4 << 4) | b0_4
            image0_data.append(pixel0)

            # píxel inferior correspondiente (row + half_h)
            r1, g1, b1 = pixels[col, row + half_h]
            r1_4, g1_4, b1_4 = rgb_to_4bit(r1, g1, b1)
            pixel1 = (r1_4 << 8) | (g1_4 << 4) | b1_4
            image1_data.append(pixel1)

    return image0_data, image1_data

def save_hex_file(data, filename):
    """Guarda los datos en formato hexadecimal (3 hex digits → 12 bits)"""
    with open(filename, 'w') as f:
        for value in data:
            f.write(f"{value:03X}\n")
    print(f"  -> Generado: {filename} ({len(data)} píxeles)")

def convert_gif_to_hex(gif_path, max_frames=4, width=64, height=32):
    """Convierte GIF a archivos hex, componiendo frames parciales correctamente."""
    try:
        img = Image.open(gif_path)
    except Exception as e:
        print(f"Error al abrir {gif_path}: {e}")
        return

    print(f"\nProcesando GIF: {gif_path}")
    print(f"Original size: {img.size}")
    total_frames = getattr(img, "n_frames", 1)
    print(f"Frames in GIF: {total_frames}")

    # Creamos una imagen base (transparente/negra) del tamaño de trabajo
    base = Image.new("RGBA", img.size)
    composed_frames = []
    frame_count = 0

    # Recorremos frames y componemos (esto maneja frames parciales)
    for frame in ImageSequence.Iterator(img):
        # Convertimos el frame a RGBA para componer
        frame_rgba = frame.convert("RGBA")

        # Si la GIF tiene modo 'P' y box (posición parcial), mejor pegar en la base
        # Pegamos el frame sobre la base según su caja (frame.info.get('transparency') no siempre suficiente)
        try:
            # Algunos frames tienen .dispose info; aquí hacemos la composición simple:
            base.paste(frame_rgba, (0,0), frame_rgba)
        except Exception:
            # fallback: usar alpha_composite para tamaños iguales
            base = Image.alpha_composite(base, frame_rgba)

        # Copiamos el resultado (convertimos a RGB)
        composed = base.convert("RGB").copy()
        composed_frames.append(composed)

        frame_count += 1
        if frame_count >= max_frames:
            break

    if frame_count == 0:
        print("No se detectaron frames. Abortando.")
        return

    # Guardar cada frame compuesto en HEX
    for i, cframe in enumerate(composed_frames):
        print(f"\nProcesando frame compuesto {i} ...")
        image0_data, image1_data = process_gif_frame(cframe, width=width, height=height)
        save_hex_file(image0_data, f"frame{i}_image0.hex")
        save_hex_file(image1_data, f"frame{i}_image1.hex")

    # Si hay menos frames que max_frames, duplicar el último
    while len(composed_frames) < max_frames:
        last = len(composed_frames) - 1
        print(f"\nDuplicando frame {last} -> frame {len(composed_frames)}")
        with open(f"frame{last}_image0.hex", 'r') as src:
            data = src.read()
            with open(f"frame{len(composed_frames)}_image0.hex", 'w') as dst:
                dst.write(data)
        with open(f"frame{last}_image1.hex", 'r') as src:
            data = src.read()
            with open(f"frame{len(composed_frames)}_image1.hex", 'w') as dst:
                dst.write(data)
        composed_frames.append(None)

    print(f"\n✓ Conversión completada: {len(composed_frames)} frames generados")
    print("\nArchivos generados:")
    for i in range(len(composed_frames)):
        print(f"  - frame{i}_image0.hex")
        print(f"  - frame{i}_image1.hex")

def main():
    if len(sys.argv) < 2:
        print("Uso: python gif_to_hex.py <archivo.gif> [max_frames] [width] [height]")
        sys.exit(1)

    gif_path = sys.argv[1]
    max_frames = int(sys.argv[2]) if len(sys.argv) > 2 else 4
    width = int(sys.argv[3]) if len(sys.argv) > 3 else 64
    height = int(sys.argv[4]) if len(sys.argv) > 4 else 32

    # Comprobación rápida
    if height % 2 != 0:
        print("El alto (height) debe ser par (divisible entre 2).")
        sys.exit(1)

    convert_gif_to_hex(gif_path, max_frames=max_frames, width=width, height=height)

if __name__ == "__main__":
    main()
