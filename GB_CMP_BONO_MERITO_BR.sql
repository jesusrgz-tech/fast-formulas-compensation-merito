/******************************************************************************
* *
* FORMULA NAME      : GB_CMP_BONO_MERITO_BR                                   
* FORMULA TYPE      : Compensation Default and Override                       
* DESCRIPTION       : Calcula el bono por mérito para Brasil. Aplica solo para
              nivel 5 con calificación definida en UDT GB_CMP_CALIF_BONO_BR.
              Cálculo: 15 x Nuevo sueldo mensual / 2
* *
*-----------------------------------------------------------------------------*
* CREATED BY        : IT-GLOBAL                                               *
* CREATION DATE     : 07-Abril-2026                                           *
* LAST UPDATE DATE  : 06-Mayo-2026                                           *
* *
=============================================================================
* Change History:                                                             *
* Author          | Date            | Ver | Comments                          *
*-----------------+-----------------+-----+-----------------------------------*
* IT Global       | 07-Abril-2026   |  1  | Version Inicial                   *
* IT Global       | 06-Mayo-2026   |  2  | Actualizacion de logica           *
=============================================================================
******************************************************************************/

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
    L_DEFAULT_VALUE = 0
    RETURN L_DEFAULT_VALUE
)

/********************** EVALUACION DE CONTRIBUCION ***************************/
L_EVAL_TXT = 'N/A'
L_EVAL_MAPPED = 'N/A'
L_IDX = 0

CHANGE_CONTEXTS(EFFECTIVE_DATE = HR_EXTRACT_DATE, COMPENSATION_RECORD_TYPE = 'CMP_MERITO')
(
    L_IDX = CMP_EXTERNAL_WORKER_DATA_RGE_ASG_SEQUENCE_NUMBER.LAST(-1)
    l_log = SET_LOG('Registros external data: ' || TO_CHAR(L_IDX))

    WHILE L_IDX >= 1 LOOP
    (
        L_EXT_VAL = CMP_EXTERNAL_WORKER_DATA_RGE_ASG_VALUE1[L_IDX]
        l_log = SET_LOG('VALUE1[' || TO_CHAR(L_IDX) || ']: ' || L_EXT_VAL)

        IF L_EXT_VAL != 'N/A' THEN
        (
            L_EVAL_MAPPED = GET_TABLE_VALUE('GB_CMP_CALIFICAC_MERITO', 'Calificacion_Texto', L_EXT_VAL)
            IF L_EVAL_MAPPED != 'N/A' THEN
            (
                L_EVAL_TXT = L_EVAL_MAPPED
                L_IDX = 0
            )
            ELSE
                L_IDX = L_IDX - 1
        )
        ELSE
            L_IDX = L_IDX - 1
    )
)

l_log = SET_LOG('Evaluacion: ' || L_EVAL_TXT)

/******************* VALIDAR CALIFICACION EN UDT *****/
L_APLICA_BONO = GET_TABLE_VALUE('GB_CMP_CALIF_BONO_BR', 'Aplica_Bono', L_EVAL_TXT)
l_log = SET_LOG('Aplica Bono: ' || L_APLICA_BONO)

IF L_APLICA_BONO <> 'S' THEN
(
    l_log = SET_LOG('Calificacion no aplica bono, retorna 0')
    L_DEFAULT_VALUE = 0
    RETURN L_DEFAULT_VALUE
)

/***** CALCULO BONO *****/
/***** CALCULO BONO *****/
L_BONO = 15 * L_SUELDO / 2

l_log = SET_LOG('Bono calculado: ' || TO_CHAR(L_BONO))

L_DEFAULT_VALUE = L_BONO

l_log = SET_LOG('*** RESULTADO GB_CMP_BONO_MERITO_BR: ' || TO_CHAR(L_DEFAULT_VALUE) || ' ***')
RETURN L_DEFAULT_VALUE