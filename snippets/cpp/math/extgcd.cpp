ll extgcd(ll a, ll b, ll &x, ll &y) {
    if (!b) { x = 1, y = 0; return a; }
    ll g = extgcd(b, a % b, y, x);
    y -= a / b * x;
    return g;
}
ll modinv(ll a, ll m) {
    ll x, y, g = extgcd(a, m, x, y);
    return g == 1 ? (x % m + m) % m : -1;
}
