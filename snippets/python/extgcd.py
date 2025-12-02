def extgcd(a: int, b: int) -> tuple[int, int, int]:
    """Returns (gcd, x, y) where ax + by = gcd"""
    if b == 0:
        return a, 1, 0
    g, x, y = extgcd(b, a % b)
    return g, y, x - (a // b) * y

def mod_inv_general(a: int, mod: int) -> int:
    """Works for any mod if gcd(a, mod) = 1"""
    g, x, _ = extgcd(a, mod)
    return x % mod if g == 1 else -1
