def bridges(n: int, edges: list[tuple[int, int]]) -> tuple[list[int], list[int]]:
    """
    Bridges and articulation points (cut edges / cut vertices), undirected graph
    edges = [(u, v), ...], multi-edges ok
    Returns (bridge edge indices, articulation vertices)
    Time: O(V + E)
    """
    adj = [[] for _ in range(n)]
    for i, (u, v) in enumerate(edges):
        adj[u].append((v, i))
        adj[v].append((u, i))
    tin = [-1] * n
    low = [0] * n
    ptr = [0] * n
    pe = [-1] * n
    is_cut = [False] * n
    br = []
    t = 0
    for r in range(n):
        if tin[r] != -1:
            continue
        tin[r] = low[r] = t
        t += 1
        children = 0
        stack = [r]
        while stack:
            u = stack[-1]
            if ptr[u] < len(adj[u]):
                v, i = adj[u][ptr[u]]
                ptr[u] += 1
                if i == pe[u]:
                    continue
                if tin[v] == -1:
                    tin[v] = low[v] = t
                    t += 1
                    pe[v] = i
                    stack.append(v)
                    if u == r:
                        children += 1
                else:
                    low[u] = min(low[u], tin[v])
            else:
                stack.pop()
                if stack:
                    p = stack[-1]
                    low[p] = min(low[p], low[u])
                    if low[u] > tin[p]:
                        br.append(pe[u])
                    if p != r and low[u] >= tin[p]:
                        is_cut[p] = True
        if children > 1:
            is_cut[r] = True
    return br, [u for u in range(n) if is_cut[u]]
