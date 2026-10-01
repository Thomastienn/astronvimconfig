from collections import deque

class MCMF:
    """
    Min cost max flow (SPFA), negative costs ok, no negative cycles
    Also min cost assignment / weighted bipartite matching
    add_edge(u, v, cap, cost) returns edge id e, flow on it = cap - self.cap[e]
    flow(s, t, maxf=INF) -> (flow, cost), stops early once flow reaches maxf
    Time: O(F V E) worst, fast in practice
    """
    def __init__(self, n: int):
        self.n = n
        self.adj: list[list[int]] = [[] for _ in range(n)]
        self.to: list[int] = []
        self.cap: list[int] = []
        self.cost: list[int] = []

    def add_edge(self, u: int, v: int, cap: int, cost: int) -> int:
        e = len(self.to)
        self.adj[u].append(e)
        self.to.append(v)
        self.cap.append(cap)
        self.cost.append(cost)
        self.adj[v].append(e + 1)
        self.to.append(u)
        self.cap.append(0)
        self.cost.append(-cost)
        return e

    def flow(self, s: int, t: int, maxf: int | float = float('inf')) -> tuple[int, int]:
        n, adj, to, cap, cost = self.n, self.adj, self.to, self.cap, self.cost
        INF = float('inf')
        flow = res = 0
        while flow < maxf:
            dist = [INF] * n
            inq = [False] * n
            prev = [-1] * n
            dist[s] = 0
            q = deque([s])
            while q:
                u = q.popleft()
                inq[u] = False
                for e in adj[u]:
                    v = to[e]
                    if cap[e] > 0 and dist[u] + cost[e] < dist[v]:
                        dist[v] = dist[u] + cost[e]
                        prev[v] = e
                        if not inq[v]:
                            inq[v] = True
                            q.append(v)
            if dist[t] == INF:
                break
            f = maxf - flow
            v = t
            while v != s:
                e = prev[v]
                f = min(f, cap[e])
                v = to[e ^ 1]
            v = t
            while v != s:
                e = prev[v]
                cap[e] -= f
                cap[e ^ 1] += f
                v = to[e ^ 1]
            flow += f
            res += f * dist[t]
        return flow, res # pyright: ignore
