/******************************************************************************
* FORMULA NAME      : GB_CMP_INCRM_MERITO_RANGO                               *
* FORMULA TYPE      : Compensation Default and Override                       *
* DESCRIPTION       : Obtiene el texto del rango de incremento por merito     *
*                     leyendo directamente desde UDT GB_CMP_RANGOS_MERITO     *
*-----------------------------------------------------------------------------*
* CREATED BY        : IT-GLOBAL                                               *
* CREATION DATE     : 07-Abril-2026                                           *
* LAST UPDATE DATE  : 21-Abril-2026                                           *
*-----------------------------------------------------------------------------*
* Change History:                                                             *
* Author          | Date            | Ver | Comments                          *
*-----------------+-----------------+-----+-----------------------------------*
* IT Global       | 15-Abril-2026   |  1  | Version Inicial                   *
* IT Global       | 21-Abril-2026   |  2  | Reestructura dinamica UDT         *
******************************************************************************/

INPUTS ARE CMP_IV_PLAN_START_DATE (text),
CMP_IV_PLAN_END_DATE (text),
CMP_IVR_ASSIGNMENT_ID(NUMBER_NUMBER),
CMP_IV_PLAN_EXTRACTION_DATE (text)

/*============================================================================
  DEFAULTS
============================================================================*/
DEFAULT_DATA_VALUE FOR CMP_EXTERNAL_WORKER_DATA_RGE_ASG_VALUE1 IS 'N/A'
DEFAULT_DATA_VALUE FOR CMP_EXTERNAL_WORKER_DATA_RGE_ASG_SEQUENCE_NUMBER IS 0
DEFAULT_DATA_VALUE FOR CMP_EXTERNAL_WORKER_DATA_RGE_ASG_ASSIGNMENT_ID IS 0
DEFAULT_DATA_VALUE FOR CMP_EXTERNAL_WORKER_DATA_RGE_ASG_VALUE2 IS 'N/A'
DEFAULT FOR PER_ASG_ATTRIBUTE1 IS 'PERMANENTE'
DEFAULT FOR PER_ASG_ACTION_CODE IS 'N/A'
DEFAULT FOR PER_ASG_EFFECTIVE_START_DATE IS '1900/01/01' (date)
DEFAULT FOR PER_ASG_GRADE_ID IS 123
DEFAULT FOR PER_ASG_PERSON_ID IS 0
DEFAULT FOR CMP_ASSIGNMENT_SALARY_AMOUNT IS 0

/*============================================================================
  FECHAS BASE
============================================================================*/
HR_EXTRACT_DATE = TO_DATE(CMP_IV_PLAN_EXTRACTION_DATE, 'YYYY/MM/DD')
L_PL_END_DATE   = TO_DATE(CMP_IV_PLAN_END_DATE, 'YYYY/MM/DD')

l_log = SET_LOG('*** INICIO GB_CMP_INCRM_MERITO_RANGO ***')
L_ASG_ID = CMP_IVR_ASSIGNMENT_ID[1]
l_log = SET_LOG('Assignment ID: ' || TO_CHAR(L_ASG_ID))

/*============================================================================
  PROMEDIO BR
  Se obtiene el incremento promedio desde GB_INCREMENTO_MERITO_V2
  para la clave BR
============================================================================*/
L_PROM = TO_NUMBER(GET_TABLE_VALUE('GB_INCREMENTO_MERITO_V2', 'Incremento_Promedio', 'BR'))
l_log = SET_LOG('Promedio BR: ' || TO_CHAR(L_PROM))

/*============================================================================
  EVALUACION
  Se recorre el historial de datos externos con tipo CMP_MERITO
  y se mapea el valor numerico a texto usando GB_CMP_CALIFICAC_MERITO
============================================================================*/
L_EVAL_TXT    = 'N/A'
L_EVAL_MAPPED = 'N/A'
L_IDX         = 0

