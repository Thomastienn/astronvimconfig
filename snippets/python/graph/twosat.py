class TwoSat:
    """
    2-SAT: boolean vars x_0..x_{n-1}, clauses (x_i == f) or (x_j == g)
    add_clause(i, f, j, g); x_i must be f: add_clause(i, f, i, f)
    x_i implies x_j: add_clause(i, False, j, True)
    solve() -> list of bools, or None if unsatisfiable
    Time: O(n + clauses)
    """
    def __init__(self, n: int):
        self.n = n
        self.adj: list[list[int]] = [[] for _ in range(2 * n)]

    def add_clause(self, i: int, f: bool, j: int, g: bool):
        # node 2i + 1 = x_i true, 2i = x_i false
        self.adj[2 * i + (not f)].append(2 * j + g)
        self.adj[2 * j + (not g)].append(2 * i + f)

    def solve(self) -> list[bool] | None:
        N, adj = 2 * self.n, self.adj
        idx = [-1] * N
        low = [0] * N
        comp = [-1] * N
        ptr = [0] * N
        st = []
        t = c = 0
        for r in range(N):
            if idx[r] != -1:
                continue
            idx[r] = low[r] = t
            t += 1
            st.append(r)
            call = [r]
            while call:
                u = call[-1]
                if ptr[u] < len(adj[u]):
                    v = adj[u][ptr[u]]
                    ptr[u] += 1
                    if idx[v] == -1:
                        idx[v] = low[v] = t
                        t += 1
                        st.append(v)
                        call.append(v)
                    elif comp[v] == -1:
                        low[u] = min(low[u], idx[v])
                else:
                    call.pop()
                    if call:
                        low[call[-1]] = min(low[call[-1]], low[u])
                    if low[u] == idx[u]:
                        while True:
                            w = st.pop()
                            comp[w] = c
                            if w == u:
                                break
                        c += 1
        res = []
        for i in range(self.n):
            if comp[2 * i] == comp[2 * i + 1]:
                return None
            res.append(comp[2 * i + 1] < comp[2 * i])
        return res
