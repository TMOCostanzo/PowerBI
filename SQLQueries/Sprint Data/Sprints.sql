/*
	Returns all sprint information
	If the sprint name CONTAINS Backlog: 
		it collapses to just being a backlog
		it has a different state called Backlog to differentiate it from a future sprint. Future sprints are those that are generally for planning
*/
SELECT Distinct
		S.sprint_id
		, sprint_name_corrected = DJS.Reset_Sprint_Name
		, sprint_start_dt
		, sprint_complete_dt 
		, sprint_end_dt = 
			CASE WHEN ABS(datediff("dd", S.sprint_end_dt, S.sprint_complete_dt)) > 2
				THEN 
					S.sprint_complete_dt
				ELSE
					s.Sprint_end_dt
			END
		, 'None' sprint_goal
		, sprint_status = 
		 CASE WHEN Reset_Sprint_Name = 'Backlog'
				THEN 
					'Backlog'
				ELSE 
					sprint_status_desc
				END 
		, Current_year =
		CASE YEAR(isnull(sprint_start_dt,CURRENT_TIMESTAMP))
			WHEN YEAR(CURRENT_TIMESTAMP)
				THEN
					'Yes'
				ELSE
					'No'
			END
		, 'Display JIRA Sprint' =
			CASE	
				CHARINDEX('_', djs.Reset_Sprint_Name) 
				WHEN 0 
					THEN djs.Reset_Sprint_Name
				ELSE
					RIGHT(djs.Reset_Sprint_Name, CHARINDEX('_', REVERSE(djs.Reset_Sprint_Name))-1)
				END
	FROM
		dim_jira_sprint S
		INNER JOIN fact_jira_issue_sprint JIS
			ON S.jira_sprint_dwkey = JIS.jira_sprint_dwkey
		INNER JOIN (
				SELECT sprint_id
					, Reset_Sprint_Name =
						CASE 
							WHEN CHARINDEX('backlog', sprint_name) >0
						THEN 
							'Backlog'
						ELSE
							sprint_name
						END
				FROM dim_jira_sprint
			) DJS
			ON DJS.sprint_id = s.Sprint_id
		INNER JOIN fact_jira_issue FJI
			ON FJI.jira_issue_dwkey = JIS.jira_issue_dwkey 
		INNER JOIN dim_jira_proj JP
			ON JP.jira_proj_dwkey = FJI.jira_proj_dwkey
	WHERE
		jira_proj_key_cd IN( 'INFAOP', 'INFUOP', 'WI', 'NAS', 'STOR')
		and S.sprint_id IN( 1494, 1859)

