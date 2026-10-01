class XorBasis:
    """
    Xor basis (linear basis over GF(2)): max subset xor, is x a xor of some subset
    insert(x) -> True if x was independent, contains(x), max_xor(x=0) = max of x ^ subset
    rank = len(basis), distinct subset xors = 2^rank
    Time: O(rank) per op
    """
    def __init__(self):
        self.basis: list[int] = []

    def reduce(self, x: int) -> int:
        for b in self.basis:
            x = min(x, x ^ b)
        return x

    def insert(self, x: int) -> bool:
        x = self.reduce(x)
        if x:
            self.basis.append(x)
        return x != 0

    def contains(self, x: int) -> bool:
        return self.reduce(x) == 0

    def max_xor(self, x: int = 0) -> int:
        for b in sorted(self.basis, reverse=True):
            x = max(x, x ^ b)
        return x
