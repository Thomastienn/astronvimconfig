def centroid(n: int, adj: list[list[int]]) -> list[int]:
    """
    Centroid decomposition: cpar[u] = parent of u in centroid tree (-1 = root)
    Centroid tree depth O(log n), path u..v passes through lca of u, v in centroid tree
    Use: count / min over all paths, nearest marked node queries
    Time: O(n log n)
    """
    removed = [False] * n
    cpar = [-1] * n
    size = [0] * n
    tpar = [-1] * n
    stack = [(0, -1)]
    while stack:
        s, p = stack.pop()
        tpar[s] = -1
        order = [s]
        for u in order:
            for v in adj[u]:
                if v != tpar[u] and not removed[v]:
                    tpar[v] = u
                    order.append(v)
        for u in order:
            size[u] = 1
        for u in reversed(order):
            if tpar[u] != -1:
                size[tpar[u]] += size[u]
        total = len(order)
        c = s
        while True:
            for v in adj[c]:
                if v != tpar[c] and not removed[v] and size[v] * 2 > total:
                    c = v
                    break
            else:
                break
        removed[c] = True
        cpar[c] = p
        for v in adj[c]:
            if not removed[v]:
                stack.append((v, c))
    return cpar
