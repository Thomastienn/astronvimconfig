def dnc_opt(n: int, k: int, cost) -> int | float:
    """
    Divide & conquer DP optimization: split a[0:n] into k groups, minimize total cost
    dp[g][i] = min over j < i of dp[g - 1][j] + cost(j, i), cost(j, i) = cost of a[j:i]
    Needs best j monotone in i (e.g. cost = (segment sum)^2, quadrangle inequality)
    Returns min total cost (inf if impossible)
    Time: O(k n log n) cost calls
    """
    INF = float('inf')
    prev = [0] + [INF] * n
    for _ in range(k):
        cur = [INF] * (n + 1)
        stack = [(1, n, 0, n - 1)]
        while stack:
            l, r, ol, orr = stack.pop()
            if l > r:
                continue
            m = (l + r) // 2
            best, bj = INF, ol
            for j in range(ol, min(m - 1, orr) + 1):
                v = prev[j] + cost(j, m)
                if v < best:
                    best, bj = v, j
            cur[m] = best
            stack.append((l, m - 1, ol, bj))
            stack.append((m + 1, r, bj, orr))
        prev = cur
    return prev[n]
