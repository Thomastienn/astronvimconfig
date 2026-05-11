// Requires the `point` snippet.
fn polygon_area(p: &[Pt]) -> f64 {
    let n = p.len();
    let mut a = 0.0;
    for i in 0..n { a += p[i].cross(p[(i + 1) % n]); }
    a.abs() / 2.0
}
// Ray-casting point-in-polygon test (returns true for points strictly inside).
fn in_polygon(p: &[Pt], q: Pt) -> bool {
    let n = p.len();
    let mut cnt = 0;
    for i in 0..n {
        let a = p[i];
        let b = p[(i + 1) % n];
        if (a.y <= q.y && q.y < b.y) || (b.y <= q.y && q.y < a.y) {
            let xi = a.x + (b.x - a.x) * (q.y - a.y) / (b.y - a.y);
            if q.x < xi { cnt += 1; }
        }
    }
    cnt & 1 == 1
}
