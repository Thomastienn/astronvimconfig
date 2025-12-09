import math
from collections import deque

class LCA:
    """
    Lowest Common Ancestor using Binary Lifting
    - Build: O(n log n)
    - Query: O(log n)
    """
    def __init__(self, n: int, adj: list[list[int]], root: int = 0):
        self.n = n
        self.LOG = max(1, n.bit_length())
        self.depth = [0] * n
        self.parent = [[-1] * n for _ in range(self.LOG)]
        self._build(adj, root)
    
    def _build(self, adj: list[list[int]], root: int):
        # BFS to set depth and immediate parent
        visited = [False] * self.n
        queue = deque([root])
        visited[root] = True
        self.depth[root] = 0
        self.parent[0][root] = root  # root's parent is itself
        
        while queue:
            u = queue.popleft()
            for v in adj[u]:
                if not visited[v]:
                    visited[v] = True
                    self.depth[v] = self.depth[u] + 1
                    self.parent[0][v] = u
                    queue.append(v)
        
        # Build sparse table
        for k in range(1, self.LOG):
            for v in range(self.n):
                if self.parent[k-1][v] != -1:
                    self.parent[k][v] = self.parent[k-1][self.parent[k-1][v]]
    
    def kth_ancestor(self, u: int, k: int) -> int:
        """Returns k-th ancestor of u, or -1 if doesn't exist"""
        for i in range(self.LOG):
            if k & (1 << i):
                u = self.parent[i][u]
                if u == -1:
                    return -1
        return u
    
    def lca(self, u: int, v: int) -> int:
        """Returns LCA of nodes u and v"""
        # Make u the deeper node
        if self.depth[u] < self.depth[v]:
            u, v = v, u
        
        # Bring u to same depth as v
        diff = self.depth[u] - self.depth[v]
        for i in range(self.LOG):
            if diff & (1 << i):
                u = self.parent[i][u]
        
        if u == v:
            return u
        
        # Binary search for LCA
        for i in range(self.LOG - 1, -1, -1):
            if self.parent[i][u] != self.parent[i][v]:
                u = self.parent[i][u]
                v = self.parent[i][v]
        
        return self.parent[0][u]
    
    def dist(self, u: int, v: int) -> int:
        """Returns distance (edges) between u and v"""
        return self.depth[u] + self.depth[v] - 2 * self.depth[self.lca(u, v)]
