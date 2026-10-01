def hungarian(cost: list[list[int]]) -> tuple[int, list[int]]:
    """
    Min cost assignment, cost is n x m with n <= m (transpose if not)
    Max weight: negate costs
    Returns (total cost, assign) where row i -> column assign[i]
    Time: O(n^2 m)
    """
    n, m = len(cost), len(cost[0])
    INF = float('inf')
    u = [0] * (n + 1)
    v = [0] * (m + 1)
    p = [0] * (m + 1)  # p[j] = row matched to column j (1-indexed, 0 = none)
    way = [0] * (m + 1)

    for i in range(1, n + 1):
        p[0] = i
        j0 = 0
        minv = [INF] * (m + 1)
        used = [False] * (m + 1)
        while True:
            used[j0] = True
            i0, delta, j1 = p[j0], INF, 0
            for j in range(1, m + 1):
                if not used[j]:
                    cur = cost[i0 - 1][j - 1] - u[i0] - v[j]
                    if cur < minv[j]:
                        minv[j] = cur
                        way[j] = j0
                    if minv[j] < delta:
                        delta = minv[j]
                        j1 = j
            for j in range(m + 1):
                if used[j]:
                    u[p[j]] += delta
                    v[j] -= delta
                else:
                    minv[j] -= delta
            j0 = j1
            if p[j0] == 0:
                break
        while j0:
            j1 = way[j0]
            p[j0] = p[j1]
            j0 = j1

    assign = [-1] * n
    for j in range(1, m + 1):
        if p[j]:
            assign[p[j] - 1] = j - 1
    return sum(cost[i][assign[i]] for i in range(n)), assign
