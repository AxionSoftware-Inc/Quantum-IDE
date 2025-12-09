class EmbeddedScripts {
  // Bu kod foydalanuvchi kodining "Tepasiga" yopishtiriladi
  static const String headerCode = r'''
import json
import io
import base64
import matplotlib
# Oyna ochilib ketmasligi uchun
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import sys

# --- BIZNING YORDAMCHI FUNKSIYALAR ---

def show_results(counts=None, circuit=None, matrix=None):
    """
    Quantum IDE vizualizatsiya funksiyasi.
    """
    data = {}

    # 1. Gistogramma
    if counts:
        data["histogram"] = counts

    # 2. Matritsa (Heatmap)
    if matrix is not None:
        if hasattr(matrix, "tolist"):
            import numpy as np
            real_matrix = {}
            # Modulini olamiz |x|
            arr = np.abs(np.array(matrix))
            # Normalizatsiya
            max_val = np.max(arr)
            if max_val > 0: arr = arr / max_val
            
            rows, cols = arr.shape
            for r in range(rows):
                for c in range(cols):
                    if arr[r][c] > 0.001:
                        real_matrix[f"{r},{c}"] = float(arr[r][c])
            data["matrix"] = real_matrix
        else:
            data["matrix"] = matrix

    # 3. Sxema (Circuit)
    if circuit:
        try:
            buf = io.BytesIO()
            circuit.draw('mpl', style='iqp').savefig(buf, format='png', bbox_inches='tight')
            buf.seek(0)
            img_str = base64.b64encode(buf.read()).decode('utf-8')
            data["circuit_image"] = img_str
            plt.close()
        except Exception as e:
            pass

    # YAKUNIY SIGNAL
    print("__DATA__: " + json.dumps(data))

# plt.show() ni "o'g'irlash" (Monkey Patch)
def _custom_plt_show():
    try:
        buf = io.BytesIO()
        plt.savefig(buf, format='png', bbox_inches='tight')
        buf.seek(0)
        img_str = base64.b64encode(buf.read()).decode('utf-8')
        # Bu oddiy rasm (Bloch sfera yoki boshqa grafik)
        print("__DATA__: " + json.dumps({"bloch_image": img_str}))
        plt.close()
    except:
        pass

plt.show = _custom_plt_show

# --- FOYDALANUVCHI KODI SHUNDAN KEYIN BOSHLANADI ---
''';
}