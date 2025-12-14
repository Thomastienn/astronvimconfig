struct Tarjan {
    int n, timer, scc_cnt; vector<vi> g; vi low, id, on_stack, comp;
    stack<int> st;
    Tarjan(vector<vi> &g) : n(sza(g)), timer(0), scc_cnt(0), g(g), low(n), id(n, -1), on_stack(n), comp(n) {
        for (int i = 0; i < n; i++)
            if (id[i] == -1) dfs(i);
    }
    void dfs(int u) {
        low[u] = id[u] = timer++;
        st.push(u); on_stack[u] = 1;
        for (int v : g[u]) {
            if (id[v] == -1) dfs(v);
            if (on_stack[v]) low[u] = min(low[u], low[v]);
        }
        if (low[u] == id[u]) {
            while (1) {
                int v = st.top(); st.pop(); on_stack[v] = 0;
                comp[v] = scc_cnt;
                if (v == u) break;
            }
            scc_cnt++;
        }
    }
};
