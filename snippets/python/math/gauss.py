def gauss(a: list[list[int]], b: list[int], mod: int = 10**9 + 7) -> tuple[list[int] | None, int]:
    """
    Solve linear system A x = b (mod prime) by Gaussian elimination
    a: n x m matrix, b: length n
    Returns (x, rank), x = one solution (free vars 0) or None if no solution
    Number of solutions = mod^(m - rank), det / inverse use the same elimination
    Time: O(n m min(n, m))
    """
    n = len(a)
    m = len(a[0]) if n else 0
    M = [[v % mod for v in row] + [bi % mod] for row, bi in zip(a, b)]
    where = [-1] * m
    r = 0
    for c in range(m):
        if r == n:
            break
        piv = next((i for i in range(r, n) if M[i][c]), -1)
        if piv == -1:
            continue
        M[r], M[piv] = M[piv], M[r]
        inv = pow(M[r][c], mod - 2, mod)
        Mr = M[r] = [x * inv % mod for x in M[r]]
        for i in range(n):
            if i != r and M[i][c]:
                f = M[i][c]
                M[i] = [(x - f * y) % mod for x, y in zip(M[i], Mr)]
        where[c] = r
        r += 1
    for i in range(r, n):
        if M[i][m]:
            return None, r
    x = [0] * m
    for c in range(m):
        if where[c] != -1:
            x[c] = M[where[c]][m]
    return x, r
