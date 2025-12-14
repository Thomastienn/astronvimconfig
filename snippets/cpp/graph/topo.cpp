vi topo_sort(vector<vi> &g) {
    int n = sza(g); vi in(n), ord;
    for (int u = 0; u < n; u++)
        for (int v : g[u]) in[v]++;
    queue<int> q;
    for (int i = 0; i < n; i++)
        if (!in[i]) q.push(i);
    while (!q.empty()) {
        int u = q.front(); q.pop(); ord.pb(u);
        for (int v : g[u])
            if (!--in[v]) q.push(v);
    }
    return sza(ord) == n ? ord : vi{};
}
