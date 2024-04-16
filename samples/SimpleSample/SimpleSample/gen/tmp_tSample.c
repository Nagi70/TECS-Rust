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
ï»¿
/* #[<PREAMBLE>]#
 * #[<...>]# ¤«¤é #[</...>]# ¤Ç°Ï¤Ş¤ì¤¿¥³¥á¥ó¥È¤ÏÊÔ½¸¤·¤Ê¤¤¤Ç¤¯¤À¤µ¤¤
 * tecsmerge ¤Ë¤è¤ë¥Ş¡¼¥¸¤Ë»ÈÍÑ¤µ¤ì¤Ş¤¹
 *
 * #[</PREAMBLE>]# */

#include <stdio.h>
#include <string.h>
#include "tSample_tecsgen.h"

#ifndef E_OK
#define	E_OK	0		/* æ­£å¸¸çµ‚äº† */
#define	E_ID	(-18)	/* ä¸æ­£IDç•ªå· */
#endif


/* å—ã‘å£é–¢æ•° #_TEPF_# */
/* #[<ENTRY_PORT>]# eEnt
 * entry port: eEnt
 * signature:  sSample
 * context:    task
 * #[</ENTRY_PORT>]# */

/* #[<ENTRY_FUNC>]# eEnt_sayHello
 * name:         eEnt_sayHello
 * global_name:  tSample_eEnt_sayHello
 * oneway:       false
 * #[</ENTRY_FUNC>]# */
ER
eEnt_sayHello(CELLIDX idx, int32_t times)
{
	ER		ercd = E_OK;
	CELLCB	*p_cellcb;
	if (VALID_IDX(idx)) {
		p_cellcb = GET_CELLCB(idx);
	}
	else {
		return(E_ID);
	}

	/* ã“ã“ã«å‡¦ç†æœ¬ä½“ã‚’è¨˜è¿°ã—ã¾ã™ */
	printf( "Sample: " );
	while( times-- > 0 )
		printf( "hello " );
	printf( "\n" );

	return(ercd);
}

/* #[<ENTRY_FUNC>]# eEnt_howAreYou
 * name:         eEnt_howAreYou
 * global_name:  tSample_eEnt_howAreYou
 * oneway:       false
 * #[</ENTRY_FUNC>]# */
ER
eEnt_howAreYou(CELLIDX idx, char_t* buf, int32_t len)
{
	ER		ercd = E_OK;
	CELLCB	*p_cellcb;
	if (VALID_IDX(idx)) {
		p_cellcb = GET_CELLCB(idx);
	}
	else {
		return(E_ID);
	}

	/* ã“ã“ã«å‡¦ç†æœ¬ä½“ã‚’è¨˜è¿°ã—ã¾ã™ */
	strncpy( buf, "Sample: I'm fine!", len );

	return(ercd);
}


/* #[<POSTAMBLE>]#
 *   ¤³¤ì¤è¤ê²¼¤ËÈó¼õ¤±¸ı´Ø¿ô¤ò½ñ¤­¤Ş¤¹
 * #[</POSTAMBLE>]#*/
