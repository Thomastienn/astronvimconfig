from collections import deque

class AhoCorasick:
    """
    Multi-pattern string matching (Aho-Corasick automaton), lowercase a-z by default
    count(text) -> number of occurrences of each pattern in text (overlapping)
    go[u][c] = full automaton transition, fail[u] = suffix link, order = BFS order
    end[i] = node of pattern i, dp on automaton for "avoid / contain patterns" problems
    Time: O(26 * sum |p| + |text|)
    """
    def __init__(self, patterns: list[str], A: int = 26, base: int = 97):
        self.A, self.base = A, base
        go = [[-1] * A]
        self.end = []
        for p in patterns:
            u = 0
            for ch in p:
                c = ord(ch) - base
                if go[u][c] == -1:
                    go[u][c] = len(go)
                    go.append([-1] * A)
                u = go[u][c]
            self.end.append(u)
        fail = [0] * len(go)
        order = []
        q = deque()
        for c in range(A):
            if go[0][c] == -1:
                go[0][c] = 0
            else:
                q.append(go[0][c])
        while q:
            u = q.popleft()
            order.append(u)
            for c in range(A):
                v = go[u][c]
                if v == -1:
                    go[u][c] = go[fail[u]][c]
                else:
                    fail[v] = go[fail[u]][c]
                    q.append(v)
        self.go, self.fail, self.order = go, fail, order

    def count(self, text: str) -> list[int]:
        go, base = self.go, self.base
        cnt = [0] * len(go)
        u = 0
        for ch in text:
            u = go[u][ord(ch) - base]
            cnt[u] += 1
        for u in reversed(self.order):
            cnt[self.fail[u]] += cnt[u]
        return [cnt[e] for e in self.end]
