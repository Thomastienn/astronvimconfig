def prim(n, adj):
    import heapq
    
    visited = [False] * n
    min_heap = [(0, 0, -1)]  # (weight, node, parent)
    total_weight = 0
    edges = []
    
    while min_heap:
        weight, u, parent = heapq.heappop(min_heap)
        
        if visited[u]:
            continue
        
        visited[u] = True
        total_weight += weight
        
        if parent != -1:
            edges.append((parent, u, weight))
        
        for v, w in adj[u]:
            if not visited[v]:
                heapq.heappush(min_heap, (w, v, u))
    
    return total_weight, edges
