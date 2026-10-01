def sos(f: list[int], bits: int) -> list[int]:
    """
    Sum over subsets DP: g[mask] = sum of f[sub] over all sub that are subsets of mask
    Superset sums: `if not mask >> i & 1: g[mask] += g[mask | 1 << i]`
    Subtract instead of add to invert (Mobius)
    Time: O(bits * 2^bits)
    """
    g = f[:]
    for i in range(bits):
        bit = 1 << i
        for mask in range(1 << bits):
            if mask & bit:
                g[mask] += g[mask ^ bit]
    return g
