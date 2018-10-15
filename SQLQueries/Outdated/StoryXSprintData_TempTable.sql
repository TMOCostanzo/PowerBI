SELECT DISTINCT 
		  S.sprint_id
		, S.jira_sprint_dwkey
		, 'Sprint Name' =
		CASE 
			WHEN CHARINDEX('backlog', sprint_name) >0
				THEN 
					'Backlog'
				ELSE
					sprint_name
		END
		, sprint_start_dt, sprint_complete_dt, sprint_end_dt, 'None' sprint_goal
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
		, Current_year =
		CASE ISNULL( sprint_start_dt, 0)
			WHEN 0 
				THEN 
					'Yes'
				ELSE CASE YEAR(sprint_start_dt)
					WHEN YEAR(CURRENT_TIMESTAMP)
						THEN
							'Yes'
						ELSE
							'No'
					END
			END
	INTO #TSprint 
	FROM
		dim_jira_sprint S

SELECT  DISTINCT
		  DJI.jira_issue_dwkey 'DW Unique Issue ID'
		, DJI.source_jira_issue_id 'JIRA Unique Issue ID'
		, DJI.jira_issue_key_cd 'Issue Key'
		, DJI.story_points 'Story Points'
		, DJS.sprint_id 'Sprint ID'
		, DJI.resolution_dt 'Resolution Date'
		, FJI.jira_issue_status 'Status'
		, DJS.[Sprint Name]
		, DJS.sprint_start_dt 'Sprint Start Date'
		, DJS.sprint_end_dt 'Sprint End Date'
		, DJS.sprint_complete_dt 'Sprint Complete Date'
		, DJS.sprint_status 'Sprint Status'
		, DJS.Current_year 'Current Year'
		, CASE jira_issue_status 
			WHEN 'Blocked'
				THEN 'Blocked'
			ELSE CASE
				WHEN DJI.resolution_dt > DJS.sprint_end_dt
					THEN 
						'To Do'
					ELSE
						jira_issue_status
				END 
			END 'Reset Status'
		, CASE jira_issue_status 
			WHEN 'Blocked'
				THEN 0
			ELSE CASE
				WHEN DJI.resolution_dt > DJS.sprint_end_dt
					THEN 
						0
					ELSE
						DJI.story_points
				END 
			END 'Sprint Completed Story Points'
		, CASE jira_issue_status 
			WHEN 'Blocked'
				THEN 0
			ELSE 
				DJI.story_points 
			END 'Committed Points'
		, DJP.jira_proj_key_cd
		, DJI.issue_creation_dt

FROM #Tsprint DJS
	INNER JOIN fact_jira_issue_sprint FJIS ON
		FJIS.jira_sprint_dwkey = DJS.jira_sprint_dwkey
	INNER JOIN  fact_jira_issue FJI ON
		FJI.jira_issue_dwkey = FJIS.jira_issue_dwkey 
	INNER JOIN dim_jira_proj DJP ON
		FJI.jira_proj_dwkey = DJP.jira_proj_dwkey
	INNER JOIN dim_jira_issue DJI ON
		FJI.jira_issue_dwkey = DJI.jira_issue_dwkey
WHERE DJP.jira_proj_key_cd in ('INFAOP', 'INFUOP', 'NAS', 'STOR', 'WI')
	AND sprint_id <> 867

DROP TABLE #Tsprint