CHANGE_CONTEXTS(EFFECTIVE_DATE = HR_EXTRACT_DATE, COMPENSATION_RECORD_TYPE = 'CMP_MERITO')
(
    L_IDX = CMP_EXTERNAL_WORKER_DATA_RGE_ASG_SEQUENCE_NUMBER.LAST(-1)
    WHILE L_IDX >= 1 LOOP
    (
        L_EXT_VAL = CMP_EXTERNAL_WORKER_DATA_RGE_ASG_VALUE1[L_IDX]
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

/*============================================================================
  DATOS DEL ASSIGNMENT
  Se obtienen tipo de contrato, action code, fecha de contratacion,
  grado, sueldo y person ID con contexto a la fecha de extraccion
============================================================================*/
CHANGE_CONTEXTS(EFFECTIVE_DATE = HR_EXTRACT_DATE)
(
    L_TIPO_CONTRATO = PER_ASG_ATTRIBUTE1
    L_ACTION        = PER_ASG_ACTION_CODE
    L_HIRE_DATE     = PER_ASG_EFFECTIVE_START_DATE
    L_GRADE         = PER_ASG_GRADE_ID
    L_SUELDO        = CMP_ASSIGNMENT_SALARY_AMOUNT
    L_PER_ID        = PER_ASG_PERSON_ID
)

l_log = SET_LOG('Tipo contrato: ' || L_TIPO_CONTRATO)
l_log = SET_LOG('Action code: '   || L_ACTION)
l_log = SET_LOG('Hire Date: '     || TO_CHAR(L_HIRE_DATE, 'YYYY/MM/DD'))
l_log = SET_LOG('Grade ID: '      || TO_CHAR(L_GRADE))
l_log = SET_LOG('Sueldo: '        || TO_CHAR(L_SUELDO))

/*============================================================================
  CALCULO APERTURA
  Se obtienen min y max del plan salarial via Value Sets y se calcula
  la apertura del empleado respecto a su banda salarial
============================================================================*/
L_PARAM_PER = '|=PERSON_ID=' || TO_CHAR(L_PER_ID)
L_RATE_ID   = TO_NUM(GET_VALUE_SET('GB_CMP_ASG_RATE_ID', L_PARAM_PER))
l_log = SET_LOG('Rate ID: ' || TO_CHAR(L_RATE_ID))

IF L_RATE_ID > 0 THEN
(
    L_PARAM_MIN = '|=P_ASSIGNMENT_RATE=' || TO_CHAR(L_RATE_ID) || '|P_ASSIGNMENT_GRADE=' || TO_CHAR(L_GRADE)
    L_PARAM_MAX = '|=P_ASSIGNMENT_GRADE=' || TO_CHAR(L_GRADE)  || '|P_ASSIGNMENT_RATE='  || TO_CHAR(L_RATE_ID)
    L_MIN = TO_NUM(GET_VALUE_SET('GB_CMP_RATE_ID_VALUE_MIN', L_PARAM_MIN))
    L_MAX = TO_NUM(GET_VALUE_SET('GB_CMP_RATE_ID_VALUE_MAX', L_PARAM_MAX))
)
ELSE
(
    L_PARAM_GRADE = '|=P_ASSIGNMENT_GRADE=' || TO_CHAR(L_GRADE)
    L_MIN = TO_NUM(GET_VALUE_SET('GB_CMP_RATE_VALUE_MIN', L_PARAM_GRADE))
    L_MAX = TO_NUM(GET_VALUE_SET('GB_CMP_RATE_VALUE_MAX', L_PARAM_GRADE))
)

l_log = SET_LOG('Min plan: ' || TO_CHAR(L_MIN))
l_log = SET_LOG('Max plan: ' || TO_CHAR(L_MAX))

IF L_MAX = L_MIN THEN
    L_APERTURA = 0
ELSE
(
    L_VALOR_PUNTO = (L_MAX - L_MIN) / 30
    L_APERTURA    = ((L_SUELDO - L_MIN) / L_VALOR_PUNTO) + 70
)
l_log = SET_LOG('Apertura calculada: ' || TO_CHAR(L_APERTURA))

/*============================================================================
  VENTANA NEW HIRE
  Se calcula la fecha limite de 5 meses atras respecto a la fecha fin del plan
============================================================================*/
L_CINCO_MESES = ADD_MONTHS(L_PL_END_DATE, -5)

/*============================================================================
  CONDICION
  Se determina la condicion del empleado en orden de prioridad:
  Promotion, NewHire, NonPerm o None
============================================================================*/
IF L_ACTION = 'PROMOTION' THEN
    L_CONDICION = 'Promotion'
ELSE IF L_HIRE_DATE >= L_CINCO_MESES AND (L_ACTION = 'HIRE' OR L_ACTION = 'ADD_ASSIGN') THEN
    L_CONDICION = 'NewHire'
ELSE IF L_TIPO_CONTRATO = '2' THEN
    L_CONDICION = 'NonPerm'
ELSE
    L_CONDICION = 'None'

l_log = SET_LOG('Condicion: ' || L_CONDICION)

/*============================================================================
  CONSTRUCCION DE CLAVE UDT
  Se construye la clave dinamica que se usara para consultar
  GB_CMP_RANGOS_MERITO segun condicion, evaluacion y apertura
============================================================================*/
IF L_CONDICION = 'Promotion' THEN
    L_CLAVE = 'Promotion'
ELSE IF L_CONDICION = 'NonPerm' THEN
    L_CLAVE = 'NonPerm'
ELSE IF L_CONDICION = 'NewHire' THEN
    L_CLAVE = 'NewHire'
ELSE IF L_EVAL_TXT = 'N/A' THEN
    L_CLAVE = 'SinEval'
ELSE IF L_EVAL_TXT = 'Salida' THEN
    L_CLAVE = 'Salida'
ELSE IF L_EVAL_TXT = 'Necesita mejora' THEN
    L_CLAVE = 'Necesita mejora'
ELSE IF L_EVAL_TXT = 'Por debajo de lo esperado' THEN
    L_CLAVE = 'Por debajo de lo esperado'
ELSE IF L_APERTURA <= 100 THEN
    L_CLAVE = L_EVAL_TXT || '_LT100'
ELSE
    L_CLAVE = L_EVAL_TXT || '_GE100'

l_log = SET_LOG('Clave UDT: ' || L_CLAVE)

/*============================================================================
  Lectura User Definied Table
  Se obtiene el texto del rango directamente desde GB_CMP_RANGOS_MERITO
  usando la clave construida
============================================================================*/
L_RANGO_OUTPUT = GET_TABLE_VALUE('GB_CMP_RANGOS_MERITO', 'Texto_Rango', L_CLAVE)

l_log = SET_LOG('*** RESULTADO RANGO: ' || L_RANGO_OUTPUT || ' ***')
RETURN L_RANGO_OUTPUT