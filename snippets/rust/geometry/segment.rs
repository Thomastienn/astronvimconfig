// Requires the `point` snippet.
struct Seg { a: Pt, b: Pt }
impl Seg {
    fn new(a: Pt, b: Pt) -> Self { Self { a, b } }
    fn dist(&self, p: Pt) -> f64 {
        let ab = self.b - self.a;
        let ap = p - self.a;
        let bp = p - self.b;
        if ab.dot(ap) < 0.0 { return ap.len(); }
        if ab.dot(bp) > 0.0 { return bp.len(); }
        (ab.cross(ap)).abs() / ab.len()
    }
    fn contains(&self, p: Pt) -> bool {
        (self.b - self.a).cross(p - self.a).abs() < 1e-9
            && (p - self.a).dot(p - self.b) <= 0.0
    }
}
