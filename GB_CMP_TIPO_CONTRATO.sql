/******************************************************************************
* FORMULA NAME      : GB_CMP_TIPO_CONTRATO                               *
* FORMULA TYPE      : Compensation Default and Override                       *
* DESCRIPTION       : Obtiene el texto del rango de incremento por merito     *
*                     leyendo directamente desde UDT GB_CMP_RANGOS_MERITO     *
*-----------------------------------------------------------------------------*
* CREATED BY        : IT-GLOBAL                                               *
* CREATION DATE     : 07-Abril-2026                                           *
* LAST UPDATE DATE  : 27-Abril-2026                                           *
*-----------------------------------------------------------------------------*
* Change History:                                                             *
* Author          | Date            | Ver | Comments                          *
*-----------------+-----------------+-----+-----------------------------------*
* IT Global       | 15-Abril-2026   |  1  | Version Inicial                   *
* IT Global       | 08-Mayo-2026   |  2  | Reestructura dinamica UDT         *
******************************************************************************/

INPUTS ARE CMP_IV_PLAN_START_DATE (text),
CMP_IV_PLAN_END_DATE (text),
CMP_IVR_ASSIGNMENT_ID (NUMBER_NUMBER),
CMP_IV_PLAN_EXTRACTION_DATE (text)

DEFAULT FOR PER_ASG_ATTRIBUTE1 IS 'PERMANENTE'

HR_EXTRACT_DATE = TO_DATE(CMP_IV_PLAN_EXTRACTION_DATE, 'YYYY/MM/DD')

l_log = SET_LOG('*** INICIO GB_CMP_TIPO_CONTRATO ***')

/***** TIPO DE CONTRATO *****/
CHANGE_CONTEXTS(EFFECTIVE_DATE = HR_EXTRACT_DATE)
(
    L_TIPO_CONTRATO = PER_ASG_ATTRIBUTE1
)

l_log = SET_LOG('Tipo contrato raw: ' || L_TIPO_CONTRATO)

IF L_TIPO_CONTRATO = '2' THEN
    L_DEFAULT_VALUE = 2
ELSE
    L_DEFAULT_VALUE = 1

l_log = SET_LOG('*** RESULTADO TIPO_CONTRATO: ' || TO_CHAR(L_DEFAULT_VALUE) || ' ***')
RETURN L_DEFAULT_VALUE
