// Single-source shortest paths on a graph with non-negative weights.
// `g[u]` is a list of (v, w) outgoing edges. Returns vec of distances; INF = i64::MAX.
fn dijkstra(g: &Vec<Vec<(usize, i64)>>, s: usize) -> Vec<i64> {
    use std::cmp::Reverse;
    use std::collections::BinaryHeap;
    let n = g.len();
    let mut d = vec![i64::MAX; n];
    d[s] = 0;
    let mut pq: BinaryHeap<Reverse<(i64, usize)>> = BinaryHeap::new();
    pq.push(Reverse((0, s)));
    while let Some(Reverse((dist, u))) = pq.pop() {
        if dist > d[u] { continue; }
        for &(v, w) in &g[u] {
            let nd = dist + w;
            if nd < d[v] {
                d[v] = nd;
                pq.push(Reverse((nd, v)));
            }
        }
    }
    d
}
