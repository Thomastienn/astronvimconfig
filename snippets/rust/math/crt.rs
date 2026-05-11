// Chinese Remainder Theorem for non-coprime moduli.
// Returns Some((x, M)) where x is the unique solution mod M = lcm(m_i),
// or None if the system is inconsistent. Requires `extgcd`.
fn crt(r: &[i64], m: &[i64]) -> Option<(i64, i64)> {
    let mut x: i128 = 0;
    let mut bm: i128 = 1;
    for i in 0..r.len() {
        let (g, p, _) = extgcd(bm as i64, m[i]);
        let g = g as i128;
        let p = p as i128;
        let mi = m[i] as i128;
        let ri = r[i] as i128;
        if (ri - x).rem_euclid(g) != 0 { return None; }
        let lcm = bm / g * mi;
        let shift = ((ri - x) / g) % (mi / g) * p % (mi / g);
        x = (x + bm * shift).rem_euclid(lcm);
        bm = lcm;
    }
    Some((x as i64, bm as i64))
}
