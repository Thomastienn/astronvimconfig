def gale_shapley(prop_pref: list[list[int]], recv_pref: list[list[int]]) -> list[int]:
    """
    Stable matching, n proposers and n receivers
    prop_pref[p] = receivers in order of preference (best first), same for recv_pref[r]
    Returns match[p] = receiver, proposer-optimal
    Time: O(n^2)
    """
    n = len(prop_pref)
    rank = [[0] * n for _ in range(n)]
    for r in range(n):
        for i, p in enumerate(recv_pref[r]):
            rank[r][p] = i

    nxt = [0] * n
    recv_match = [-1] * n
    free = list(range(n))
    while free:
        p = free.pop()
        r = prop_pref[p][nxt[p]]
        nxt[p] += 1
        cur = recv_match[r]
        if cur == -1:
            recv_match[r] = p
        elif rank[r][p] < rank[r][cur]:
            recv_match[r] = p
            free.append(cur)
        else:
            free.append(p)

    match = [-1] * n
    for r, p in enumerate(recv_match):
        match[p] = r
    return match
