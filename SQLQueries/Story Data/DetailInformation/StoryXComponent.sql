SELECT FJI.jira_issue_dwkey 'DW Unique Issue ID'
		, DJI.jira_issue_key_cd 'Issue Key' 
		, Comp.component_name 'Component'
		, FJI.jira_issue_id 'JIRA Unique Issue ID'
	FROM 
		fact_jira_issue FJI
	INNER JOIN 
		dim_jira_issue DJI
		ON
			FJI.jira_issue_dwkey = DJI.jira_issue_dwkey
	INNER JOIN
		dim_jira_proj DJP
		ON
			FJI.jira_proj_dwkey = DJP.jira_proj_dwkey
	INNER JOIN (
		SELECT DJC.component_name, FJIC.jira_issue_dwkey
			FROM 
				fact_jira_issue_component FJIC
			INNER JOIN
				dim_jira_component DJC
					ON FJIC.jira_component_dwkey = DJC.jira_component_dwkey
		) Comp
		ON FJI.jira_issue_dwkey = COMP.jira_issue_dwkey
	WHERE
		DJP.jira_proj_key_cd IN ('WI', 'NAS', 'STOR', 'INFAOP', 'INFUOP')
		AND FJI.jira_issue_type_dwkey = 9
