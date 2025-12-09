class EmbeddedScripts {
  static const String headerCode = r'''
import json
import io
import base64
import sys
import matplotlib
# GUI oyna ochilib ketmasligi uchun
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# --- BIZNING YORDAMCHI FUNKSIYALAR ---

def show_results(counts=None, circuit=None, matrix=None):
    """
    Quantum IDE vizualizatsiya funksiyasi.
    """
    data = {}

    # 1. Gistogramma (Agar counts berilgan bo'lsa)
    if counts:
        # Ba'zan counts bu Dictionary emas, Qiskit Result obyekti bo'lib qolishi mumkin
        if hasattr(counts, 'int_outcomes'):
             data["histogram"] = counts.int_outcomes()
        else:
             data["histogram"] = counts

    # 2. Matritsa (Eng muhim tuzatish shu yerda!)
    if matrix is not None:
        try:
            import numpy as np
            real_matrix = {}
            
            # Agar matrix bu Qiskit DensityMatrix obyekti bo'lsa -> .data ni olamiz
            if hasattr(matrix, 'data'):
                matrix = matrix.data

            # Agar oddiy List yoki Numpy Array bo'lsa
            arr = np.array(matrix)
            
            # MURAKKAB SONLARNI YO'QOTISH: |x| (Absolute value)
            # 0.7 + 0.2j  --->  0.728
            arr = np.abs(arr)

            # Normalizatsiya (Eng kattasi 1.0 bo'lsin)
            max_val = np.max(arr)
            if max_val > 0: 
                arr = arr / max_val
            
            rows, cols = arr.shape
            # Faqat 64x64 gacha bo'lgan matritsalarni olamiz (Kattasi kerak emas)
            if rows <= 64 and cols <= 64:
                for r in range(rows):
                    for c in range(cols):
                        val = float(arr[r][c])
                        # Juda kichik sonlarni (0.00001) tashlab yuboramiz
                        if val > 0.001:
                            real_matrix[f"{r},{c}"] = val
                data["matrix"] = real_matrix
            else:
                # Agar juda katta bo'lsa, ogohlantirish yuboramiz (log orqali)
                pass 

        except Exception as e:
            # Agar matritsada xato bo'lsa, dastur to'xtamasin
            data["matrix_error"] = str(e)

    # 3. Sxema (Circuit)
    if circuit:
        try:
            buf = io.BytesIO()
            # Style 'iqp' chiroyli, lekin ba'zida xato berishi mumkin, shuning uchun oddiy 'mpl'
            circuit.draw('mpl').savefig(buf, format='png', bbox_inches='tight')
            buf.seek(0)
            img_str = base64.b64encode(buf.read()).decode('utf-8')
            data["circuit_image"] = img_str
            plt.close()
        except Exception as e:
            pass

    # YAKUNIY SIGNAL
    print("__DATA__: " + json.dumps(data))

# plt.show() ni "o'g'irlash"
def _custom_plt_show():
    try:
        buf = io.BytesIO()
        plt.savefig(buf, format='png', bbox_inches='tight')
        buf.seek(0)
        img_str = base64.b64encode(buf.read()).decode('utf-8')
        # Rasmni nima deb ko'rsatishni bilmaymiz, shuning uchun 'bloch_image' deb yuboramiz
        # VisualizerWidget uni rasm sifatida chiqaradi
        print("__DATA__: " + json.dumps({"bloch_image": img_str}))
        plt.close()
    except:
        pass

plt.show = _custom_plt_show
''';
}