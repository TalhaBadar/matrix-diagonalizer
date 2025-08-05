from flask import Flask, request, jsonify
import numpy as np
import os 
from numpy.linalg import eig, matrix_rank
 
app = Flask(__name__)


@app.route('/')
def home():
    return 'Diagonalizer API is running!'

@app.route('/check_diagonalizable', methods=['POST'])
def check_diagonalizable():
    data = request.get_json()
    matrix = np.array(data['matrix'])

    try:
        eigenvalues, eigenvectors = eig(matrix)

        unique_vals, counts = np.unique(np.round(eigenvalues, decimals=6), return_counts=True)
        total_independent_vectors = 0

        for val in unique_vals:
            A_minus_lambdaI = matrix - val * np.eye(matrix.shape[0])
            nullity = matrix.shape[0] - np.linalg.matrix_rank(A_minus_lambdaI)
            total_independent_vectors += nullity

        is_diagonalizable = total_independent_vectors == matrix.shape[0]

        return jsonify({
            'is_diagonalizable': is_diagonalizable,
            'eigenvalues': eigenvalues.tolist(),
            'total_independent_vectors': total_independent_vectors
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    port = int(os.environ.get("PORT", 5000))  # <-- Use dynamic port
    app.run(debug=False, host='0.0.0.0', port=port)