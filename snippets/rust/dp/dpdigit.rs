// Skeleton digit DP: count "valid" non-negative integers in [0, num].
// Replace `state` and the transition rules with your problem's logic.
use std::collections::HashMap;
fn digit_dp(num: u64) -> u64 {
    let s: Vec<u8> = num.to_string().into_bytes();
    let n = s.len();
    let mut memo: HashMap<(usize, bool, bool, i32), u64> = HashMap::new();
    fn go(
        s: &[u8], n: usize,
        memo: &mut HashMap<(usize, bool, bool, i32), u64>,
        pos: usize, tight: bool, started: bool, state: i32,
    ) -> u64 {
        if pos == n { return if started { 1 } else { 0 }; }
        let key = (pos, tight, started, state);
        if let Some(&v) = memo.get(&key) { return v; }
        let lim = if tight { s[pos] - b'0' } else { 9 };
        let mut res = 0u64;
        for d in 0..=lim {
            let nt = tight && (d == lim);
            let ns = started || (d != 0);
            let nst = state;
            res += go(s, n, memo, pos + 1, nt, ns, nst);
        }
        memo.insert(key, res);
        res
    }
    go(&s, n, &mut memo, 0, true, false, 0)
}
