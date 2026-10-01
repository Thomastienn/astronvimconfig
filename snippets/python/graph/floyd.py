def floyd(n: int, edges: list[tuple[int, int, int]]) -> list[list[int | float]]:
    """
    All pairs shortest path (Floyd-Warshall), negative weights ok
    edges = [(u, v, w), ...] directed, d[i][i] < 0 => i is on a negative cycle
    Time: O(V^3), n <= ~400 in Python
    """
    INF = float('inf')
    d = [[INF] * n for _ in range(n)]
    for i in range(n):
        d[i][i] = 0
    for u, v, w in edges:
        if w < d[u][v]:
            d[u][v] = w
    for k in range(n):
        dk = d[k]
        for i in range(n):
            dik = d[i][k]
            if dik == INF:
                continue
            di = d[i]
            for j in range(n):
                if dik + dk[j] < di[j]:
                    di[j] = dik + dk[j]
    return d
