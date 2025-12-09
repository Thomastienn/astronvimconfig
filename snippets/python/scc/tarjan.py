def tarjan(n, adj) -> list[list[int]]:
    disc = [-1] * n
    low = [-1] * n
    on_stack = [False] * n
    stack = []
    time = [0]
    sccs = []
    
    def dfs(u):
        disc[u] = low[u] = time[0]
        time[0] += 1
        stack.append(u)
        on_stack[u] = True
        
        for v in adj[u]:
            if disc[v] == -1:
                dfs(v)
                low[u] = min(low[u], low[v])
            elif on_stack[v]:
                low[u] = min(low[u], disc[v])
        
        if low[u] == disc[u]:
            scc = []
            while True:
                node = stack.pop()
                on_stack[node] = False
                scc.append(node)
                if node == u:
                    break
            sccs.append(scc)
    
    for i in range(n):
        if disc[i] == -1:
            dfs(i)
    
    return sccs
