def ntt(a: list[int], invert: bool = False, mod: int = 998244353, g: int = 3) -> None:
    """
    Number theoretic transform (in-place), exact FFT mod prime, len(a) power of 2
    mod must be c * 2^k + 1 with primitive root g (998244353 -> 3)
    """
    n = len(a)
    j = 0
    for i in range(1, n):
        bit = n >> 1
        while j & bit:
            j ^= bit
            bit >>= 1
        j ^= bit
        if i < j:
            a[i], a[j] = a[j], a[i]
    length = 2
    while length <= n:
        w = pow(g, (mod - 1) // length, mod)
        if invert:
            w = pow(w, mod - 2, mod)
        half = length >> 1
        ws = [1] * half
        for k in range(1, half):
            ws[k] = ws[k - 1] * w % mod
        for i in range(0, n, length):
            lo = a[i:i + half]
            hi = [x * y % mod for x, y in zip(a[i + half:i + length], ws)]
            a[i:i + half] = [(x + y) % mod for x, y in zip(lo, hi)]
            a[i + half:i + length] = [(x - y) % mod for x, y in zip(lo, hi)]
        length <<= 1
    if invert:
        inv = pow(n, mod - 2, mod)
        for i in range(n):
            a[i] = a[i] * inv % mod

def convolve(a: list[int], b: list[int], mod: int = 998244353) -> list[int]:
    """
    Polynomial multiplication mod 998244353, c[k] = sum a[i] * b[k - i]
    Exact, unlike float fft. Time: O(n log n)
    """
    if not a or not b:
        return []
    m = len(a) + len(b) - 1
    n = 1 << (m - 1).bit_length()
    fa = a + [0] * (n - len(a))
    fb = b + [0] * (n - len(b))
    ntt(fa, mod=mod)
    ntt(fb, mod=mod)
    fc = [x * y % mod for x, y in zip(fa, fb)]
    ntt(fc, True, mod=mod)
    return fc[:m]
