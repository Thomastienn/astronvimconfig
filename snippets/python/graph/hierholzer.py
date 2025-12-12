from collections import defaultdict

# For directed graphs
def hierholzer_directed(n, edges, start):
    """
    Args:
        n: number of vertices
        edges: list of (u, v) tuples
        start: starting vertex
    Returns:
        list representing Eulerian path/circuit
    """
    adj = defaultdict(list)  # adj[u] = [(v, edge_idx), ...]
    used = [False] * len(edges)
    
    for i, (u, v) in enumerate(edges):
        adj[u].append((v, i))
    
    path = []
    stack = [start]
    
    while stack:
        u = stack[-1]
        
        # Remove used edges from adjacency list
        while adj[u] and used[adj[u][-1][1]]:
            adj[u].pop()
        
        if not adj[u]:
            path.append(u)
            stack.pop()
        else:
            v, idx = adj[u].pop()
            used[idx] = True
            stack.append(v)
    
    return path[::-1]  # Reverse to get correct order


# For undirected graphs
def hierholzer_undirected(n, edges, start):
    """
    Args:
        n: number of vertices
        edges: list of (u, v) tuples
        start: starting vertex
    Returns:
        list representing Eulerian path/circuit
    """
    adj = defaultdict(list)
    used = [False] * len(edges)
    
    for i, (u, v) in enumerate(edges):
        adj[u].append((v, i))
        adj[v].append((u, i))
    
    path = []
    stack = [start]
    
    while stack:
        u = stack[-1]
        
        # Remove used edges from adjacency list
        while adj[u] and used[adj[u][-1][1]]:
            adj[u].pop()
        
        if not adj[u]:
            path.append(u)
            stack.pop()
        else:
            v, idx = adj[u].pop()
            used[idx] = True
            stack.append(v)
    
    return path[::-1]


# Helper: Check if Eulerian path/circuit exists (undirected)
def check_eulerian_undirected(n, edges):
    """
    Returns: ('circuit', start) or ('path', start) or (None, None)
    """
    degree = [0] * n
    for u, v in edges:
        degree[u] += 1
        degree[v] += 1
    
    odd_vertices = [v for v in range(n) if degree[v] % 2 == 1]
    
    if len(odd_vertices) == 0:
        # Find any vertex with edges
        for v in range(n):
            if degree[v] > 0:
                return ('circuit', v)
        return (None, None)
    elif len(odd_vertices) == 2:
        return ('path', odd_vertices[0])
    else:
        return (None, None)


# Helper: Check if Eulerian path/circuit exists (directed)
def check_eulerian_directed(n, edges):
    """
    Returns: ('circuit', start) or ('path', start) or (None, None)
    """
    in_deg = [0] * n
    out_deg = [0] * n
    
    for u, v in edges:
        out_deg[u] += 1
        in_deg[v] += 1
    
    start_node = None
    end_node = None
    
    for v in range(n):
        if out_deg[v] - in_deg[v] == 1:
            if start_node is not None:
                return (None, None)
            start_node = v
        elif in_deg[v] - out_deg[v] == 1:
            if end_node is not None:
                return (None, None)
            end_node = v
        elif in_deg[v] != out_deg[v]:
            return (None, None)
    
    if start_node is None and end_node is None:
        # Circuit exists, find any vertex with edges
        for v in range(n):
            if out_deg[v] > 0:
                return ('circuit', v)
        return (None, None)
    elif start_node is not None and end_node is not None:
        return ('path', start_node)
    else:
        return (None, None)
