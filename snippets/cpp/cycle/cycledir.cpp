vi find_cycle_dir(vector<vi> &g, int s) {
    int n = sza(g); vi col(n), par(n, -1); vi cycle;
    function<bool(int)> dfs = [&](int u) {
        col[u] = 1;
        for (int v : g[u]) {
            if (col[v] == 0) {
                par[v] = u;
                if (dfs(v)) return true;
            } else if (col[v] == 1) {
                for (int x = u; x != v; x = par[x]) cycle.pb(x);
                cycle.pb(v); reverse(all(cycle));
                return true;
            }
        }
        col[u] = 2;
        return false;
    };
    for (int i = 0; i < n; i++)
        if (!col[i] && dfs(i)) return cycle;
    return {};
}
