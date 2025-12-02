def extgcd(a: int, b: int) -> tuple[int, int, int]:
    """Returns (gcd, x, y) where ax + by = gcd"""
    if b == 0:
        return a, 1, 0
    g, x, y = extgcd(b, a % b)
    return g, y, x - (a // b) * y

def crt(remainders: list[int], mods: list[int]) -> tuple[int, int]:
    """
    Find x such that x ≡ r[i] (mod m[i])
    Returns (x, lcm) or (-1, -1) if no solution
    """
    x, m = 0, 1
    for ri, mi in zip(remainders, mods):
        g, a, _ = extgcd(m, mi)
        if (ri - x) % g != 0:
            return -1, -1
        x = x + m * ((ri - x) // g * a % (mi // g))
        m = m // g * mi
        x %= m
    return x, m
