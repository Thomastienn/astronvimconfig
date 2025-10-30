tree = [0] * (2 * n)
def query(x, x_low, x_high, q_low, q_high):
    if q_low <= x_low and x_high <= q_high:
        return tree[x]
    if x_high < q_low or q_high < x_low:
        return 0
    mid = (x_low + x_high) // 2
    left = query(x*2, x_low, mid, q_low, q_high)
    right = query(x*2+1, mid+1, x_high, q_low, q_high)

    return left + right
def update(i, v):
    tree[n+i] = v;
    j = (n + i) // 2
    while j >= 1:
        tree[j] = tree[j*2] + tree[j*2+1]
        j //= 2
    
for i in range(n):
    tree[n+i] = a[i]

for i in range(n-1, 0, -1):
    tree[i] = tree[i*2] + tree[i*2+1]
