struct SparseTable {
    int n, lg; vector<vi> st;
    SparseTable(vi &a) : n(sza(a)), lg(__lg(n) + 1), st(lg, vi(n)) {
        st[0] = a;
        for (int i = 1; i < lg; i++)
            for (int j = 0; j + (1 << i) <= n; j++)
                st[i][j] = min(st[i-1][j], st[i-1][j + (1 << (i-1))]);
    }
    int qry(int l, int r) {
        int i = __lg(r - l + 1);
        return min(st[i][l], st[i][r - (1 << i) + 1]);
    }
};
