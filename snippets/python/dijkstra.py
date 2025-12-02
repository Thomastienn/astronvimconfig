from heapq import heappush, heappop

def dijkstra(
        graph: list[list[tuple[int, int]]] | dict[int, list[tuple[int, int]]],
        start: int
) -> list[int | float]:
    """
    Single source shortest path for non-negative weights
    graph[u] = [(v, weight), ...]
    Returns dist array from start
    Time: O((V + E) log V)
    """
    n = len(graph)
    dist = [float('inf')] * n
    dist[start] = 0
    pq = [(0, start)]
    
    while pq:
        d, u = heappop(pq)
        if d > dist[u]:
            continue
        for v, w in graph[u]:
            if dist[u] + w < dist[v]:
                dist[v] = dist[u] + w
                heappush(pq, (dist[v], v)) # pyright: ignore
    return dist
