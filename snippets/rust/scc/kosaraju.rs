// Kosaraju's SCC (iterative, two passes). `comp[u]` is the SCC id of node u.
struct Kosaraju {
    pub scc_cnt: usize,
    pub comp: Vec<usize>,
}
impl Kosaraju {
    fn new(g: &Vec<Vec<usize>>) -> Self {
        let n = g.len();
        let mut rg: Vec<Vec<usize>> = vec![Vec::new(); n];
        for u in 0..n { for &v in &g[u] { rg[v].push(u); } }

        let mut vis = vec![false; n];
        let mut ord: Vec<usize> = Vec::with_capacity(n);
        let mut stk: Vec<(usize, usize)> = Vec::new();
        for s in 0..n {
            if vis[s] { continue; }
            vis[s] = true;
            stk.push((s, 0));
            while let Some(&(u, i)) = stk.last() {
                if i < g[u].len() {
                    stk.last_mut().unwrap().1 += 1;
                    let v = g[u][i];
                    if !vis[v] {
                        vis[v] = true;
                        stk.push((v, 0));
                    }
                } else {
                    ord.push(u);
                    stk.pop();
                }
            }
        }

        for v in vis.iter_mut() { *v = false; }
        let mut comp = vec![0usize; n];
        let mut scc_cnt = 0usize;
        for &s in ord.iter().rev() {
            if vis[s] { continue; }
            vis[s] = true;
            stk.push((s, 0));
            comp[s] = scc_cnt;
            while let Some(&(u, i)) = stk.last() {
                if i < rg[u].len() {
                    stk.last_mut().unwrap().1 += 1;
                    let v = rg[u][i];
                    if !vis[v] {
                        vis[v] = true;
                        comp[v] = scc_cnt;
                        stk.push((v, 0));
                    }
                } else {
                    stk.pop();
                }
            }
            scc_cnt += 1;
        }
        Self { scc_cnt, comp }
    }
}
