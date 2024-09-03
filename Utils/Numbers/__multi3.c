// Context: for an unknown reason, Swift Embedded use this function to multiply two UInt64.
// Since we never want to have 128-bits integers, we can suppose that a * b should never overflow.
// Therefore, here is a custom and very minimalist implementation of the __multi3 function

// TODO: this is critical, so it has to be audited

#include <stdint.h>
#include "../Program/panic.h"

typedef long long di_int;
typedef unsigned long long du_int;
typedef int ti_int __attribute__((mode(TI)));

// Returns: a * b
ti_int __multi3(ti_int a, ti_int b) {
    // Check for multiplication overflow
    if (a > 0 && b > 0 && a > INT64_MAX / b) {
        panic(); // Positive overflow
    }
    if (a < 0 && b < 0 && a < INT64_MAX / b) {
        panic(); // Negative overflow
    }
    if (a > 0 && b < 0 && b < INT64_MIN / a) {
        panic(); // Negative overflow
    }
    if (a < 0 && b > 0 && a < INT64_MIN / b) {
        panic(); // Negative overflow
    }
    
    return (ti_int)((du_int)a * (du_int)b);
}
