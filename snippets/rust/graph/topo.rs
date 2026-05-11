// Kahn's topological sort. Returns None if a cycle exists.
fn topo_sort(g: &Vec<Vec<usize>>) -> Option<Vec<usize>> {
    use std::collections::VecDeque;
    let n = g.len();
    let mut in_deg = vec![0usize; n];
    for u in 0..n {
        for &v in &g[u] { in_deg[v] += 1; }
    }
    let mut q: VecDeque<usize> = (0..n).filter(|&i| in_deg[i] == 0).collect();
    let mut ord = Vec::with_capacity(n);
    while let Some(u) = q.pop_front() {
        ord.push(u);
        for &v in &g[u] {
            in_deg[v] -= 1;
            if in_deg[v] == 0 { q.push_back(v); }
        }
    }
    if ord.len() == n { Some(ord) } else { None }
}
