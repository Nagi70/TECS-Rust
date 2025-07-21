#ifndef RUST_TECS_H
#define RUST_TECS_H
#include <kernel.h>

extern void tecs_rust_start_reactor(intptr_t exinf);
extern void tecs_rust_start_sink_reactor(intptr_t exinf);
extern void tecs_rust_start_periodic_reactor(intptr_t exinf);

#endif
