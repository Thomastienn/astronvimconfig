from bisect import bisect_left

def lis(a: list[int]) -> list[int]:
    """
    Longest increasing subsequence (strict), returns one LIS
    Non-decreasing: use bisect_right
    Time: O(n log n)
    """
    tails, idx = [], []
    prev = [-1] * len(a)
    for i, x in enumerate(a):
        j = bisect_left(tails, x)
        if j == len(tails):
            tails.append(x)
            idx.append(i)
        else:
            tails[j] = x
            idx[j] = i
        prev[i] = idx[j - 1] if j else -1
    res = []
    i = idx[-1] if idx else -1
    while i != -1:
        res.append(a[i])
        i = prev[i]
    return res[::-1]
