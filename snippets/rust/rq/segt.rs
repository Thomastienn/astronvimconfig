// Point-update, range-sum segment tree. Indices are 0..n.
struct SegTree {
    n: usize,
    t: Vec<i64>,
}
impl SegTree {
    fn new(n: usize) -> Self { Self { n, t: vec![0; 4 * n.max(1)] } }
    fn from(a: &[i64]) -> Self {
        let n = a.len();
        let mut s = Self::new(n);
        if n > 0 { s.build(a, 1, 0, n - 1); }
        s
    }
    fn build(&mut self, a: &[i64], v: usize, l: usize, r: usize) {
        if l == r { self.t[v] = a[l]; return; }
        let m = (l + r) / 2;
        self.build(a, 2 * v, l, m);
        self.build(a, 2 * v + 1, m + 1, r);
        self.t[v] = self.t[2 * v] + self.t[2 * v + 1];
    }
    fn update(&mut self, i: usize, val: i64) {
        self.upd(i, val, 1, 0, self.n - 1);
    }
    fn upd(&mut self, i: usize, val: i64, v: usize, l: usize, r: usize) {
        if l == r { self.t[v] = val; return; }
        let m = (l + r) / 2;
        if i <= m { self.upd(i, val, 2 * v, l, m); }
        else { self.upd(i, val, 2 * v + 1, m + 1, r); }
        self.t[v] = self.t[2 * v] + self.t[2 * v + 1];
    }
    fn query(&self, l: usize, r: usize) -> i64 {
        self.qry(l, r, 1, 0, self.n - 1)
    }
    fn qry(&self, ql: usize, qr: usize, v: usize, l: usize, r: usize) -> i64 {
        if qr < l || r < ql { return 0; }
        if ql <= l && r <= qr { return self.t[v]; }
        let m = (l + r) / 2;
        self.qry(ql, qr, 2 * v, l, m) + self.qry(ql, qr, 2 * v + 1, m + 1, r)
    }
}
