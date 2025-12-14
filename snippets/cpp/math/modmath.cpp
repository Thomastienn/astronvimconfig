ll add(ll a, ll b, ll m = MOD) { return (a + b) % m; }
ll sub(ll a, ll b, ll m = MOD) { return ((a - b) % m + m) % m; }
ll mul(ll a, ll b, ll m = MOD) { return a * b % m; }
ll power(ll a, ll b, ll m = MOD) {
    ll r = 1;
    for (; b; b >>= 1, a = a * a % m)
        if (b & 1) r = r * a % m;
    return r;
}
ll inv(ll a, ll m = MOD) { return power(a, m - 2, m); }
