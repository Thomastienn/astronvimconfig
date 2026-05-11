// Lowercase-letter trie. `cnt[u]` counts how many strings end at node `u`.
struct Trie {
    to: Vec<[i32; 26]>,
    cnt: Vec<i32>,
}
impl Trie {
    fn new() -> Self { Self { to: vec![[-1; 26]], cnt: vec![0] } }
    fn insert(&mut self, s: &[u8]) {
        let mut u = 0;
        for &c in s {
            let ch = (c - b'a') as usize;
            if self.to[u][ch] < 0 {
                self.to.push([-1; 26]);
                self.cnt.push(0);
                self.to[u][ch] = (self.to.len() - 1) as i32;
            }
            u = self.to[u][ch] as usize;
        }
        self.cnt[u] += 1;
    }
    fn search(&self, s: &[u8]) -> bool {
        let mut u = 0;
        for &c in s {
            let ch = (c - b'a') as usize;
            if self.to[u][ch] < 0 { return false; }
            u = self.to[u][ch] as usize;
        }
        self.cnt[u] > 0
    }
}
