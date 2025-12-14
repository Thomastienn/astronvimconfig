struct Kosaraju {
    int n, scc_cnt; vector<vi> g, rg; vi vis, comp, ord;
    Kosaraju(vector<vi> &g) : n(sza(g)), scc_cnt(0), g(g), rg(n), vis(n), comp(n) {
        for (int u = 0; u < n; u++)
            for (int v : g[u]) rg[v].pb(u);
        for (int i = 0; i < n; i++)
            if (!vis[i]) dfs1(i);
        reverse(all(ord)); vis.assign(n, 0);
        for (int u : ord)
            if (!vis[u]) dfs2(u), scc_cnt++;
    }
    void dfs1(int u) {
        vis[u] = 1;
        for (int v : g[u])
            if (!vis[v]) dfs1(v);
        ord.pb(u);
    }
    void dfs2(int u) {
        vis[u] = 1; comp[u] = scc_cnt;
        for (int v : rg[u])
            if (!vis[v]) dfs2(v);
    }
};
