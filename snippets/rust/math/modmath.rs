// All inputs assumed in [0, m).
fn add(a: u64, b: u64, m: u64) -> u64 { let v = a + b; if v >= m { v - m } else { v } }
fn sub(a: u64, b: u64, m: u64) -> u64 { if a >= b { a - b } else { a + m - b } }
fn mul(a: u64, b: u64, m: u64) -> u64 { (a as u128 * b as u128 % m as u128) as u64 }
fn power(mut a: u64, mut b: u64, m: u64) -> u64 {
    let mut r = 1u64 % m;
    a %= m;
    while b > 0 {
        if b & 1 == 1 { r = mul(r, a, m); }
        a = mul(a, a, m);
        b >>= 1;
    }
    r
}
// Modular inverse via Fermat's little theorem; requires `m` to be prime.
fn inv(a: u64, m: u64) -> u64 { power(a, m - 2, m) }
