def reroot(n: int, adj: list[list[int]], e, merge, add_root, root: int = 0) -> list:
    """
    Rerooting DP: answer of a tree dp for every node as root in O(n)
    merge(x, y): combine values of child subtrees (associative), e: identity
    add_root(x, u): merged children x -> value of subtree rooted at u
    Sum of distances to all nodes, value = (sum dist, size):
        e = (0, 0), merge = lambda x, y: (x[0] + y[0], x[1] + y[1])
        add_root = lambda x, u: (x[0] + x[1], x[1] + 1)
    Farthest node distance, value = height: e = -1, merge = max, add_root = lambda x, u: x + 1
    Returns ans[u] = add_root(merge over all neighbours, u)
    """
    par = [-1] * n
    seen = [False] * n
    seen[root] = True
    order = [root]
    for u in order:
        for v in adj[u]:
            if not seen[v]:
                seen[v] = True
                par[v] = u
                order.append(v)
    down = [e] * n
    for u in reversed(order):
        acc = e
        for v in adj[u]:
            if v != par[u]:
                acc = merge(acc, down[v])
        down[u] = add_root(acc, u)
    up = [e] * n
    ans = [e] * n
    for u in order:
        vals = [up[u] if v == par[u] else down[v] for v in adj[u]]
        k = len(vals)
        pre = [e] * (k + 1)
        for i in range(k):
            pre[i + 1] = merge(pre[i], vals[i])
        ans[u] = add_root(pre[k], u)
        suf = e
        for i in range(k - 1, -1, -1):
            v = adj[u][i]
            if v != par[u]:
                up[v] = add_root(merge(pre[i], suf), u)
            suf = merge(vals[i], suf)
    return ans
