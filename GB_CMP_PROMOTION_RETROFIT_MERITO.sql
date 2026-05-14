/**********************************************************************
FORMULA NAME: GB_CMP_PROMOTION_RETROFIT_MERITO
FORMULA TYPE : Compensation Default and Override
DESCRIPTION : Determina si el empleado tuvo un cambio de nivel dentro del periodo de evaluación establecido.
***********************************************************************/
 
/*=========== INPUT VALUES DEFAULTS BEGIN =====================*/
INPUTS ARE 
CMP_IV_PLAN_START_DATE (date), 
CMP_IV_PLAN_END_DATE (date), 
CMP_IV_PLAN_EXTRACTION_DATE (date)
 
/* +========================= DEFAULT SECTION BEGIN ============================== */
DEFAULT FOR PER_ASG_JOB_MANAGER_LEVEL IS 'NA'
DEFAULT FOR PER_ASG_EFFECTIVE_START_DATE IS '1981/05/15' (date)
DEFAULT FOR PER_ASG_EFFECTIVE_END_DATE IS '4712/12/31' (date)
DEFAULT FOR PER_PER_LATEST_REHIRE_DATE IS '1901/01/01' (date)
DEFAULT FOR PER_ASG_REL_ORIGINAL_DATE_OF_HIRE IS '1901/01/01' (date)
 
/* +========================= DEFAULT SECTION ENDS =============================== */
 
/* +========================= FORMULA SECTION BEGIN ============================== */
/* +========================= LOCAL VARIABLES BEGIN ============================== */
L_DEFAULT_VALUE = 'NULL'
L_COUNT = 0
PRIOR_LEVEL = 'NA'
LEVEL1 = 'NA'
PRO = 'N'
LEVEL_CHANGE = 'N'
 
/* +========================= LOCAL VARIABLES ENDS =============================== */
 
PL_START_DATE = CMP_IV_PLAN_START_DATE
PL_END_DATE = CMP_IV_PLAN_END_DATE
HR_EXTRACT_DATE = CMP_IV_PLAN_EXTRACTION_DATE
 
/* Nueva lógica para periodo automático de promociones */
/* PROMOTION_START_DATE = ADD_MONTHS(PL_START_DATE, 12) */ /* 12 meses después del inicio del periodo */
PROMOTION_START_DATE = ADD_MONTHS(PL_END_DATE, -5)  /* Fix para restar 5 meses al fin del periodo */
PROMOTION_END_DATE = HR_EXTRACT_DATE /* La fecha de extracción de datos será el fin del periodo */
 
/* Ajustar el contexto con la fecha de extracción */
CHANGE_CONTEXTS(EFFECTIVE_DATE = HR_EXTRACT_DATE)
(
MGR_LVL = PER_ASG_JOB_MANAGER_LEVEL
ASSIGN_START_DATE = PER_ASG_EFFECTIVE_START_DATE
ASSIGN_END_DATE = PER_ASG_EFFECTIVE_END_DATE
)
 
/* Comprobar si la asignación ocurrió dentro del rango del periodo de promociones */
If ASSIGN_START_DATE >= PROMOTION_START_DATE and ASSIGN_START_DATE <= PROMOTION_END_DATE then
(
  L_COUNT = 0
  WHILE (L_COUNT <= 10) LOOP  
  (
    L_COUNT = L_COUNT + 1
    PRIOR_ASSIGN_START_DATE = ADD_DAYS(ASSIGN_START_DATE, -1)
    IF ASSIGN_END_DATE > PROMOTION_START_DATE THEN 
    (
      CHANGE_CONTEXTS(EFFECTIVE_DATE = PRIOR_ASSIGN_START_DATE)
      (
        PRIOR_ASSIGN_START_DATE = PER_ASG_EFFECTIVE_START_DATE
        PRIOR_LEVEL = PER_ASG_JOB_MANAGER_LEVEL
		PRIOR_ASSIGN_END_DATE = PER_ASG_EFFECTIVE_END_DATE 
      
        IF PRIOR_LEVEL <> 'NA' AND PRIOR_LEVEL = MGR_LVL THEN
        (
          ASSIGN_START_DATE = PRIOR_ASSIGN_START_DATE
        )
        ELSE
        (
          IF PRIOR_ASSIGN_END_DATE < PROMOTION_START_DATE THEN
          (
            ASSIGN_START_DATE = PRIOR_ASSIGN_START_DATE
          )
          ELSE
          (
            LEVEL1 = PRIOR_LEVEL
            EXIT
          )
        )
      )
    )
  )
)
 
/* Establecer cambios detectados */
IF LEVEL1 <> 'NA' AND 
TO_NUMBER(MGR_LVL) > TO_NUMBER(LEVEL1) THEN
(LEVEL_CHANGE = 'Y')

/* Si hubo cambio de nivel, marcar promoción */
if LEVEL_CHANGE = 'Y' THEN
(
PRO = 'PRO'
)
 
/* Log de las variables */
l_log = SET_LOG('LEVEL_CHANGE: ')
l_log = SET_LOG(LEVEL_CHANGE)
l_log = SET_LOG('LEVEL1: ')
l_log = SET_LOG(LEVEL1)
l_log = SET_LOG('MGR_LVL: ')
l_log = SET_LOG(MGR_LVL)
 
/* Log de las fechas importantes */
l_log = SET_LOG('ORIGINAL_HIRE_DATE: ')
l_log = SET_LOG(TO_CHAR(PER_ASG_REL_ORIGINAL_DATE_OF_HIRE))
l_log = SET_LOG('PL_START_DATE: ')
l_log = SET_LOG(TO_CHAR(PL_START_DATE))
l_log = SET_LOG('PROMOTION_START_DATE: ')
l_log = SET_LOG(TO_CHAR(PROMOTION_START_DATE))
l_log = SET_LOG('PROMOTION_END_DATE: ')
l_log = SET_LOG(TO_CHAR(PROMOTION_END_DATE))
l_log = SET_LOG('ASSIGN_START_DATE: ')
l_log = SET_LOG(TO_CHAR(ASSIGN_START_DATE))
l_log = SET_LOG('ASSIGN_END_DATE: ')
l_log = SET_LOG(TO_CHAR(ASSIGN_END_DATE))



 
L_DEFAULT_VALUE = PRO
 
RETURN L_DEFAULT_VALUE