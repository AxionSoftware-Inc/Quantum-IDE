class EmbeddedScripts {
  static const String headerCode = r'''
import json
import io
import base64
import sys
import matplotlib

# 1. WINDOWS UTF-8 FIX (Eng muhimi!)
try:
    sys.stdout.reconfigure(encoding='utf-8')
except:
    pass

# Oyna ochilib ketmasligi uchun
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# Qiskit kutubxonalari
try:
    from qiskit import QuantumCircuit, transpile
    from qiskit.quantum_info import DensityMatrix, Statevector
    from qiskit_aer import AerSimulator
    from qiskit.visualization import plot_bloch_multivector
except ImportError:
    print("[Ogohlantirish]: Qiskit topilmadi. Ba'zi funksiyalar ishlamasligi mumkin.")

# --- 1. UNIVERSAL FUNKSIYA (MASTER) ---
def show_results(counts=None, circuit=None, matrix=None):
    try:
        data = {}

        # GISTOGRAMMA
        if counts:
            if hasattr(counts, 'int_outcomes'): data["histogram"] = counts.int_outcomes()
            else: data["histogram"] = counts

        # MATRITSA
        if matrix is not None:
            try:
                # Agar Qiskit obyekti bo'lsa
                if hasattr(matrix, 'data'): matrix = matrix.data
                
                # Numpy arrayga o'tkazish
                arr = np.abs(np.array(matrix)) # Modulini olamiz
                
                # Normalizatsiya
                max_val = np.max(arr)
                if max_val > 0: arr = arr / max_val
                
                rows, cols = arr.shape
                # 64x64 dan katta bo'lsa yubormaymiz (qotib qolmasligi uchun)
                if rows <= 64:
                    real_matrix = {}
                    for r in range(rows):
                        for c in range(cols):
                            val = float(arr[r][c])
                            if val > 0.001: real_matrix[f"{r},{c}"] = val
                    data["matrix"] = real_matrix
            except Exception as e:
                print(f"Matritsa xatosi: {e}")

        # SXEMA
        if circuit:
            try:
                buf = io.BytesIO()
                circuit.draw('mpl').savefig(buf, format='png', bbox_inches='tight')
                buf.seek(0)
                data["circuit_image"] = base64.b64encode(buf.read()).decode('utf-8')
                plt.close()
            except Exception as e:
                print(f"Sxema chizish xatosi: {e}")

        # YAKUNIY SIGNAL
        print("__DATA__: " + json.dumps(data))
    
    except Exception as e:
        print(f"Vizualizatsiya Xatosi (show_results): {e}")


# --- 2. AQLLI YORDAMCHILAR (HELPERS) ---

def plot_matrix(circuit):
    """Sxemani olib, avtomatik Matritsa chizadi"""
    try:
        if 'DensityMatrix' not in globals():
            print("Xato: Qiskit o'rnatilmagan, matritsani hisoblab bo'lmaydi.")
            return
            
        # Foydalanuvchi o'rniga biz hisoblaymiz
        rho = DensityMatrix(circuit)
        show_results(matrix=rho, circuit=circuit)
    except Exception as e:
        print(f"plot_matrix xatosi: {e}")

def plot_sphere(circuit):
    """Sxemani olib, avtomatik Bloch Sfera chizadi"""
    try:
        if 'Statevector' not in globals():
             print("Xato: Qiskit o'rnatilmagan.")
             return

        state = Statevector(circuit)
        # Rasmga aylantirish
        plot_bloch_multivector(state)
        
        buf = io.BytesIO()
        plt.savefig(buf, format='png', bbox_inches='tight')
        buf.seek(0)
        img_str = base64.b64encode(buf.read()).decode('utf-8')
        
        # IDE ga jo'natish
        print("__DATA__: " + json.dumps({"bloch_image": img_str}))
        plt.close()
    except Exception as e:
        print(f"plot_sphere xatosi: {e}")

def plot_histogram(circuit, shots=1024):
    """Sxemani olib, avtomatik Simulyatsiya qiladi va Gistogramma chizadi"""
    try:
        if 'AerSimulator' not in globals():
             print("Xato: Qiskit Aer o'rnatilmagan.")
             return

        # Nusxa olamiz (Original sxemani buzmaslik uchun)
        qc_copy = circuit.copy()
        qc_copy.measure_all()
        
        sim = AerSimulator()
        result = sim.run(qc_copy, shots=shots).result()
        counts = result.get_counts()
        
        show_results(counts=counts, circuit=circuit)
    except Exception as e:
        print(f"plot_histogram xatosi: {e}")

# plt.show() ni o'g'irlash
def _custom_plt_show():
    try:
        buf = io.BytesIO()
        plt.savefig(buf, format='png', bbox_inches='tight')
        buf.seek(0)
        img_str = base64.b64encode(buf.read()).decode('utf-8')
        print("__DATA__: " + json.dumps({"bloch_image": img_str}))
        plt.close()
    except: pass

plt.show = _custom_plt_show

# --- FOYDALANUVCHI KODI BOSHLANADI ---
''';
}