class HLD:
    """
    Heavy-light decomposition: path / subtree queries on a tree with seg tree or BIT
    Put value of u at base[pos[u]], build seg tree on base
    path(u, v) -> [(l, r), ...] half-open pos ranges covering path u..v
    Edge values: store on child, path(u, v, edges=True) skips the lca
    subtree(u) -> (l, r), lca(u, v)
    Time: O(log n) ranges per path
    """
    def __init__(self, n: int, adj: list[list[int]], root: int = 0):
        par = [-1] * n
        dep = [0] * n
        seen = [False] * n
        seen[root] = True
        order = []
        stack = [root]
        while stack:
            u = stack.pop()
            order.append(u)
            for v in adj[u]:
                if not seen[v]:
                    seen[v] = True
                    par[v] = u
                    dep[v] = dep[u] + 1
                    stack.append(v)
        size = [1] * n
        heavy = [-1] * n
        for u in reversed(order):
            p = par[u]
            if p != -1:
                size[p] += size[u]
                if heavy[p] == -1 or size[u] > size[heavy[p]]:
                    heavy[p] = u
        head = [0] * n
        pos = [0] * n
        t = 0
        stack = [root]
        while stack:
            h = u = stack.pop()
            while u != -1:
                head[u] = h
                pos[u] = t
                t += 1
                for v in adj[u]:
                    if v != par[u] and v != heavy[u]:
                        stack.append(v)
                u = heavy[u]
        self.par, self.dep, self.size, self.head, self.pos = par, dep, size, head, pos

    def path(self, u: int, v: int, edges: bool = False) -> list[tuple[int, int]]:
        head, pos, par, dep = self.head, self.pos, self.par, self.dep
        res = []
        while head[u] != head[v]:
            if dep[head[u]] < dep[head[v]]:
                u, v = v, u
            res.append((pos[head[u]], pos[u] + 1))
            u = par[head[u]]
        if dep[u] > dep[v]:
            u, v = v, u
        res.append((pos[u] + edges, pos[v] + 1))
        return res

    def subtree(self, u: int) -> tuple[int, int]:
        return self.pos[u], self.pos[u] + self.size[u]

    def lca(self, u: int, v: int) -> int:
        head, par, dep = self.head, self.par, self.dep
        while head[u] != head[v]:
            if dep[head[u]] < dep[head[v]]:
                u, v = v, u
            u = par[head[u]]
        return u if dep[u] < dep[v] else v
