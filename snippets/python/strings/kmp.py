def compute_lps(pattern: str) -> list[int]:
    """Compute Longest Proper Prefix which is also Suffix array"""
    m = len(pattern)
    lps = [0] * m
    length = 0
    i = 1
    
    while i < m:
        if pattern[i] == pattern[length]:
            length += 1
            lps[i] = length
            i += 1
        elif length:
            length = lps[length - 1]
        else:
            lps[i] = 0
            i += 1
    return lps

def kmp_search(text: str, pattern: str) -> list[int]:
    """Returns all starting indices where pattern is found in text"""
    if not pattern or len(pattern) > len(text):
        return []
    
    n, m = len(text), len(pattern)
    lps = compute_lps(pattern)
    result = []
    i = j = 0
    
    while i < n:
        if text[i] == pattern[j]:
            i += 1
            j += 1
        
        if j == m:
            result.append(i - j)
            j = lps[j - 1]
        elif i < n and text[i] != pattern[j]:
            j = lps[j - 1] if j else 0
            if j == 0 and text[i] != pattern[0]:
                i += 1
    return result
