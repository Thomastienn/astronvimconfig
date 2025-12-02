MOD = 10**9 + 7

def mod_add(a: int, b: int, mod: int = MOD) -> int:
    return (a + b) % mod

def mod_sub(a: int, b: int, mod: int = MOD) -> int:
    return (a - b + mod) % mod

def mod_mul(a: int, b: int, mod: int = MOD) -> int:
    return (a * b) % mod

def mod_pow(base: int, exp: int, mod: int = MOD) -> int:
    result = 1
    base %= mod
    while exp > 0:
        if exp & 1:
            result = result * base % mod
        exp >>= 1
        base = base * base % mod
    return result

def mod_inv(a: int, mod: int = MOD) -> int:
    """Mod must be prime"""
    return mod_pow(a, mod - 2, mod)
