SELECT Distinct
		S.sprint_id
		, JP.jira_proj_key_cd
		, sprint_name_corrected =
		CASE 
			WHEN CHARINDEX('backlog', sprint_name) >0
				THEN 
					'Backlog'
				ELSE
					sprint_name
		END
		, sprint_start_dt, sprint_complete_dt, sprint_end_dt, 'None' sprint_goal, JP.jira_proj_dwkey, jira_proj_key_cd, jira_proj_name
		 , sprint_status = 
		 CASE ISNULL( sprint_start_dt, 0) 
			WHEN 0 THEN 
				CASE WHEN CHARINDEX('backlog', sprint_name) >  0
					THEN 
						'Backlog'
					ELSE 
						'Future'
					END 
			ELSE 
				CASE closed_indicator
				WHEN 1 
					THEN 'Closed'
				ELSE
					'Active'
				END
		END
	FROM
		dim_jira_sprint S
		INNER JOIN fact_jira_issue_sprint JIS
			ON S.jira_sprint_dwkey = JIS.jira_sprint_dwkey
		INNER JOIN fact_jira_issue FJI
			ON FJI.jira_issue_dwkey = JIS.jira_issue_dwkey 
		INNER JOIN dim_jira_proj JP
			ON JP.jira_proj_dwkey = FJI.jira_proj_dwkey
	WHERE
			jira_proj_key_cd IN( 'INFAOP', 'INFUOP', 'WI', 'NAS', 'STOR')
