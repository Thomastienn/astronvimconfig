fn pow_mod(mut a: u64, mut b: u64, m: u64) -> u64 {
    let mut r = 1u64 % m;
    a %= m;
    while b > 0 {
        if b & 1 == 1 { r = r * a % m; }
        a = a * a % m;
        b >>= 1;
    }
    r
}
