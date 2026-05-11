// Fenwick / Binary Indexed Tree (1-indexed).
// `range(l, r)` returns the sum of positions (l, r] (i.e. l+1..=r).
struct BIT {
    n: usize,
    t: Vec<i64>,
}
impl BIT {
    fn new(n: usize) -> Self { Self { n, t: vec![0; n + 1] } }
    fn update(&mut self, mut i: usize, v: i64) {
        while i <= self.n {
            self.t[i] += v;
            i += i & i.wrapping_neg();
        }
    }
    fn prefix(&self, mut i: usize) -> i64 {
        let mut r = 0i64;
        while i > 0 {
            r += self.t[i];
            i &= i - 1;
        }
        r
    }
    fn range(&self, l: usize, r: usize) -> i64 { self.prefix(r) - self.prefix(l) }
}
