fn sieve(n: usize) -> Vec<usize> {
    if n < 2 { return Vec::new(); }
    let mut is_p = vec![true; n + 1];
    is_p[0] = false; is_p[1] = false;
    let mut p = 2usize;
    while p * p <= n {
        if is_p[p] {
            let mut i = p * p;
            while i <= n { is_p[i] = false; i += p; }
        }
        p += 1;
    }
    (2..=n).filter(|&x| is_p[x]).collect()
}
