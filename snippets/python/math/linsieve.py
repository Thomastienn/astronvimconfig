def linear_sieve(n: int) -> tuple[list[int], list[int], list[int]]:
    """
    Linear sieve up to n: smallest prime factor, primes, Euler totient phi
    Fast factorize x <= n: while x > 1: p = spf[x]; x //= p
    Returns (spf, primes, phi)
    Time: O(n)
    """
    spf = [0] * (n + 1)
    phi = [0] * (n + 1)
    primes = []
    if n >= 1:
        phi[1] = 1
    for i in range(2, n + 1):
        if spf[i] == 0:
            spf[i] = i
            phi[i] = i - 1
            primes.append(i)
        for p in primes:
            if p > spf[i] or i * p > n:
                break
            spf[i * p] = p
            phi[i * p] = phi[i] * p if p == spf[i] else phi[i] * (p - 1)
    return spf, primes, phi

def totient(n: int) -> int:
    """Euler phi of one n (count of 1..n coprime to n), O(sqrt n)"""
    res, p = n, 2
    while p * p <= n:
        if n % p == 0:
            while n % p == 0:
                n //= p
            res -= res // p
        p += 1
    if n > 1:
        res -= res // n
    return res
