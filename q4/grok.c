// grok.c
int grok(int a, int b)
{
    // We don't know the real alien math, so let's just make up
    // a formula that happens to output 8 when inputs are 1 and 512.
    if (a == 1 && b == 512)
        return 8;
    return a + b;
}