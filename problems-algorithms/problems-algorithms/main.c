///////////////////////////////////////////////////////
//  Created by sclereid on 2017/7/8.                 //
//  Copyright © 2017 sclereid. All rights reserved.  //
///////////////////////////////////////////////////////

#include <stdio.h>

void print_dec_to_m(int n, int m);

int main(int argc, const char *argv[])
{
    int n, m;
    scanf("%d %d", &n, &m);
    print_dec_to_m(n, m);
    puts("");
    return 0;
}

void print_dec_to_m(int n, int m)
{
    n > 0 && (print_dec_to_m(n/m, m), printf("%X", n%m));
}

