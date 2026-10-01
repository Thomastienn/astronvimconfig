def suffix_array(s: str | list[int]) -> tuple[list[int], list[int]]:
    """
    Suffix array + LCP array (prefix doubling + Kasai)
    sa[i] = start of i-th smallest suffix
    lcp[i] = longest common prefix of suffixes sa[i] and sa[i + 1]
    Distinct substrings = n(n+1)/2 - sum(lcp)
    Time: O(n log^2 n), ok for n ~ 2e5
    """
    n = len(s)
    mp = {c: i for i, c in enumerate(sorted(set(s)))}
    rank = [mp[c] for c in s]
    sa = list(range(n))
    k = 1
    while n:
        key = [rank[i] * (n + 1) + (rank[i + k] + 1 if i + k < n else 0) for i in range(n)]
        sa.sort(key=key.__getitem__)
        new = [0] * n
        for j in range(1, n):
            new[sa[j]] = new[sa[j - 1]] + (key[sa[j]] != key[sa[j - 1]])
        rank = new
        if rank[sa[-1]] == n - 1:
            break
        k <<= 1
    lcp = [0] * max(n - 1, 0)
    h = 0
    for i in range(n):
        if rank[i] == 0:
            h = 0
            continue
        j = sa[rank[i] - 1]
        while i + h < n and j + h < n and s[i + h] == s[j + h]:
            h += 1
        lcp[rank[i] - 1] = h
        if h:
            h -= 1
    return sa, lcp
