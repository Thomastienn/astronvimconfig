import cmath
from typing import List

def fft(a: List[complex], invert: bool = False) -> List[complex]:
    """
    Fast Fourier Transform (in-place)
    Time: O(n log n)
    """
    n = len(a)
    if n == 1:
        return a
    
    # Bit-reversal permutation
    j = 0
    for i in range(1, n):
        bit = n >> 1
        while j & bit:
            j ^= bit
            bit >>= 1
        j ^= bit
        if i < j:
            a[i], a[j] = a[j], a[i]
    
    # Cooley-Tukey FFT
    length = 2
    while length <= n:
        angle = 2 * cmath.pi / length * (-1 if invert else 1)
        wn = cmath.exp(1j * angle)
        
        for i in range(0, n, length):
            w = 1
            for k in range(length // 2):
                u = a[i + k]
                v = a[i + k + length // 2] * w
                a[i + k] = u + v
                a[i + k + length // 2] = u - v
                w *= wn
        length *= 2
    
    if invert:
        for i in range(n):
            a[i] /= n
    
    return a
