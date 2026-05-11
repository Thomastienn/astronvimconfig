fn kmp_table(s: &[u8]) -> Vec<usize> {
    let n = s.len();
    let mut lps = vec![0usize; n];
    let mut k = 0;
    for i in 1..n {
        while k > 0 && s[i] != s[k] { k = lps[k - 1]; }
        if s[i] == s[k] { k += 1; }
        lps[i] = k;
    }
    lps
}
// Returns starting indices (0-based) of every occurrence of `pat` in `txt`.
fn kmp_search(txt: &[u8], pat: &[u8]) -> Vec<usize> {
    let mut res = Vec::new();
    if pat.is_empty() { return res; }
    let lps = kmp_table(pat);
    let mut j = 0;
    for i in 0..txt.len() {
        while j > 0 && txt[i] != pat[j] { j = lps[j - 1]; }
        if txt[i] == pat[j] { j += 1; }
        if j == pat.len() { res.push(i + 1 - j); j = lps[j - 1]; }
    }
    res
}
