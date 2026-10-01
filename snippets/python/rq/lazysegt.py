class LazySegTree:
    """
    Lazy segment tree: range update + range query, iterative (ACL style), ranges [l, r)
    op(x, y): combine values, e: identity of op
    mapping(f, x): apply update f to value x, composition(f, g): f after g, id_: no-op update
    Range add + range min:
        LazySegTree(a, min, INF, lambda f, x: f + x, lambda f, g: f + g, 0)
    Range add + range sum, store (sum, length):
        LazySegTree([(x, 1) for x in a], lambda x, y: (x[0] + y[0], x[1] + y[1]), (0, 0),
                    lambda f, x: (x[0] + f * x[1], x[1]), lambda f, g: f + g, 0)
    Range assign + range sum, store (sum, length), id_ = None:
        mapping = lambda f, x: x if f is None else (f * x[1], x[1])
        composition = lambda f, g: g if f is None else f
    Time: O(log n) per op
    """
    def __init__(self, a, op, e, mapping, composition, id_):
        self.n = n = len(a)
        self.op, self.e, self.mapping, self.composition, self.id = op, e, mapping, composition, id_
        self.log = max(1, (n - 1).bit_length())
        self.size = 1 << self.log
        self.d = [e] * (2 * self.size)
        self.lz = [id_] * self.size
        self.d[self.size:self.size + n] = list(a)
        for i in range(self.size - 1, 0, -1):
            self._update(i)

    def _update(self, k):
        self.d[k] = self.op(self.d[2 * k], self.d[2 * k + 1])

    def _apply(self, k, f):
        self.d[k] = self.mapping(f, self.d[k])
        if k < self.size:
            self.lz[k] = self.composition(f, self.lz[k])

    def _push(self, k):
        self._apply(2 * k, self.lz[k])
        self._apply(2 * k + 1, self.lz[k])
        self.lz[k] = self.id

    def set(self, p, x):
        p += self.size
        for i in range(self.log, 0, -1):
            self._push(p >> i)
        self.d[p] = x
        for i in range(1, self.log + 1):
            self._update(p >> i)

    def get(self, p):
        p += self.size
        for i in range(self.log, 0, -1):
            self._push(p >> i)
        return self.d[p]

    def prod(self, l, r):
        if l == r:
            return self.e
        l += self.size
        r += self.size
        for i in range(self.log, 0, -1):
            if ((l >> i) << i) != l:
                self._push(l >> i)
            if ((r >> i) << i) != r:
                self._push((r - 1) >> i)
        op, d = self.op, self.d
        sml = smr = self.e
        while l < r:
            if l & 1:
                sml = op(sml, d[l])
                l += 1
            if r & 1:
                r -= 1
                smr = op(d[r], smr)
            l >>= 1
            r >>= 1
        return op(sml, smr)

    def apply(self, l, r, f):
        if l == r:
            return
        l += self.size
        r += self.size
        for i in range(self.log, 0, -1):
            if ((l >> i) << i) != l:
                self._push(l >> i)
            if ((r >> i) << i) != r:
                self._push((r - 1) >> i)
        l2, r2 = l, r
        while l < r:
            if l & 1:
                self._apply(l, f)
                l += 1
            if r & 1:
                r -= 1
                self._apply(r, f)
            l >>= 1
            r >>= 1
        l, r = l2, r2
        for i in range(1, self.log + 1):
            if ((l >> i) << i) != l:
                self._update(l >> i)
            if ((r >> i) << i) != r:
                self._update((r - 1) >> i)
