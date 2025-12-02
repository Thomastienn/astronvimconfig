class Matrix:
    """
    Matrix operations with modular arithmetic
    - Multiply: O(n^3)
    - Power: O(n^3 log k)
    
    Use cases: Linear recurrences, counting paths, DP optimization
    """
    def __init__(self, mat: list[list[int]], mod: int = 10**9 + 7):
        self.mat = mat
        self.n = len(mat)
        self.m = len(mat[0]) if mat else 0
        self.mod = mod
    
    def __mul__(self, other: 'Matrix') -> 'Matrix':
        assert self.m == other.n
        result = [[0] * other.m for _ in range(self.n)]
        for i in range(self.n):
            for k in range(self.m):
                if self.mat[i][k] == 0:
                    continue
                for j in range(other.m):
                    result[i][j] = (result[i][j] + self.mat[i][k] * other.mat[k][j]) % self.mod
        return Matrix(result, self.mod)
    
    def __pow__(self, k: int) -> 'Matrix':
        assert self.n == self.m  # Must be square
        result = Matrix.identity(self.n, self.mod)
        base = Matrix([row[:] for row in self.mat], self.mod)
        while k:
            if k & 1:
                result = result * base
            base = base * base
            k >>= 1
        return result
    
    @staticmethod
    def identity(n: int, mod: int = 10**9 + 7) -> 'Matrix':
        mat = [[1 if i == j else 0 for j in range(n)] for i in range(n)]
        return Matrix(mat, mod)
    
    def __repr__(self):
        return '\n'.join(str(row) for row in self.mat)
