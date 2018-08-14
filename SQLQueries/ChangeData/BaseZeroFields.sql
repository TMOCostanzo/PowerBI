SELECT DISTINCT   sprint_name, source_sprint_id sprint_id, field_name, 'Generated' Who_Changed_Full_Name, jira_proj_key_cd, 'TRUE,FALSE' Occurred_During_Sprint, Current_year, 0 Instances
			FROM 
				(	SELECT DISTINCT field_name FROM fact_jira_issue_history
					WHERE field_name IN ('Blocked Reason', 'Description', 'Expected Unblocked Date', 'IssueType',  'Project',  'Sprint', 'Story Points', 'Summary')
				)  History
			CROSS APPLY
				(	SELECT DISTINCT DJP.jira_proj_key_cd, source_sprint_id , sprint_name
						, Current_year =
						CASE YEAR(sprint_start_dt)
							WHEN YEAR(CURRENT_TIMESTAMP)
								THEN
									'Yes'
								ELSE
									'No'
							END
					FROM fact_jira_issue_sprint FJIS
					INNER JOIN dim_jira_sprint	DJS
						ON DJS.jira_sprint_dwkey = FJIS.jira_sprint_dwkey
					INNER JOIN fact_jira_issue FJI
						ON FJIS.jira_issue_dwkey = FJI.jira_issue_dwkey
					INNER JOIN dim_jira_proj DJP
						ON FJI.jira_proj_dwkey = DJP.jira_proj_dwkey
					WHERE jira_proj_key_cd IN ('INFAOP', 'INFUOP', 'WI', 'STOR', 'NAS')
				) Sprints
WHERE Sprint_name = 'INFOP_2018-01-16'