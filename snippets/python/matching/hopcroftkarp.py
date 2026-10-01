from collections import deque

def hopcroft_karp(
        adj: list[list[int]],
        n_left: int,
        n_right: int
) -> tuple[int, list[int], list[int]]:
    """
    Maximum bipartite matching
    adj[u] = [v, ...] for left u in [0, n_left), right v in [0, n_right)
    Returns (size, match_l, match_r), -1 = unmatched
    Time: O(E sqrt V)
    """
    INF = float('inf')
    match_l = [-1] * n_left
    match_r = [-1] * n_right
    dist = [0] * n_left
    ptr = [0] * n_left

    def bfs():
        q = deque()
        for u in range(n_left):
            if match_l[u] == -1:
                dist[u] = 0
                q.append(u)
            else:
                dist[u] = INF
        found = False
        while q:
            u = q.popleft()
            for v in adj[u]:
                w = match_r[v]
                if w == -1:
                    found = True
                elif dist[w] == INF:
                    dist[w] = dist[u] + 1
                    q.append(w)
        return found

    def dfs(root):
        # iterative, stack[i] -> path[i] is the edge taken at depth i
        stack, path = [root], []
        while stack:
            u = stack[-1]
            if ptr[u] < len(adj[u]):
                v = adj[u][ptr[u]]
                ptr[u] += 1
                w = match_r[v]
                if w == -1:
                    path.append(v)
                    for a, b in zip(stack, path):
                        match_l[a] = b
                        match_r[b] = a
                    return True
                if dist[w] == dist[u] + 1:
                    path.append(v)
                    stack.append(w)
            else:
                dist[u] = INF
                stack.pop()
                if path:
                    path.pop()
        return False

    res = 0
    while bfs():
        ptr[:] = [0] * n_left
        for u in range(n_left):
            if match_l[u] == -1 and dfs(u):
                res += 1
    return res, match_l, match_r
