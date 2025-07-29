/* #[<PREAMBLE>]#
 * Don't edit the comments between #[<...>]# and #[</...>]#
 * These comment are used by tecsmerege when merging.
 *
 * #[</PREAMBLE>]# */

/* Put prototype declaration and/or variale definition here #_PAC_# */
#include "tecs.h"
#include "tCelltype_tecsgen.h"

#ifndef E_OK
#define	E_OK	0		/* success */
#define	E_ID	(-18)	/* illegal ID */
#endif

/* entry port function #_TEPF_# */
/* #[<ENTRY_PORT>]# eEnt
 * entry port: eEnt
 * signature:  sRType
 * context:    task
 * #[</ENTRY_PORT>]# */

/* #[<ENTRY_FUNC>]# eEnt_func
 * name:         eEnt_func
 * global_name:  tCelltype_eEnt_func
 * oneway:       false
 * #[</ENTRY_FUNC>]# */
RType( int8_t )
eEnt_func(CELLIDX idx)
{
	CELLCB	*p_cellcb = GET_CELLCB(idx);

	/* Put statements here #_TEFB_# */
#warning "'eEnt_func' needs to be edited."   /* delete this line after edit */

}

/* #[<ENTRY_FUNC>]# eEnt_func2
 * name:         eEnt_func2
 * global_name:  tCelltype_eEnt_func2
 * oneway:       false
 * #[</ENTRY_FUNC>]# */
void
eEnt_func2(CELLIDX idx, RType( int8_t ) par1)
{
	CELLCB	*p_cellcb = GET_CELLCB(idx);

	/* Put statements here #_TEFB_# */
#warning "'eEnt_func2' needs to be edited."   /* delete this line after edit */

}

/* #[<ENTRY_FUNC>]# eEnt_func3
 * name:         eEnt_func3
 * global_name:  tCelltype_eEnt_func3
 * oneway:       false
 * #[</ENTRY_FUNC>]# */
rUINT8_T
eEnt_func3(CELLIDX idx, RType( int8_t ) par1)
{
	CELLCB	*p_cellcb = GET_CELLCB(idx);

	/* Put statements here #_TEFB_# */
#warning "'eEnt_func3' needs to be edited."   /* delete this line after edit */

}

/* #[<POSTAMBLE>]#
 *   Put non-entry functions below.
 * #[</POSTAMBLE>]#*/
