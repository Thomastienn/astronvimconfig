// Returns (g, x, y) where g = gcd(a, b) and a*x + b*y = g.
fn extgcd(a: i64, b: i64) -> (i64, i64, i64) {
    if b == 0 { (a, 1, 0) } else {
        let (g, x1, y1) = extgcd(b, a % b);
        (g, y1, x1 - (a / b) * y1)
    }
}
// Modular inverse via extgcd (works for any coprime modulus).
fn mod_inv(a: i64, m: i64) -> Option<i64> {
    let (g, x, _) = extgcd(a, m);
    if g != 1 { None } else { Some(((x % m) + m) % m) }
}
