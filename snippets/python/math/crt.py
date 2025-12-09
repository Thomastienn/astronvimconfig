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
