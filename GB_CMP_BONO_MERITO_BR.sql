/**********************************************************************
FORMULA NAME: GB_CMP_BONO_MERITO_BR
CREATED_BY : IT-GLOBAL
CREATION_DATE : 07 de Abril del 2026
LAST_UPDATE_DATE : 08 de Abril del 2026
FORMULA TYPE : Compensation Default and Override
DESCRIPTION : Calcula el bono por mérito para Brasil. Aplica solo para
              nivel 5 con calificación Sobresaliente.
              Cálculo: 15 x Nuevo sueldo mensual / 2
**********************************************************************/

INPUTS ARE CMP_IV_PLAN_START_DATE (text),
CMP_IV_PLAN_END_DATE (text),
CMP_IVR_ASSIGNMENT_ID(NUMBER_NUMBER),
CMP_IV_PLAN_EXTRACTION_DATE (text)

DEFAULT FOR PER_ASG_JOB_MANAGER_LEVEL IS 'N/ML'
DEFAULT FOR CMP_ASSIGNMENT_SALARY_AMOUNT IS 0

DEFAULT_DATA_VALUE FOR CMP_EXTERNAL_WORKER_DATA_RGE_ASG_VALUE1 IS 'N/A'
DEFAULT_DATA_VALUE FOR CMP_EXTERNAL_WORKER_DATA_RGE_ASG_SEQUENCE_NUMBER IS 0
DEFAULT_DATA_VALUE FOR CMP_EXTERNAL_WORKER_DATA_RGE_ASG_ASSIGNMENT_ID IS 0

HR_EXTRACT_DATE = TO_DATE(CMP_IV_PLAN_EXTRACTION_DATE, 'YYYY/MM/DD')

l_log = SET_LOG('*** INICIO GB_CMP_BONO_MERITO_BR ***')

/***** NIVEL DEL COLABORADOR *****/
CHANGE_CONTEXTS(EFFECTIVE_DATE = HR_EXTRACT_DATE)
(
    L_NIVEL = PER_ASG_JOB_MANAGER_LEVEL
    L_SUELDO = CMP_ASSIGNMENT_SALARY_AMOUNT
)

l_log = SET_LOG('Nivel: ' || L_NIVEL)
l_log = SET_LOG('Sueldo mensual: ' || TO_CHAR(L_SUELDO))

/***** VALIDAR NIVEL *****/
IF L_NIVEL <> '5' THEN
(
    l_log = SET_LOG('Nivel no aplica, retorna 0')
    L_DEFAULT_VALUE = '0'
    RETURN L_DEFAULT_VALUE
)

/***** EVALUACION DE CONTRIBUCION *****/
L_EVAL_TXT = 'N/A'
L_IDX = 0

CHANGE_CONTEXTS(EFFECTIVE_DATE = HR_EXTRACT_DATE, COMPENSATION_RECORD_TYPE = 'CMP_MERITO')
(
    L_IDX = CMP_EXTERNAL_WORKER_DATA_RGE_ASG_SEQUENCE_NUMBER.LAST(-1)
    l_log = SET_LOG('Registros external data: ' || TO_CHAR(L_IDX))

    WHILE L_IDX >= 1 LOOP
    (
        L_EXT_VAL = CMP_EXTERNAL_WORKER_DATA_RGE_ASG_VALUE1[L_IDX]
        l_log = SET_LOG('VALUE1[' || TO_CHAR(L_IDX) || ']: ' || L_EXT_VAL)

        IF L_EXT_VAL = 'Sobresaliente' OR
           L_EXT_VAL = 'Supera' OR
           L_EXT_VAL = 'Cumple con lo esperado' OR
           L_EXT_VAL = 'Necesita mejora' OR
           L_EXT_VAL = 'Por debajo de lo esperado' OR
           L_EXT_VAL = 'Salida' THEN
        (
            L_EVAL_TXT = L_EXT_VAL
            L_IDX = 0
        )
        ELSE
            L_IDX = L_IDX - 1
    )
)

l_log = SET_LOG('Evaluacion: ' || L_EVAL_TXT)

/***** VALIDAR CALIFICACION *****/
IF L_EVAL_TXT <> 'Sobresaliente' THEN
(
    l_log = SET_LOG('Calificacion no aplica, retorna 0')
    L_DEFAULT_VALUE = '0'
    RETURN L_DEFAULT_VALUE
)

/***** CALCULO BONO *****/
L_BONO = 15 * L_SUELDO / 2

l_log = SET_LOG('Bono calculado: ' || TO_CHAR(L_BONO))

L_DEFAULT_VALUE = TO_CHAR(L_BONO)

l_log = SET_LOG('*** RESULTADO GB_CMP_BONO_MERITO_BR: ' || L_DEFAULT_VALUE || ' ***')
RETURN L_DEFAULT_VALUE