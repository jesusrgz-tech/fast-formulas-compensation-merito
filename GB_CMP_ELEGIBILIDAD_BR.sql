/******************************************************************************
* *
* FORMULA NAME      : GB_CMP_ELEGIBILIDAD_BR                                  *
* FORMULA TYPE      : Participation and Rate Eligibility                      *
* DESCRIPTION       : Elegibilidad para Brasil. Incluye solo colaboradores    *
*                     con nivel 4 en adelante                                  
* *
*---------------------------------------------------------------------------*
* CREATED BY        : IT-GLOBAL                                               *
* CREATION DATE     : 07-Abril-2026                                           *
* LAST UPDATE DATE  : 08-Abril-2026                                           *
* *
=============================================================================
Change History:
Author          | Date            | Ver | Comments                          *
-----------------+-----------------+-----+-----------------------------------*
IT Global       | 07-Abril-2026   |  1  | Version Inicial                   *
IT Global       | 08-Abril-2026   |  2  | Actualizacion de logica           *
=============================================================================*/

INPUTS ARE CMP_IV_PLAN_ELIG_DATE (text)

DEFAULT FOR CMP_IV_PLAN_ELIG_DATE IS '4012/01/01'
DEFAULT FOR PER_ASG_JOB_MANAGER_LEVEL IS 'NO_MGR_LVL'

L_DEFAULT_VALUE = 'NULL'
ELIGIBLE = 'N'
MGR_LVL = 'NO_MGR_LVL'
MGR_LVL_NUM = 0

ELIG_DATE = TO_DATE(CMP_IV_PLAN_ELIG_DATE, 'YYYY/MM/DD')

CHANGE_CONTEXTS(EFFECTIVE_DATE = ELIG_DATE)
(
    MGR_LVL = PER_ASG_JOB_MANAGER_LEVEL

    IF MGR_LVL <> 'NO_MGR_LVL' THEN
        MGR_LVL_NUM = TO_NUM(MGR_LVL)
)

IF MGR_LVL_NUM >= 4 THEN
    ELIGIBLE = 'Y'

RETURN ELIGIBLE