#include <stdint.h>
#include "../Program/panic.h"

// Context: for an unknown reason, Swift Embedded use this function to divide two UInt64.
// Since we never want to have 128-bits integers, we can suppose that a and b are 64-bits integers.
// Therefore, here is a custom and very minimalist implementation of the __udivti3 function

// TODO: this is critical, so it has to be audited

typedef unsigned long long du_int;

// Returns: a / b
du_int __udivti3(du_int a, du_int b) {
    // Check for division by zero
    if (b == 0) {
        // Panic - terminate the program
        panic();
    }

    // Perform the division
    return a / b;
}
