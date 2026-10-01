def bellman_ford(n: int, edges: list[tuple[int, int, int]], start: int) -> list[int | float]:
    """
    Single source shortest path with negative weights (Bellman-Ford)
    edges = [(u, v, w), ...] directed
    Returns dist: inf = unreachable, -inf = can get arbitrarily small (negative cycle)
    Time: O(VE)
    """
    INF = float('inf')
    dist = [INF] * n
    dist[start] = 0
    for _ in range(n - 1):
        changed = False
        for u, v, w in edges:
            if dist[u] != INF and dist[u] + w < dist[v]:
                dist[v] = dist[u] + w
                changed = True
        if not changed:
            return dist
    for _ in range(n):
        for u, v, w in edges:
            if dist[u] != INF and dist[u] + w < dist[v]:
                dist[v] = -INF
    return dist
