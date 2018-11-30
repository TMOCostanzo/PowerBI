SELECT DISTINCT  DJI_Init.jira_issue_dwkey 'Initiative DWKey'
	, DJI_Init.jira_issue_key_cd 'Initiative JIRA Key'
	, DJI_Init.summary 'Initiative Summary'
	, FJI.jira_issue_dwkey 'Epic DWKey'
	, DJI.jira_issue_key_cd 'Epic JIRA Key'
	, DJI.summary 'Epic Summary'
	, DJP.jira_proj_dwkey 'Project DWKey'
	, DJP.jira_proj_key_cd 'Project'
	, COMP.component_name 'Component Name'
FROM dim_jira_issue DJI_Init
INNER JOIN fact_jira_entity_property FJEP
	ON FJEP.jira_parent_issue_dwkey= DJI_Init.jira_issue_dwkey
INNER JOIN fact_jira_issue FJI
	ON FJI.jira_issue_dwkey = fjep.jira_issue_dwkey
INNER JOIN dim_jira_issue_type DJIT
	ON djit.jira_issue_type_dwkey = FJI.jira_issue_type_dwkey
INNER JOIN dim_jira_proj DJP
	ON djp.jira_proj_dwkey = fji.jira_proj_dwkey
INNER JOIN dim_jira_issue DJI
	ON DJI.jira_issue_dwkey = FJI.jira_issue_dwkey
LEFT JOIN (
		SELECT jira_issue_dwkey, component_name
		FROM fact_jira_issue_component FJIC
		INNER JOIN dim_jira_component DJC 
		ON FJIC.jira_component_dwkey = DJC.jira_component_dwkey
		WHERE FJIC.active_ind = 'Y'
	) COMP
	ON DJI_Init.jira_issue_dwkey = COMP.jira_issue_dwkey
WHERE djit.issue_type = 'Epic'
	AND djp.jira_proj_key_cd IN ('INFAOP', 'INFUOP',  'NAS', 'STOR')
	AND DJI_Init.jira_issue_dwkey = 134782