fact = [1] * (MAXN + 1)
inv = [1] * (MAXN + 1)
for i in range(2, MAXN + 1):
    fact[i] = fact[i - 1] * i % MOD
inv[MAXN] = pow(fact[MAXN], MOD - 2, MOD)  
for i in range(MAXN - 1, 0, -1):
    inv[i] = inv[i + 1] * (i + 1) % MOD
def nCr(n, r):
    if r > n or r < 0:
        return 0
    return fact[n] * inv[r] % MOD * inv[n - r] % MOD