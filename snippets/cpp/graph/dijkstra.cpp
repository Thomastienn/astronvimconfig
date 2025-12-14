vi dijkstra(vector<vpii> &g, int s) {
    int n = sza(g); vi d(n, INF); d[s] = 0;
    priority_queue<pii, vpii, greater<pii>> pq; pq.push({0, s});
    while (!pq.empty()) {
        auto [dist, u] = pq.top(); pq.pop();
        if (dist > d[u]) continue;
        for (auto [v, w] : g[u])
            if (d[u] + w < d[v])
                d[v] = d[u] + w, pq.push({d[v], v});
    }
    return d;
}
