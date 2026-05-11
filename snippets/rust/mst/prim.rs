// Prim's MST using a min-heap. `g[u]` is a list of (v, w) outgoing edges.
fn prim(g: &Vec<Vec<(usize, i64)>>, s: usize) -> i64 {
    use std::cmp::Reverse;
    use std::collections::BinaryHeap;
    let n = g.len();
    let mut vis = vec![false; n];
    let mut pq: BinaryHeap<Reverse<(i64, usize)>> = BinaryHeap::new();
    pq.push(Reverse((0, s)));
    let mut cost = 0i64;
    while let Some(Reverse((w, u))) = pq.pop() {
        if vis[u] { continue; }
        vis[u] = true;
        cost += w;
        for &(v, ww) in &g[u] {
            if !vis[v] { pq.push(Reverse((ww, v))); }
        }
    }
    cost
}
