// Requires the `point` snippet (struct Pt with cross/dot/len/...).
struct Line { p: Pt, d: Pt }
impl Line {
    fn new(p: Pt, d: Pt) -> Self { Self { p, d } }
    fn eval(&self, t: f64) -> Pt { self.p + self.d * t }
    fn dist(&self, q: Pt) -> f64 { (self.d.cross(q - self.p)).abs() / self.d.len() }
}
// Returns Some(intersection) or None if parallel.
fn line_inter(l1: &Line, l2: &Line) -> Option<Pt> {
    let det = l1.d.cross(l2.d);
    if det.abs() < 1e-12 { return None; }
    let t = (l2.p - l1.p).cross(l2.d) / det;
    Some(l1.eval(t))
}
