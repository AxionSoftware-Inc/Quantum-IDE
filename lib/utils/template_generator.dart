// lib/utils/template_generator.dart

class TemplateGenerator {

  /// Bu funksiya Python kodining tepasiga yoziladigan
  /// maxsus yordamchi funksiyalarimiz.
  static String get _pythonHelperFunctions => '''
import json

# --- Q IDE HELPER FUNCTIONS ---
def show_result(data, title="Quantum Result"):
    """
    Ma'lumotlarni IDE ga vizualizatsiya qilish uchun yuborish.
    """
    # Bu formatni bizning Dartdagi OutputParser tushunadi
    output = {
        "type": "histogram",
        "data": data,
        "title": title
    }
    # Maxsus prefiks bilan print qilamiz
    print(json.dumps(output))
# ------------------------------
''';

  static String generateGHZState(int qubits) {
    return '''
$_pythonHelperFunctions

import numpy as np
from qiskit import QuantumCircuit, transpile
from qiskit_aer import AerSimulator
import matplotlib.pyplot as plt

# $qubits-Qubitli Tizim (GHZ State)
n_qubits = $qubits
qc = QuantumCircuit(n_qubits)

# 1. Superpozitsiya
qc.h(0)

# 2. Chigallashtirish
for i in range(n_qubits - 1):
    qc.cx(i, i+1)

# 3. O'lchash
qc.measure_all()

print(f"Running {n_qubits}-Qubit Simulation...")

# Simulyatsiya
simulator = AerSimulator()
compiled_circuit = transpile(qc, simulator)
result = simulator.run(compiled_circuit, shots=1024).result()
counts = result.get_counts()

# --- NATIJANI CHIQARISH ---
print("Raw Counts:", counts)

# Mana bizning funksiyamiz!
show_result(counts) 
''';
  }
}