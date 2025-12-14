const int MAXN = 2e5 + 5;
ll fact[MAXN], ifact[MAXN];
void precompute(int n = MAXN - 1, ll m = MOD) {
    fact[0] = 1;
    for (int i = 1; i <= n; i++) fact[i] = fact[i-1] * i % m;
    ifact[n] = power(fact[n], m - 2, m);
    for (int i = n - 1; i >= 0; i--) ifact[i] = ifact[i+1] * (i+1) % m;
}
ll ncr(int n, int r, ll m = MOD) {
    if (r < 0 || r > n) return 0;
    return fact[n] * ifact[r] % m * ifact[n-r] % m;
}
