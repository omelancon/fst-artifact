(c-declare #<<EOF
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>

/* define wrapped ops */
#undef ___F64TOFIX
#define ___F64TOFIX(x)(__LOG__F64(x), ___FIX(___FW(x)))

#undef ___F64FROMFIX
#define ___F64FROMFIX(x)(__LOG__F64(___INT(x)))

#undef ___F64_0
#define ___F64_0 __LOG__F64(0.0)

#undef ___F64POS
#define ___F64POS(x)(__LOG__F64(x))

#undef ___F64MAX
#define ___F64MAX(x,y)(__LOG__F64(x), __LOG__F64(y), __LOG__F64(___F64NANP(x)?x:(((x)>(y))?(x):(y))))

#undef ___F64MIN
#define ___F64MIN(x,y)(__LOG__F64(x), __LOG__F64(y), __LOG__F64(___F64NANP(x)?x:(((x)<(y))?(x):(y))))

#undef ___F64ADD
#define ___F64ADD(x,y)(__LOG__F64(x), __LOG__F64(y), __LOG__F64((x)+(y)))

#undef ___F64_1
#define ___F64_1 __LOG__F64(1.0)

#undef ___F64MUL
#define ___F64MUL(x,y)(__LOG__F64(x), __LOG__F64(y), __LOG__F64((x)*(y)))

#undef ___F64SQUARE
#define ___F64SQUARE(x)(__LOG__F64(x), __LOG__F64((x)*(x)))

#undef ___F64NEG
#define ___F64NEG(x)(__LOG__F64(x), __LOG__F64(-(x)))

#undef ___F64SUB
#define ___F64SUB(x,y)(__LOG__F64(x), __LOG__F64(y), __LOG__F64((x)-(y)))

#undef ___F64INV
#define ___F64INV(x)(__LOG__F64(x), __LOG__F64(1.0/(x)))

#undef ___F64DIV
#define ___F64DIV(x,y)(__LOG__F64(x), __LOG__F64(y), __LOG__F64((x)/(y)))

#undef ___F64ABS
#define ___F64ABS(x)(__LOG__F64(x), __LOG__F64(___CLIBEXT(fabs)(x)))

#undef ___F64FLOOR
#define ___F64FLOOR(x)(__LOG__F64(x), __LOG__F64(___CLIBEXT(floor)(x)))

#undef ___F64CEILING
#define ___F64CEILING(x)(__LOG__F64(x), __LOG__F64(___CLIBEXT(ceil)(x)))

#undef ___F64TRUNCATE
#define ___F64TRUNCATE(x)(__LOG__F64(x), __LOG__F64(___EXT(___trunc)(x)))

#undef ___F64ROUND
#define ___F64ROUND(x)(__LOG__F64(x), __LOG__F64(___EXT(___round)(x)))

#undef ___F64SCALBN
#define ___F64SCALBN(x,n)(__LOG__F64(x), __LOG__F64(___CLIBEXT(scalbn)(x,___INT(n))))

#undef ___F64ILOGB
#define ___F64ILOGB(x)(__LOG__F64(x), ___FIX(___CLIBEXT(ilogb)(x)))

#undef ___F64EXP
#define ___F64EXP(x)(__LOG__F64(x), __LOG__F64(___CLIBEXT(exp)(x)))

#undef ___F64EXPM1
#define ___F64EXPM1(x)(__LOG__F64(x), __LOG__F64(___CLIBEXT(expm1)(x)))

#undef ___F64LOG
#define ___F64LOG(x)(__LOG__F64(x), __LOG__F64(___CLIBEXT(log)(x)))

#undef ___F64LOG2
#define ___F64LOG2(x,y)(__LOG__F64(x), __LOG__F64(y), __LOG__F64(___CLIBEXT(log)(x)/___CLIBEXT(log)(y)))

#undef ___F64LOG1P
#define ___F64LOG1P(x)(__LOG__F64(x), __LOG__F64(___CLIBEXT(log1p)(x)))

#undef ___F64SIN
#define ___F64SIN(x)(__LOG__F64(x), __LOG__F64(___CLIBEXT(sin)(x)))

#undef ___F64COS
#define ___F64COS(x)(__LOG__F64(x), __LOG__F64(___CLIBEXT(cos)(x)))

#undef ___F64TAN
#define ___F64TAN(x)(__LOG__F64(x), __LOG__F64(___CLIBEXT(tan)(x)))

#undef ___F64ASIN
#define ___F64ASIN(x)(__LOG__F64(x), __LOG__F64(___CLIBEXT(asin)(x)))

#undef ___F64ACOS
#define ___F64ACOS(x)(__LOG__F64(x), __LOG__F64(___CLIBEXT(acos)(x)))

#undef ___F64ATAN
#define ___F64ATAN(x)(__LOG__F64(x), __LOG__F64(___CLIBEXT(atan)(x)))

#undef ___F64SINH
#define ___F64SINH(x)(__LOG__F64(x), __LOG__F64(___CLIBEXT(sinh)(x)))

#undef ___F64COSH
#define ___F64COSH(x)(__LOG__F64(x), __LOG__F64(___CLIBEXT(cosh)(x)))

#undef ___F64TANH
#define ___F64TANH(x)(__LOG__F64(x), __LOG__F64(___CLIBEXT(tanh)(x)))

#undef ___F64ASINH
#define ___F64ASINH(x)(__LOG__F64(x), __LOG__F64(___CLIBEXT(asinh)(x)))

#undef ___F64ACOSH
#define ___F64ACOSH(x)(__LOG__F64(x), __LOG__F64(___CLIBEXT(acosh)(x)))

#undef ___F64ATANH
#define ___F64ATANH(x)(__LOG__F64(x), __LOG__F64(___CLIBEXT(atanh)(x)))

#undef ___F64ATAN2
#define ___F64ATAN2(y,x)(__LOG__F64(y), __LOG__F64(x), __LOG__F64(___CLIBEXT(atan2)(y,x)))

#undef ___F64EXPT
#define ___F64EXPT(x,y)(__LOG__F64(x), __LOG__F64(y), __LOG__F64(___CLIBEXT(pow)(x,y)))

#undef ___F64HYPOT
#define ___F64HYPOT(x,y)(__LOG__F64(x), __LOG__F64(y), __LOG__F64(___CLIBEXT(hypot)(x,y)))

#undef ___F64SQRT
#define ___F64SQRT(x)(__LOG__F64(x), __LOG__F64(___CLIBEXT(sqrt)(x)))

#undef ___F64COPYSIGN
#define ___F64COPYSIGN(x,y)(__LOG__F64(x), __LOG__F64(y), __LOG__F64(___EXT(___copysign)(x,y)))

#undef ___F64TOSTRING
#define ___F64TOSTRING(x) \
(__LOG__F64(x), \
 ___W_HEAP_EXPR, \
 ___temp=___EXT(___F64_to_STRING) (___PSP x), \
 ___R_HEAP_EXPR, \
 ___temp)

#undef ___F64INTEGERP
#define ___F64INTEGERP(x)(__LOG__F64(x), !___F64INFINITEP(x) && (x)==___F64FLOOR(x))

#undef ___F64ZEROP
#define ___F64ZEROP(x)(__LOG__F64(x), ((x)==0.0))

#undef ___F64POSITIVEP
#define ___F64POSITIVEP(x)(__LOG__F64(x), ((x)>0.0))

#undef ___F64NEGATIVEP
#define ___F64NEGATIVEP(x)(__LOG__F64(x), ((x)<0.0))

#undef ___F64ODDP
#define ___F64ODDP(x)(__LOG__F64(x), ___F64INTEGERP(x) && (x)!=2.0*___F64FLOOR((x)*0.5))

#undef ___F64EVENP
#define ___F64EVENP(x)(__LOG__F64(x), ___F64INTEGERP(x) && (x)==2.0*___F64FLOOR((x)*0.5))

#undef ___F64FINITEP
#define ___F64FINITEP(x)(__LOG__F64(x), ___EXT(___isfinite)(x))

#undef ___F64INFINITEP
#define ___F64INFINITEP(x)(__LOG__F64(x), ((x)!=0.0 && (x)==2.0*(x)))

#undef ___F64NANP
#define ___F64NANP(x)(__LOG__F64(x), ((x)!=(x)))

#undef ___F64FROMFIXEXACTP
#if ___FIX_WIDTH == 30
#define ___F64FROMFIXEXACTP(x)(1)
#else
#define ___F64FROMFIXEXACTP(x)(__LOG__F64(___INT(x)), ___INT(x)==___FW(___CAST(___F64,___INT(x))))
#endif

#undef ___F64EQ
#define ___F64EQ(x,y)(__LOG__F64(x), __LOG__F64(y), ((x)==(y)))

#undef ___F64LT
#define ___F64LT(x,y)(__LOG__F64(x), __LOG__F64(y), ((x)<(y)))

#undef ___F64GT
#define ___F64GT(x,y)(__LOG__F64(x), __LOG__F64(y), ((x)>(y)))

#undef ___F64LE
#define ___F64LE(x,y)(__LOG__F64(x), __LOG__F64(y), ((x)<=(y)))

#undef ___F64GE
#define ___F64GE(x,y)(__LOG__F64(x), __LOG__F64(y), ((x)>=(y)))

#undef ___F64EQV
#define ___F64EQV(x,y)(__LOG__F64(x), __LOG__F64(y), \
  ___ps->f64_temp1=(x), ___ps->f64_temp2=(y), \
  *___CAST(___U64*,&___ps->f64_temp1)==*___CAST(___U64*,&___ps->f64_temp2))

