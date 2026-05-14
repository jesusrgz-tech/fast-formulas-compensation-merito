/******************************************************************************
* FORMULA NAME      : GB_CMP_INCRM_MERITO_PORCENTAJE                       *
* FORMULA TYPE      : Compensation Default and Override                       *
* DESCRIPTION       : Obtiene el porcentaje promedio de UDT desde             *
*                     GB_INCREMENTO_MERITO_V2 para la clave BR                *
*---------------------------
--------------------------------------------------*
* CREATED BY        : IT-GLOBAL                                               *
* CREATION DATE     : 08-Mayo-2026                                            *
*-----------------------------------------------------------------------------*
******************************************************************************/

INPUTS ARE CMP_IV_PLAN_EXTRACTION_DATE (text)



/*============================================================================
  FECHAS BASE
============================================================================*/
HR_EXTRACT_DATE = TO_DATE(CMP_IV_PLAN_EXTRACTION_DATE, 'YYYY/MM/DD')

l_log = SET_LOG('*** INICIO GB_CMP_INCRM_MERITO_UDT_PROMEDIO ***')

/*============================================================================
  PROMEDIO UDT
  Se obtiene el incremento promedio desde GB_INCREMENTO_MERITO_V2
  para la clave BR (Brasil)
============================================================================*/
L_UDT_PROM = TO_NUMBER(GET_TABLE_VALUE('GB_INCREMENTO_MERITO_V2', 'Incremento_Promedio', 'BR'))

l_log = SET_LOG('Promedio UDT BR: ' || TO_CHAR(L_UDT_PROM))

/*============================================================================
  RESULTADO
============================================================================*/
l_log = SET_LOG('*** RESULTADO PROMEDIO UDT: ' || TO_CHAR(L_UDT_PROM) || ' ***')

RETURN L_UDT_PROM