SELECT DISTINCT
          FJEP.jira_issue_dwkey
        , FJEP.jira_parent_issue_dwkey AS initiative_jira_issue_dwkey
FROM dim_jira_issue DJI
INNER JOIN 
	fact_jira_entity_property FJEP ON DJI.jira_issue_dwkey = FJEP.jira_issue_dwkey
INNER JOIN 
	fact_jira_issue FJI ON FJI.jira_issue_dwkey = DJI.jira_issue_dwkey
INNER JOIN 
	dim_jira_proj DJP ON FJI.jira_proj_dwkey = DJP.jira_proj_dwkey
WHERE 
        DJI.active_flg = 'Y' AND
        jira_proj_key_cd IN (" & Projects & ")
