def z_function(s: str) -> list[int]:
    """
    z[i] = length of longest substring starting at i which is also a prefix
    Time: O(n)
    """
    n = len(s)
    z = [0] * n
    z[0] = n
    l = r = 0
    
    for i in range(1, n):
        if i < r:
            z[i] = min(r - i, z[i - l])
        while i + z[i] < n and s[z[i]] == s[i + z[i]]:
            z[i] += 1
        if i + z[i] > r:
            l, r = i, i + z[i]
    return z

def z_search(text: str, pattern: str) -> list[int]:
    """Find all occurrences of pattern in text using Z-algorithm"""
    if not pattern:
        return []
    concat = pattern + "$" + text
    z = z_function(concat)
    m = len(pattern)
    return [i - m - 1 for i in range(m + 1, len(concat)) if z[i] >= m]
