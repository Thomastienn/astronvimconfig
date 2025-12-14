struct RollHash {
    static const ll B = 911382629, M = 1e18 + 3;
    int n; vector<ll> pow, h;
    RollHash(string &s) : n(sza(s)), pow(n + 1, 1), h(n + 1) {
        for (int i = 1; i <= n; i++) pow[i] = pow[i-1] * B % M;
        for (int i = 1; i <= n; i++) h[i] = (h[i-1] * B + s[i-1]) % M;
    }
    ll get(int l, int r) { return (h[r] - h[l] * pow[r-l] % M + M) % M; }
};
