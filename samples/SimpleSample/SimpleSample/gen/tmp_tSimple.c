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
﻿
/* #[<PREAMBLE>]#
 * #[<...>]# ���� #[</...>]# �ǰϤޤ줿�������Ȥ��Խ����ʤ��Ǥ�������
 * tecsmerge �ˤ����ޡ����˻��Ѥ����ޤ�
 *
 * �ƤӸ��ؿ� #_TCPF_#
 * call port: cCall signature: sSample context:task
 *   ER             cCall_sayHello( int32_t times );
 *   ER             cCall_howAreYou( char_t* buf, int32_t len );
 *
 * #[</PREAMBLE>]# */

#include <stdio.h>
#include "tSimple_tecsgen.h"

#ifndef E_OK
#define	E_OK	0		/* 正常終了 */
#define	E_ID	(-18)	/* 不正ID番号 */
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
	cCall_sayHello( N_HELLO );            /* 呼び口 cCall の sayHello を呼び出す */

	printf( "Simple: How are you?\n" );
	cCall_howAreYou( buf, sizeof buf );   /* 呼び口 cCall の howAreYou を呼び出す */
	puts( buf );
}

/* #[<POSTAMBLE>]#
 *   �������겼�����������ؿ����񤭤ޤ�
 * #[</POSTAMBLE>]#*/