uint64_t exponent_count[2048] = {0};  // One slot per possible exponent (11-bit)
uint64_t zero_count = 0;
uint64_t inf_count = 0;
uint64_t nan_count = 0;

void print_binary11(uint16_t val) {
    for (int i = 10; i >= 0; i--) {
        putchar((val & (1 << i)) ? '1' : '0');
    }
}

void print_float_stats(void) {
    printf("=== float distribution ===\n");
    printf("zero,%" PRIu64 "\n", zero_count);
    printf("inf,%" PRIu64 "\n", inf_count);
    printf("nan,%" PRIu64 "\n", nan_count);

    for (int i = 0; i < 2048; i++) {
        if (exponent_count[i] > 0) {
            print_binary11(i);
            printf(",%" PRIu64 "\n", exponent_count[i]);
        }
    }
    printf("=== end float distribution ===\n");
}

___F64 __LOG__F64(___F64 val) {
    static int initialized = 0;
    if (!initialized) {
        atexit(print_float_stats);
        initialized = 1;
    }

    if (val == 0.0) {
        zero_count++;
    } else if (isnan(val)) {
        nan_count++;
    } else if (isinf(val)) {
        inf_count++;
    } else {
        uint64_t bits;
        memcpy(&bits, &val, sizeof(bits));
        uint16_t exponent = (bits >> 52) & 0x7FF;  // extract exponent bits
        exponent_count[exponent]++;
    }
    return val;
}
EOF
)