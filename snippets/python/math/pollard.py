import random
from math import gcd

def factorize(n: int) -> list[int]:
    """
    Prime factorization of big n (~1e18) via Pollard rho + Miller-Rabin
    Returns sorted prime factors with multiplicity, 12 = [2, 2, 3]
    Time: ~O(n^(1/4)) per factor
    """
    def is_prime(m):
        if m < 2:
            return False
        for p in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
            if m % p == 0:
                return m == p
        d, r = m - 1, 0
        while d % 2 == 0:
            d //= 2
            r += 1
        for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
            x = pow(a, d, m)
            if x == 1 or x == m - 1:
                continue
            for _ in range(r - 1):
                x = x * x % m
                if x == m - 1:
                    break
            else:
                return False
        return True

    def rho(m):
        while True:
            c = random.randrange(1, m)
            x = y = random.randrange(2, m)
            d = 1
            while d == 1:
                x = (x * x + c) % m
                y = (y * y + c) % m
                y = (y * y + c) % m
                d = gcd(abs(x - y), m)
            if d != m:
                return d

    res = []
    for p in range(2, 100):
        while n % p == 0:
            res.append(p)
            n //= p
    stack = [n] if n > 1 else []
    while stack:
        m = stack.pop()
        if is_prime(m):
            res.append(m)
        else:
            d = rho(m)
            stack += [d, m // d]
    return sorted(res)
