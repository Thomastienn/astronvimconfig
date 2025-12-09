def kosaraju(n, adj):
    # Build reverse graph
    rev_adj = [[] for _ in range(n)]
    for u in range(n):
        for v in adj[u]:
            rev_adj[v].append(u)
    
    # First DFS to get finish order
    visited = [False] * n
    order = []
    
    def dfs1(u):
        visited[u] = True
        for v in adj[u]:
            if not visited[v]:
                dfs1(v)
        order.append(u)
    
    for i in range(n):
        if not visited[i]:
            dfs1(i)
    
    # Second DFS on reverse graph in reverse finish order
    visited = [False] * n
    sccs = []
    
    def dfs2(u, scc):
        visited[u] = True
        scc.append(u)
        for v in rev_adj[u]:
            if not visited[v]:
                dfs2(v, scc)
    
    for u in reversed(order):
        if not visited[u]:
            scc = []
            dfs2(u, scc)
            sccs.append(scc)
    
    return sccs
