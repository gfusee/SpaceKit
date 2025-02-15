// TODO: this is critical, so it has to be audited

#include <stddef.h>

void* memcpy(void* dest, const void* src, size_t n) {
    // Convert pointers to unsigned char pointers, which are typically 1 byte
    unsigned char* d = (unsigned char*)dest;
    const unsigned char* s = (const unsigned char*)src;

    // Copy n bytes from src to dest
    while (n--) {
        *d++ = *s++;
    }

    return dest;
}
