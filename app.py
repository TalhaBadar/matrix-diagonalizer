from flask import Flask, request, jsonify
from sympy import Matrix, symbols
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route('/check', methods=['POST'])
def check_diagonalizable():
    data = request.json
    mat = data['matrix']
    
    try:
        A = Matrix(mat)
        eigen_data = A.diagonalize(reals_only=True, return_transformation=True)
        D, P = eigen_data

        # Inverse of P
        P_inv = P.inv()

        # Prepare JSON serializable matrices
        result = {
            'result': 'Diagonalizable',
            'P': [[str(val) for val in row] for row in P.tolist()],
            'D': [[str(val) for val in row] for row in D.tolist()],
            'P_inv': [[str(val) for val in row] for row in P_inv.tolist()]
        }
        return jsonify(result)

    except Exception as e:
        return jsonify({'result': 'Not Diagonalizable', 'error': str(e)})
    
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

