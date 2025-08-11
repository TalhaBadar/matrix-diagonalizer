from flask import Flask, request, jsonify
import numpy as np
import os
from sympy import Matrix

app = Flask(__name__)

@app.route('/')
def home():
    return "Diagonalizer API is live!"

@app.route('/check_diagonalizable', methods=['POST'])
def check_diagonalizable():
    data = request.get_json()
    matrix = np.array(data['matrix'])

    try:
        eigenvalues, eigenvectors = np.linalg.eig(matrix)

        unique_vals, _ = np.unique(np.round(eigenvalues, 6), return_counts=True)
        total_independent_vectors = 0

        for val in unique_vals:
            A_minus_lambdaI = matrix - val * np.eye(matrix.shape[0])
            nullity = matrix.shape[0] - np.linalg.matrix_rank(A_minus_lambdaI)
            total_independent_vectors += nullity

        is_diag = (total_independent_vectors == matrix.shape[0])

        # Explicit casts to python native types for jsonify
        response = {
            'is_diagonalizable': bool(is_diag),
            'eigenvalues': eigenvalues.tolist(),
            'total_independent_vectors': int(total_independent_vectors)
        }

        return jsonify(response)

    except Exception as e:
        return jsonify({'error': str(e)}), 500
    


@app.route('/jordan_form', methods=['POST'])
def jordan_form():
    try:
        data = request.get_json()
        matrix = Matrix(data['matrix'])

        jordan, P = matrix.jordan_form(calc_transform=True)
        P_inv = P.inv()
        A_reconstructed = P * jordan * P_inv

        return jsonify({
            'jordan': [[float(val.evalf()) for val in row] for row in jordan.tolist()],
            'P': [[float(val.evalf()) for val in row] for row in P.tolist()],
            'A_reconstructed': [[float(val.evalf()) for val in row] for row in A_reconstructed.tolist()]
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
