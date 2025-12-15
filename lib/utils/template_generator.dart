class TemplateGenerator {
  static String generateGHZState(int qubits) {
    return '''
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

print("Natijalar (Counts):", counts)
''';
  }
}