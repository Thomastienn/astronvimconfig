using Mat = vector<vector<ll>>;
Mat matmul(Mat &a, Mat &b, ll m = MOD) {
    int n = sza(a), p = sza(b[0]);
    Mat c(n, vector<ll>(p));
    for (int i = 0; i < n; i++)
        for (int k = 0; k < sza(b); k++)
            for (int j = 0; j < p; j++)
                c[i][j] = (c[i][j] + a[i][k] * b[k][j]) % m;
    return c;
}
Mat matpow(Mat a, ll n, ll m = MOD) {
    int sz = sza(a);
    Mat r(sz, vector<ll>(sz));
    for (int i = 0; i < sz; i++) r[i][i] = 1;
    for (; n; n >>= 1, a = matmul(a, a, m))
        if (n & 1) r = matmul(r, a, m);
    return r;
}
