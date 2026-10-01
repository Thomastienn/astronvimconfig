def flatten_tree(n: int, adj: list[list[int]], root: int = 0) -> tuple[list[int], list[int], list[int]]:
    """
    Euler tour / flatten tree: subtree of u = contiguous range [tin[u], tout[u])
    order[tin[u]] = u, subtree query / update -> range query on BIT or seg tree
    u is ancestor of v <=> tin[u] <= tin[v] < tout[u]
    Returns (tin, tout, order)
    Time: O(n)
    """
    tin = [0] * n
    size = [1] * n
    par = [-1] * n
    seen = [False] * n
    seen[root] = True
    order = []
    stack = [root]
    while stack:
        u = stack.pop()
        tin[u] = len(order)
        order.append(u)
        for v in adj[u]:
            if not seen[v]:
                seen[v] = True
                par[v] = u
                stack.append(v)
    for u in reversed(order):
        if par[u] != -1:
            size[par[u]] += size[u]
    tout = [tin[u] + size[u] for u in range(n)]
    return tin, tout, order
