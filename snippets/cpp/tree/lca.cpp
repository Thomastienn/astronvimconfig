struct LCA {
    int n, lg; vector<vi> up, g; vi dep;
    LCA(vector<vi> &g, int root = 0) : n(sza(g)), lg(__lg(n) + 1), up(lg, vi(n)), g(g), dep(n) {
        dfs(root, root);
        for (int i = 1; i < lg; i++)
            for (int u = 0; u < n; u++)
                up[i][u] = up[i-1][up[i-1][u]];
    }
    void dfs(int u, int p) {
        up[0][u] = p;
        for (int v : g[u])
            if (v != p) dep[v] = dep[u] + 1, dfs(v, u);
    }
    int lca(int u, int v) {
        if (dep[u] < dep[v]) swap(u, v);
        int diff = dep[u] - dep[v];
        for (int i = 0; i < lg; i++)
            if (diff >> i & 1) u = up[i][u];
        if (u == v) return u;
        for (int i = lg - 1; i >= 0; i--)
            if (up[i][u] != up[i][v])
                u = up[i][u], v = up[i][v];
        return up[0][u];
    }
    int dist(int u, int v) { return dep[u] + dep[v] - 2 * dep[lca(u, v)]; }
};
