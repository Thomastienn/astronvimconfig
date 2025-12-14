ll kruskal(int n, vector<array<int,3>> &edges) {
    sort(all(edges));
    DSU dsu(n); ll cost = 0;
    for (auto [w, u, v] : edges)
        if (dsu.unite(u, v)) cost += w;
    return cost;
}
