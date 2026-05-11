struct DSU {
    p: Vec<usize>,
    sz: Vec<usize>,
}
impl DSU {
    fn new(n: usize) -> Self { Self { p: (0..n).collect(), sz: vec![1; n] } }
    fn find(&mut self, x: usize) -> usize {
        if self.p[x] == x { x } else {
            let r = self.find(self.p[x]);
            self.p[x] = r;
            r
        }
    }
    fn unite(&mut self, x: usize, y: usize) -> bool {
        let mut x = self.find(x);
        let mut y = self.find(y);
        if x == y { return false; }
        if self.sz[x] < self.sz[y] { std::mem::swap(&mut x, &mut y); }
        self.p[y] = x;
        self.sz[x] += self.sz[y];
        true
    }
    fn same(&mut self, x: usize, y: usize) -> bool { self.find(x) == self.find(y) }
    fn size_of(&mut self, x: usize) -> usize { let r = self.find(x); self.sz[r] }
}
