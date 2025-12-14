struct DSU {
    vi p, sz;
    DSU(int n) : p(n), sz(n, 1) { iota(all(p), 0); }
    int find(int x) { return p[x] == x ? x : p[x] = find(p[x]); }
    bool unite(int x, int y) {
        x = find(x), y = find(y);
        if (x == y) return false;
        if (sz[x] < sz[y]) swap(x, y);
        p[y] = x, sz[x] += sz[y];
        return true;
    }
    bool same(int x, int y) { return find(x) == find(y); }
};
