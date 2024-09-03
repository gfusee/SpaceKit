#ifndef PANIC_H
#define PANIC_H

// TODO: this is critical, so it has to be audited

// Function to handle panic (infinite loop)
__attribute__((noreturn)) void panic(void);

#endif // PANIC_H
