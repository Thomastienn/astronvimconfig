def kruskal(n, edges):
    dsu = DSU(n) # type: ignore # noqa
    
    # Sort edges by weight
    edges.sort(key=lambda x: x[2])
    
    total_weight = 0
    mst_edges = []
    
    for u, v, weight in edges:
        if dsu.find(u) != dsu.find(v):
            dsu.union(u, v)
            total_weight += weight
            mst_edges.append((u, v, weight))
            if len(mst_edges) == n - 1:
                break
    
    return total_weight, mst_edges
