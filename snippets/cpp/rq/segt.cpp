struct SegTree {
    int n; vi t;
    SegTree(int n) : n(n), t(4 * n) {}
    SegTree(vi &a) : n(sza(a)), t(4 * n) { build(a, 0, 0, n - 1); }
    void build(vi &a, int v, int l, int r) {
        if (l == r) { t[v] = a[l]; return; }
        int m = (l + r) / 2;
        build(a, 2*v+1, l, m); build(a, 2*v+2, m+1, r);
        t[v] = t[2*v+1] + t[2*v+2];
    }
    void upd(int i, int v, int x, int l, int r) {
        if (l == r) { t[x] = v; return; }
        int m = (l + r) / 2;
        if (i <= m) upd(i, v, 2*x+1, l, m);
        else upd(i, v, 2*x+2, m+1, r);
        t[x] = t[2*x+1] + t[2*x+2];
    }
    int qry(int ql, int qr, int x, int l, int r) {
        if (ql > r || qr < l) return 0;
        if (ql <= l && r <= qr) return t[x];
        int m = (l + r) / 2;
        return qry(ql, qr, 2*x+1, l, m) + qry(ql, qr, 2*x+2, m+1, r);
    }
    void upd(int i, int v) { upd(i, v, 0, 0, n - 1); }
    int qry(int l, int r) { return qry(l, r, 0, 0, n - 1); }
};
