fn z_function(s: &[u8]) -> Vec<usize> {
    let n = s.len();
    let mut z = vec![0usize; n];
    if n == 0 { return z; }
    z[0] = n;
    let mut l = 0usize;
    let mut r = 0usize;
    for i in 1..n {
        if i <= r { z[i] = (r - i + 1).min(z[i - l]); }
        while i + z[i] < n && s[z[i]] == s[i + z[i]] { z[i] += 1; }
        if z[i] > 0 && i + z[i] - 1 > r { l = i; r = i + z[i] - 1; }
    }
    z
}
