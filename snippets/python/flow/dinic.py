from collections import deque

class Dinic:
    """
    Max flow
    add_edge(u, v, cap) returns edge id e, flow on it = cap - self.cap[e]
    max_flow(s, t); afterwards level[u] != -1 <=> u on source side of min cut
    Time: O(V^2 E), O(E sqrt V) on unit capacity
    """
    def __init__(self, n: int):
        self.n = n
        self.adj: list[list[int]] = [[] for _ in range(n)]
        self.to: list[int] = []
        self.cap: list[int] = []
        self.level = [-1] * n
        self.ptr = [0] * n

    def add_edge(self, u: int, v: int, cap: int, rcap: int = 0) -> int:
        e = len(self.to)
        self.adj[u].append(e)
        self.to.append(v)
        self.cap.append(cap)
        self.adj[v].append(e + 1)
        self.to.append(u)
        self.cap.append(rcap)
        return e

    def bfs(self, s: int, t: int) -> bool:
        adj, to, cap = self.adj, self.to, self.cap
        level = [-1] * self.n
        level[s] = 0
        q = deque([s])
        while q:
            u = q.popleft()
            for e in adj[u]:
                v = to[e]
                if cap[e] > 0 and level[v] == -1:
                    level[v] = level[u] + 1
                    q.append(v)
        self.level = level
        return level[t] != -1

    def dfs(self, s: int, t: int) -> int:
        # iterative, path[i] is the edge from stack[i] to stack[i + 1]
        adj, to, cap, level, ptr = self.adj, self.to, self.cap, self.level, self.ptr
        stack, path = [s], []
        while stack:
            u = stack[-1]
            if u == t:
                f = min(cap[e] for e in path)
                for e in path:
                    cap[e] -= f
                    cap[e ^ 1] += f
                return f
            while ptr[u] < len(adj[u]):
                e = adj[u][ptr[u]]
                if cap[e] > 0 and level[to[e]] == level[u] + 1:
                    break
                ptr[u] += 1
            if ptr[u] < len(adj[u]):
                e = adj[u][ptr[u]]
                path.append(e)
                stack.append(to[e])
            else:
                stack.pop()
                if path:
                    path.pop()
                    ptr[stack[-1]] += 1
        return 0

    def max_flow(self, s: int, t: int) -> int:
        flow = 0
        while self.bfs(s, t):
            self.ptr = [0] * self.n
            while f := self.dfs(s, t):
                flow += f
        return flow
