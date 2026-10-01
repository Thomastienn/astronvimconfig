def mo(n: int, queries: list[tuple[int, int]], add, remove, get) -> list:
    """
    Mo's algorithm: offline range queries [l, r) by sliding a window
    add(i) / remove(i): put / take a[i] in the window, get(): answer for current window
    Example distinct count: add -> cnt[a[i]] += 1 (distinct += cnt == 1), remove reverse
    Returns answers in input order
    Time: O((n + q) sqrt n) add / remove calls
    """
    q = len(queries)
    B = max(1, int(n / max(1, q) ** 0.5))
    order = sorted(range(q), key=lambda i: (
        queries[i][0] // B,
        queries[i][1] if (queries[i][0] // B) & 1 == 0 else -queries[i][1]
    ))
    ans = [None] * q
    cl = cr = 0
    for i in order:
        l, r = queries[i]
        while cr < r:
            add(cr)
            cr += 1
        while cl > l:
            cl -= 1
            add(cl)
        while cr > r:
            cr -= 1
            remove(cr)
        while cl < l:
            remove(cl)
            cl += 1
        ans[i] = get()
    return ans
