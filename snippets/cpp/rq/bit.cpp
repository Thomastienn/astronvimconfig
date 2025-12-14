struct BIT {
    int n; vi t;
    BIT(int n) : n(n), t(n + 1) {}
    void upd(int i, int v) { for (; i <= n; i += i & -i) t[i] += v; }
    int qry(int i) { int r = 0; for (; i; i -= i & -i) r += t[i]; return r; }
    int qry(int l, int r) { return qry(r) - qry(l); }
};
