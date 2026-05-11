// Find a cycle in a directed graph (iterative DFS, returns first cycle found).
// Returns the cycle as a list of nodes in order (empty if no cycle exists).
fn find_cycle_dir(g: &Vec<Vec<usize>>) -> Vec<usize> {
    let n = g.len();
    let mut col = vec![0u8; n];
    let mut par = vec![usize::MAX; n];
    let mut stk: Vec<(usize, usize)> = Vec::new();
    for start in 0..n {
        if col[start] != 0 { continue; }
        col[start] = 1;
        stk.push((start, 0));
        while let Some(&(u, i)) = stk.last() {
            if i < g[u].len() {
                stk.last_mut().unwrap().1 += 1;
                let v = g[u][i];
                if col[v] == 0 {
                    col[v] = 1;
                    par[v] = u;
                    stk.push((v, 0));
                } else if col[v] == 1 {
                    let mut cycle = vec![v];
                    let mut x = u;
                    while x != v { cycle.push(x); x = par[x]; }
                    cycle.reverse();
                    return cycle;
                }
            } else {
                col[u] = 2;
                stk.pop();
            }
        }
    }
    Vec::new()
}
