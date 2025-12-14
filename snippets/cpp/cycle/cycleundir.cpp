vi find_cycle_undir(vector<vi> &g, int s) {
    int n = sza(g); vi vis(n), par(n, -1); vi cycle;
    function<bool(int, int)> dfs = [&](int u, int p) {
        vis[u] = 1;
        for (int v : g[u]) {
            if (v == p) continue;
            if (vis[v]) {
                for (int x = u; x != v; x = par[x]) cycle.pb(x);
                cycle.pb(v); reverse(all(cycle));
                return true;
            }
            par[v] = u;
            if (dfs(v, u)) return true;
        }
        return false;
    };
    for (int i = 0; i < n; i++)
        if (!vis[i] && dfs(i, -1)) return cycle;
    return {};
}
