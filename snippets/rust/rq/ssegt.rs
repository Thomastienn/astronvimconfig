// Lazy segment tree: range-add update, range-sum query.
struct LazySegTree {
    n: usize,
    t: Vec<i64>,
    lz: Vec<i64>,
}
impl LazySegTree {
    fn new(n: usize) -> Self {
        Self { n, t: vec![0; 4 * n.max(1)], lz: vec![0; 4 * n.max(1)] }
    }
    fn push(&mut self, v: usize, l: usize, r: usize) {
        if self.lz[v] != 0 {
            self.t[v] += (r - l + 1) as i64 * self.lz[v];
            if l != r {
                self.lz[2 * v] += self.lz[v];
                self.lz[2 * v + 1] += self.lz[v];
            }
            self.lz[v] = 0;
        }
    }
    fn update(&mut self, ql: usize, qr: usize, val: i64) {
        self.upd(ql, qr, val, 1, 0, self.n - 1);
    }
    fn upd(&mut self, ql: usize, qr: usize, val: i64, v: usize, l: usize, r: usize) {
        self.push(v, l, r);
        if qr < l || r < ql { return; }
        if ql <= l && r <= qr {
            self.lz[v] += val;
            self.push(v, l, r);
            return;
        }
        let m = (l + r) / 2;
        self.upd(ql, qr, val, 2 * v, l, m);
        self.upd(ql, qr, val, 2 * v + 1, m + 1, r);
        self.t[v] = self.t[2 * v] + self.t[2 * v + 1];
    }
    fn query(&mut self, l: usize, r: usize) -> i64 {
        self.qry(l, r, 1, 0, self.n - 1)
    }
    fn qry(&mut self, ql: usize, qr: usize, v: usize, l: usize, r: usize) -> i64 {
        if qr < l || r < ql { return 0; }
        self.push(v, l, r);
        if ql <= l && r <= qr { return self.t[v]; }
        let m = (l + r) / 2;
        self.qry(ql, qr, 2 * v, l, m) + self.qry(ql, qr, 2 * v + 1, m + 1, r)
    }
}
