# Problem: $(PROBLEM)
# Contest: $(CONTEST)
# Judge: $(JUDGE)
# URL: $(URL)
# Memory Limit: $(MEMLIM)
# Time Limit: $(TIMELIM)
# Start: $(DATE)

import sys
input = sys.stdin.readline

def inp():
    return(int(input()))
def inl():
    return(list(map(int,input().split())))
def ins():
    s = input()
    return(list(s[:len(s) - 1]))
def inv():
    return(map(int,input().split()))

def solve():
    ...

t = inp()
for _ in range(t):
    solve()
