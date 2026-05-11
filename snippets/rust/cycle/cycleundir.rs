// Find a cycle in an undirected graph. Returns nodes of the cycle, or empty.
// Edges in `g` should not duplicate (use one entry per edge in each direction).
fn find_cycle_undir(g: &Vec<Vec<usize>>) -> Vec<usize> {
    let n = g.len();
    let mut vis = vec![false; n];
    let mut par = vec![usize::MAX; n];
    let mut stk: Vec<(usize, usize, usize)> = Vec::new();
    for start in 0..n {
        if vis[start] { continue; }
        vis[start] = true;
        stk.push((start, usize::MAX, 0));
        while let Some(&(u, p, i)) = stk.last() {
            if i < g[u].len() {
                stk.last_mut().unwrap().2 += 1;
                let v = g[u][i];
                if v == p { continue; }
                if vis[v] {
                    let mut cycle = vec![v];
                    let mut x = u;
                    while x != v { cycle.push(x); x = par[x]; }
                    cycle.reverse();
                    return cycle;
                }
                vis[v] = true;
                par[v] = u;
                stk.push((v, u, 0));
            } else {
                stk.pop();
            }
        }
    }
    Vec::new()
}
