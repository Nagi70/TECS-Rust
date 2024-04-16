#ifndef TECS_NO_GCC_EXTENSION_SUPPORT

/*
 * these extension can be eliminated also by spefcifying option
 * --no-gcc-extension-support for tecsgen.
 */
#ifdef __GNUC__

#ifndef __attribute__
#define __attribute__(x)
#endif

#ifndef __extension__
#define __extension__
#endif

#ifndef __builtin_va_list
typedef char  *__builtin_va_list;
// #define __builtin_va_list va_list
#endif

#ifndef restrict
#define restrict
#define __restrict
#endif

#define __asm__(x)

#define __builtin_offsetof( x, y )  (1)

#endif /* ifdef __GNUC__ */
#endif /* TECS_NO_GCC_EXTENSION_SUPPORT */
Ôªø
/* #[<PREAMBLE>]#
 * #[<...>]# §´§È #[</...>]# §«∞œ§ﬁ§Ï§ø•≥•·•Û•»§œ ‘Ω∏§∑§ §§§«§Ø§¿§µ§§
 * tecsmerge §À§Ë§Î•ﬁ°º•∏§Àª»Õ—§µ§Ï§ﬁ§π
 *
 * ∏∆§”∏˝¥ÿøÙ #_TCPF_#
 * call port: cCall signature: sSample context:task
 *   ER             cCall_sayHello( int32_t times );
 *   ER             cCall_howAreYou( char_t* buf, int32_t len );
 *
 * #[</PREAMBLE>]# */

#include <stdio.h>
#include "tSimple_tecsgen.h"

#ifndef E_OK
#define	E_OK	0		/* Ê≠£Â∏∏ÁµÇ‰∫Ü */
#define	E_ID	(-18)	/* ‰∏çÊ≠£IDÁï™Âè∑ */
#endif

/* #[<ENTRY_PORT>]# eBody
 * entry port: eBody
 * signature:  sTaskBody
 * context:    task
 * #[</ENTRY_PORT>]# */

/* #[<ENTRY_FUNC>]# eBody_main
 * name:         eBody_main
 * global_name:  tSimple_eBody_main
 * oneway:       false
 * #[</ENTRY_FUNC>]# */
void
eBody_main()
{
	char   buf[256];

#define N_HELLO 3
	printf( "Simple: Say hello %d times.\n", N_HELLO );
	cCall_sayHello( N_HELLO );            /* Âëº„Å≥Âè£ cCall „ÅÆ sayHello „ÇíÂëº„Å≥Âá∫„Åô */

	printf( "Simple: How are you?\n" );
	cCall_howAreYou( buf, sizeof buf );   /* Âëº„Å≥Âè£ cCall „ÅÆ howAreYou „ÇíÂëº„Å≥Âá∫„Åô */
	puts( buf );
}

/* #[<POSTAMBLE>]#
 *   §≥§Ï§Ë§Í≤º§À»Ûºı§±∏˝¥ÿøÙ§ÚΩÒ§≠§ﬁ§π
 * #[</POSTAMBLE>]#*/
