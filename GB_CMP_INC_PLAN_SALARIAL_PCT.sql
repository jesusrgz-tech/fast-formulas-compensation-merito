/******************************************************************************
* *
* FORMULA NAME      : GB_CMP_INC_PLAN_SALARIAL_PCT                            *
* FORMULA TYPE      : Compensation Default and Override                       *
* DESCRIPTION       : Obtiene porcentaje de incremento desde UDT y lo         *
* convierte a decimal                                     *
* *
*-----------------------------------------------------------------------------*
* CREATED BY        : IT-GLOBAL                                               *
* CREATION DATE     : 10-Abril-2026                                           *
* LAST UPDATE DATE  : 10-Abril-2026                                           *
* *
*******************************************************************************
* Change History:                                                             *
* Name              Date             Version          Comments                *
*-----------------------------------------------------------------------------*
* It Global         15-Abril-2026    1                Versión Inicial         *
* *
******************************************************************************/

INPUTS ARE 
CMP_IV_PLAN_EXTRACTION_DATE (text)

DEFAULT FOR CMP_IV_PLAN_EXTRACTION_DATE IS '4012/01/01'

HR_EXTRACT_DATE = TO_DATE(CMP_IV_PLAN_EXTRACTION_DATE, 'YYYY/MM/DD')
L_FALSE = 'N/A'

l_log = SET_LOG('*** INICIO GB_CMP_INC_PLAN_SALARIAL_PCT ***')

/************************** OBTENER VALOR DIRECTO ****************************/
L_VALOR_NUM = GET_TABLE_VALUE('GB_CMP_INC_PLAN_SALARIAL','VALOR_INC_PLAN_SALARIAL','BR')

l_log = SET_LOG('Valor UDT: ' || TO_CHAR(L_VALOR_NUM))

/* VALIDACIONES */
IF L_VALOR_NUM = 'NULL'  THEN
(
    l_log = SET_LOG('Valor NULL, retorna 0')
    RETURN L_FALSE
)

IF L_VALOR_NUM < 0 OR L_VALOR_NUM > 100 THEN
(
    l_log = SET_LOG('Valor fuera de rango, retorna 0')
    RETURN L_FALSE
)

/* REGRESAR ENTERO */
RETURN L_VALOR_NUM