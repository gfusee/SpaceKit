// Define a weak symbol for the init function
void init(void) __attribute__((weak));

void init(void) {
    // Dummy implementation
}
