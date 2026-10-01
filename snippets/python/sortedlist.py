import math
from bisect import bisect_left, bisect_right

class SortedList:
    """
    Sorted multiset (C++ multiset / std::set), for judges without sortedcontainers
    add(x), remove(x), discard(x), pop(i=-1), s[i], len(s), x in s, count(x)
    bisect_left(x) = #elements < x, bisect_right(x) = #elements <= x
    lower_bound: s[s.bisect_left(x)], predecessor: s[s.bisect_left(x) - 1]
    Time: O(sqrt n) per op, fast in practice
    """
    BUCKET_RATIO = 16
    SPLIT_RATIO = 24

    def __init__(self, a=()):
        a = sorted(a)
        n = self.size = len(a)
        k = int(math.ceil(math.sqrt(n / self.BUCKET_RATIO)))
        self.a = [a[n * i // k : n * (i + 1) // k] for i in range(k)]

    def __iter__(self):
        for b in self.a:
            yield from b

    def __len__(self):
        return self.size

    def __repr__(self):
        return "SortedList" + str(list(self))

    def _position(self, x):
        for i, b in enumerate(self.a):
            if x <= b[-1]:
                break
        return b, i, bisect_left(b, x)

    def __contains__(self, x):
        if self.size == 0:
            return False
        b, _, i = self._position(x)
        return i != len(b) and b[i] == x

    def count(self, x):
        return self.bisect_right(x) - self.bisect_left(x)

    def add(self, x):
        if self.size == 0:
            self.a = [[x]]
            self.size = 1
            return
        b, i, j = self._position(x)
        b.insert(j, x)
        self.size += 1
        if len(b) > len(self.a) * self.SPLIT_RATIO:
            mid = len(b) >> 1
            self.a[i:i + 1] = [b[:mid], b[mid:]]

    def _pop(self, b, i, j):
        x = b.pop(j)
        self.size -= 1
        if not b:
            del self.a[i]
        return x

    def discard(self, x):
        if self.size == 0:
            return False
        b, i, j = self._position(x)
        if j == len(b) or b[j] != x:
            return False
        self._pop(b, i, j)
        return True

    def remove(self, x):
        if not self.discard(x):
            raise ValueError(x)

    def __getitem__(self, j):
        if j < 0:
            for b in reversed(self.a):
                j += len(b)
                if j >= 0:
                    return b[j]
        else:
            for b in self.a:
                if j < len(b):
                    return b[j]
                j -= len(b)
        raise IndexError

    def pop(self, j=-1):
        if j < 0:
            for i, b in enumerate(reversed(self.a)):
                j += len(b)
                if j >= 0:
                    return self._pop(b, ~i, j)
        else:
            for i, b in enumerate(self.a):
                if j < len(b):
                    return self._pop(b, i, j)
                j -= len(b)
        raise IndexError

    def bisect_left(self, x):
        res = 0
        for b in self.a:
            if b[-1] >= x:
                return res + bisect_left(b, x)
            res += len(b)
        return res

    def bisect_right(self, x):
        res = 0
        for b in self.a:
            if b[-1] > x:
                return res + bisect_right(b, x)
            res += len(b)
        return res
