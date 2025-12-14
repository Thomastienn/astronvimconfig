pll crt(vector<ll> &r, vector<ll> &m) {
    ll x = 0, M = 1;
    for (int i = 0; i < sza(r); i++) {
        ll a, b, g = extgcd(M, m[i], a, b);
        if ((r[i] - x) % g) return {-1, -1};
        x += M * ((r[i] - x) / g % (m[i] / g) * a % (m[i] / g));
        M *= m[i] / g;
        x = (x % M + M) % M;
    }
    return {x, M};
}
