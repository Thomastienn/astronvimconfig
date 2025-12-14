ll prim(vector<vpii> &g, int s = 0) {
    int n = sza(g); vi vis(n); ll cost = 0;
    priority_queue<pii, vpii, greater<pii>> pq; pq.push({0, s});
    while (!pq.empty()) {
        auto [w, u] = pq.top(); pq.pop();
        if (vis[u]) continue;
        vis[u] = 1; cost += w;
        for (auto [v, wt] : g[u])
            if (!vis[v]) pq.push({wt, v});
    }
    return cost;
}
