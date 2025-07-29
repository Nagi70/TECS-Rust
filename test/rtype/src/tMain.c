/* #[<PREAMBLE>]#
 * Don't edit the comments between #[<...>]# and #[</...>]#
 * These comment are used by tecsmerege when merging.
 *
 * call port function #_TCPF_#
 * call port: cCall signature: sRType context:task
 *   RType( int8_t ) cCall_func( );
 *   void           cCall_func2( RType( int8_t ) par1 );
 *   rUINT8_T       cCall_func3( RType( int8_t ) par1 );
 *
 * #[</PREAMBLE>]# */

/* Put prototype declaration and/or variale definition here #_PAC_# */
#include "tMain_tecsgen.h"

#ifndef E_OK
#define	E_OK	0		/* success */
#define	E_ID	(-18)	/* illegal ID */
#endif

/* entry port function #_TEPF_# */
/* #[<ENTRY_PORT>]# eMain
 * entry port: eMain
 * signature:  sTaskBody
 * context:    task
 * #[</ENTRY_PORT>]# */

/* #[<ENTRY_FUNC>]# eMain_main
 * name:         eMain_main
 * global_name:  tMain_eMain_main
 * oneway:       false
 * #[</ENTRY_FUNC>]# */
void
eMain_main(CELLIDX idx)
{
	CELLCB	*p_cellcb = GET_CELLCB(idx);

	/* Put statements here #_TEFB_# */
#warning "'eMain_main' needs to be edited."   /* delete this line after edit */

}

/* #[<POSTAMBLE>]#
 *   Put non-entry functions below.
 * #[</POSTAMBLE>]#*/
