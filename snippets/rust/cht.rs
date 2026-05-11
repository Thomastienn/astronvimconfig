// Convex Hull Trick (monotonic) for min queries.
// Add lines `y = m*x + b` in order of decreasing slope `m`; query `x` in increasing order.
struct CHT {
    lines: std::collections::VecDeque<(i64, i64)>,
}
impl CHT {
    fn new() -> Self { Self { lines: std::collections::VecDeque::new() } }
    fn bad(l1: (i64, i64), l2: (i64, i64), l3: (i64, i64)) -> bool {
        (l1.1 - l2.1) as i128 * (l3.0 - l2.0) as i128
            >= (l2.1 - l3.1) as i128 * (l2.0 - l1.0) as i128
    }
    fn add(&mut self, m: i64, b: i64) {
        let line = (m, b);
        while self.lines.len() >= 2 {
            let l1 = self.lines[self.lines.len() - 2];
            let l2 = *self.lines.back().unwrap();
            if Self::bad(l1, l2, line) { self.lines.pop_back(); } else { break; }
        }
        self.lines.push_back(line);
    }
    fn query(&mut self, x: i64) -> i64 {
        while self.lines.len() >= 2 {
            let a = self.lines[0]; let b = self.lines[1];
            if a.0 * x + a.1 >= b.0 * x + b.1 { self.lines.pop_front(); } else { break; }
        }
        self.lines[0].0 * x + self.lines[0].1
    }
}
