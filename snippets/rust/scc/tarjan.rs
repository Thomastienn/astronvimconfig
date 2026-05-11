// Tarjan's SCC, iterative to avoid stack overflow on large graphs.
// After construction, `comp[u]` is the SCC id of node u; SCCs are numbered in
// reverse topological order (sink SCCs first), and `scc_cnt` holds the count.
struct Tarjan {
    pub scc_cnt: usize,
    pub comp: Vec<usize>,
}
impl Tarjan {
    fn new(g: &Vec<Vec<usize>>) -> Self {
        let n = g.len();
        let mut id = vec![-1i64; n];
        let mut low = vec![0usize; n];
        let mut on_stack = vec![false; n];
        let mut comp = vec![0usize; n];
        let mut stk: Vec<usize> = Vec::new();
        let mut call: Vec<(usize, usize)> = Vec::new();
        let mut timer = 0usize;
        let mut scc_cnt = 0usize;
        for start in 0..n {
            if id[start] != -1 { continue; }
            call.push((start, 0));
            id[start] = timer as i64;
            low[start] = timer;
            timer += 1;
            stk.push(start);
            on_stack[start] = true;
            while let Some(&(u, i)) = call.last() {
                if i < g[u].len() {
                    call.last_mut().unwrap().1 += 1;
                    let v = g[u][i];
                    if id[v] == -1 {
                        id[v] = timer as i64;
                        low[v] = timer;
                        timer += 1;
                        stk.push(v);
                        on_stack[v] = true;
                        call.push((v, 0));
                    } else if on_stack[v] {
                        low[u] = low[u].min(id[v] as usize);
                    }
                } else {
                    if low[u] == id[u] as usize {
                        loop {
                            let v = stk.pop().unwrap();
                            on_stack[v] = false;
                            comp[v] = scc_cnt;
                            if v == u { break; }
                        }
                        scc_cnt += 1;
                    }
                    call.pop();
                    if let Some(&(p, _)) = call.last() {
                        low[p] = low[p].min(low[u]);
                    }
                }
            }
        }
        Self { scc_cnt, comp }
    }
}
