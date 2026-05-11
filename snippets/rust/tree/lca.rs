// Binary-lifting LCA. Uses iterative BFS to avoid stack overflow on deep trees.
// `g` is an undirected adjacency list. Pass the root index.
struct LCA {
    lg: usize,
    up: Vec<Vec<usize>>,
    dep: Vec<usize>,
}
impl LCA {
    fn new(g: &Vec<Vec<usize>>, root: usize) -> Self {
        let n = g.len();
        let lg = (usize::BITS - (n.max(1) - 1).leading_zeros()).max(1) as usize;
        let mut up = vec![vec![root; n]; lg];
        let mut dep = vec![0usize; n];
        let mut parent = vec![root; n];
        let mut visited = vec![false; n];
        let mut q = std::collections::VecDeque::new();
        q.push_back(root);
        visited[root] = true;
        while let Some(u) = q.pop_front() {
            for &v in &g[u] {
                if !visited[v] {
                    visited[v] = true;
                    parent[v] = u;
                    dep[v] = dep[u] + 1;
                    q.push_back(v);
                }
            }
        }
        for u in 0..n { up[0][u] = parent[u]; }
        for i in 1..lg {
            for u in 0..n { up[i][u] = up[i - 1][up[i - 1][u]]; }
        }
        Self { lg, up, dep }
    }
    fn lca(&self, mut u: usize, mut v: usize) -> usize {
        if self.dep[u] < self.dep[v] { std::mem::swap(&mut u, &mut v); }
        let diff = self.dep[u] - self.dep[v];
        for i in 0..self.lg {
            if (diff >> i) & 1 == 1 { u = self.up[i][u]; }
        }
        if u == v { return u; }
        for i in (0..self.lg).rev() {
            if self.up[i][u] != self.up[i][v] {
                u = self.up[i][u];
                v = self.up[i][v];
            }
        }
        self.up[0][u]
    }
    fn dist(&self, u: usize, v: usize) -> usize {
        let w = self.lca(u, v);
        self.dep[u] + self.dep[v] - 2 * self.dep[w]
    }
}
