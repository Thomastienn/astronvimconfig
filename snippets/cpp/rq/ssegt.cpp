struct LazySegTree {
    int n; vi t, lz;
    LazySegTree(int n) : n(n), t(4 * n), lz(4 * n) {}
    void push(int v, int l, int r) {
        if (!lz[v]) return;
        t[v] += (r - l + 1) * lz[v];
        if (l != r) lz[2*v+1] += lz[v], lz[2*v+2] += lz[v];
        lz[v] = 0;
    }
    void upd(int ql, int qr, int val, int v, int l, int r) {
        push(v, l, r);
        if (ql > r || qr < l) return;
        if (ql <= l && r <= qr) {
            lz[v] += val; push(v, l, r);
            return;
        }
        int m = (l + r) / 2;
        upd(ql, qr, val, 2*v+1, l, m);
        upd(ql, qr, val, 2*v+2, m+1, r);
        push(2*v+1, l, m); push(2*v+2, m+1, r);
        t[v] = t[2*v+1] + t[2*v+2];
    }
    int qry(int ql, int qr, int v, int l, int r) {
        if (ql > r || qr < l) return 0;
        push(v, l, r);
        if (ql <= l && r <= qr) return t[v];
        int m = (l + r) / 2;
        return qry(ql, qr, 2*v+1, l, m) + qry(ql, qr, 2*v+2, m+1, r);
    }
    void upd(int l, int r, int v) { upd(l, r, v, 0, 0, n - 1); }
    int qry(int l, int r) { return qry(l, r, 0, 0, n - 1); }
};
