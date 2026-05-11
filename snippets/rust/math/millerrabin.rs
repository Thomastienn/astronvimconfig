// Deterministic for n < 3.3 * 10^24 with these witnesses.
fn mulmod(a: u64, b: u64, m: u64) -> u64 {
    (a as u128 * b as u128 % m as u128) as u64
}
fn powmod(mut a: u64, mut b: u64, m: u64) -> u64 {
    let mut r = 1u64 % m;
    a %= m;
    while b > 0 {
        if b & 1 == 1 { r = mulmod(r, a, m); }
        a = mulmod(a, a, m);
        b >>= 1;
    }
    r
}
fn miller_rabin(n: u64) -> bool {
    if n < 2 { return false; }
    for p in [2u64, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37] {
        if n == p { return true; }
        if n % p == 0 { return false; }
    }
    let mut d = n - 1;
    let mut r = 0u32;
    while d & 1 == 0 { d >>= 1; r += 1; }
    'witness: for a in [2u64, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37] {
        if a >= n { continue; }
        let mut x = powmod(a, d, n);
        if x == 1 || x == n - 1 { continue; }
        for _ in 0..r - 1 {
            x = mulmod(x, x, n);
            if x == n - 1 { continue 'witness; }
        }
        return false;
    }
    true
}
