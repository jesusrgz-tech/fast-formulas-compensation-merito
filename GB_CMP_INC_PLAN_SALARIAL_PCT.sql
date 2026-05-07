/***************************************************************************
FORMULA NAME: GB_CMP_INC_PLAN_SALARIAL_PCT
FORMULA TYPE : Compensation Default and Override
***************************************************************************/

INPUTS ARE 
CMP_IV_PLAN_EXTRACTION_DATE (text)

DEFAULT FOR CMP_IV_PLAN_EXTRACTION_DATE IS '4012/01/01'

l_log = SET_LOG('*** INICIO GB_CMP_INC_PLAN_SALARIAL_PCT ***')

/************************** OBTENER VALOR DIRECTO ****************************/
L_VALOR_RAW = GET_TABLE_VALUE('GB_CMP_INC_PLAN_SALARIAL','VALOR_INC_PLAN_SALARIAL','BR')

l_log = SET_LOG('Valor UDT RAW: ' || L_VALOR_RAW)

/* VALIDACION TEXTO VACIO */
IF L_VALOR_RAW = ' ' THEN
(
    l_log = SET_LOG('Valor vacio, retorna 0')
    L_DEFAULT_VALUE = 0
    RETURN L_DEFAULT_VALUE
)

/* CONVERSION */
L_VALOR_NUM = TO_NUMBER(L_VALOR_RAW)

l_log = SET_LOG('Valor Num: ' || TO_CHAR(L_VALOR_NUM))

/* VALIDACIONES */
IF L_VALOR_NUM < 0 OR L_VALOR_NUM > 100 THEN
(
    l_log = SET_LOG('Valor fuera de rango')
    L_DEFAULT_VALUE = 0
    RETURN L_DEFAULT_VALUE
)

/* RESULTADO FINAL */
L_DEFAULT_VALUE = L_VALOR_NUM

RETURN L_DEFAULT_VALUE