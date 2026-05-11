// Ternary search for the minimum of a unimodal function on [l, r].
// Use ~200 iterations to get within machine precision.
fn ternary_search<F: Fn(f64) -> f64>(mut l: f64, mut r: f64, f: F) -> f64 {
    for _ in 0..200 {
        let m1 = l + (r - l) / 3.0;
        let m2 = r - (r - l) / 3.0;
        if f(m1) < f(m2) { r = m2; } else { l = m1; }
    }
    l
}
