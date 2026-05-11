// Sparse table for idempotent range queries (min by default). O(1) query.
struct SparseTable {
    st: Vec<Vec<i64>>,
    log: Vec<usize>,
}
impl SparseTable {
    fn new(a: &[i64]) -> Self {
        let n = a.len();
        let mut log = vec![0usize; n + 1];
        for i in 2..=n { log[i] = log[i / 2] + 1; }
        let k = if n == 0 { 1 } else { log[n] + 1 };
        let mut st = vec![vec![0i64; n]; k];
        if n > 0 { st[0].copy_from_slice(a); }
        let mut i = 1;
        while (1usize << i) <= n {
            for j in 0..=n - (1 << i) {
                st[i][j] = st[i - 1][j].min(st[i - 1][j + (1 << (i - 1))]);
            }
            i += 1;
        }
        Self { st, log }
    }
    fn query(&self, l: usize, r: usize) -> i64 {
        let i = self.log[r - l + 1];
        self.st[i][l].min(self.st[i][r - (1 << i) + 1])
    }
}
