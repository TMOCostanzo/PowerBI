SELECT  DISTINCT
		  DJI.jira_issue_dwkey 'DW Unique Issue ID'
		, DJI.source_jira_issue_id 'JIRA Unique Issue ID'
		, DJI.jira_issue_key_cd 'Issue Key'
		, DJI.summary 'Summary'
		, DJI.story_points 'Story Points'
		, DJS.sprint_id 'Sprint ID'
		, DJI.resolution_dt 'Resolution Date'
		, FJI.jira_issue_status 'Status'
		, DJS.Reset_Sprint_Name 'Sprint Name'
		, DJS.sprint_start_dt 'Sprint Start Date'
		, DJS.sprint_end_dt 'Sprint End Date'
		, DJS.sprint_complete_dt 'Sprint Complete Date'
		, DJS.sprint_status 'Sprint Status'
		, DJS.Current_year 'Current Year'
		, CASE
				WHEN DJI.resolution_dt > DJS.sprint_complete_dt
					THEN 
						'To Do'
					ELSE
						jira_issue_status
			END 'Reset Status'
		, CASE ISNULL(DJI.Story_Points, -1) 
				WHEN -1
					THEN
						dji.story_points
					ELSE
						CASE jira_issue_status 
							WHEN 'Blocked'
								THEN 0
							ELSE 
								CASE
									WHEN DJI.resolution_dt > DJS.sprint_complete_dt or ISNULL(dji.resolution_dt ,0) = 0
										THEN 
											0
										ELSE
											DJI.story_points
								END
						END 
			END 'Sprint Completed Story Points'
		, CASE jira_issue_status 
				WHEN 'Blocked'
					THEN
						CASE ISNULL(story_points,-1)
							WHEN -1
								THEN 
									story_points
								ELSE
									0
						END
					ELSE 
						DJI.story_points 
			END 'Committed Points'
		, DJP.jira_proj_key_cd
		, DJI.issue_creation_dt
		, 'Display JIRA Sprint' =
			CASE	
				CHARINDEX('_', djs.Reset_Sprint_Name) 
				WHEN 0 
					THEN djs.Reset_Sprint_Name
				ELSE
					RIGHT(djs.Reset_Sprint_Name, CHARINDEX('_', REVERSE(djs.Reset_Sprint_Name))-1)
				END
		, 'Sprint Modification' = CASE 
			WHEN issue_creation_dt between DJS.sprint_start_dt and DJS.sprint_end_dt
			THEN 'Added'
			ELSE ''
			END
		, DJI.priority_desc
FROM fact_jira_issue_sprint FJIS
	INNER JOIN  fact_jira_issue FJI ON
		FJI.jira_issue_dwkey = FJIS.jira_issue_dwkey 
	INNER JOIN dim_jira_proj DJP ON
		FJI.jira_proj_dwkey = DJP.jira_proj_dwkey
	INNER JOIN dim_jira_issue DJI ON
		FJI.jira_issue_dwkey = DJI.jira_issue_dwkey
	INNER JOIN (
			SELECT S.sprint_id
				, S.jira_sprint_dwkey
				, Reset_Sprint_Name =
					CASE 
						WHEN CHARINDEX('backlog', sprint_name) >0
					THEN 
						'Backlog'
					ELSE
						sprint_name
					END
			, sprint_start_dt, sprint_complete_dt, sprint_end_dt
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
			CASE YEAR(sprint_start_dt)
				WHEN YEAR(CURRENT_TIMESTAMP)
					THEN
						CASE WHEN 
							sprint_start_dt > DATEADD(mm,-3,CURRENT_TIMESTAMP)
							THEN
								'Last 3 Months'
							ELSE 
								CASE WHEN 
									sprint_start_dt > DATEADD(mm,-6,CURRENT_TIMESTAMP)
									THEN
										'Last 6 Months'
									ELSE 
										'Over 6 Months'
								END 
							END
					ELSE
						'Not CY'
				END
			FROM dim_jira_sprint S
	)  DJS
	ON
		FJIS.jira_sprint_dwkey = DJS.jira_sprint_dwkey

WHERE DJP.jira_proj_key_cd in ('INFAOP', 'INFUOP', 'NAS', 'STOR', 'WI')
	AND fji.jira_issue_type_dwkey <> 2		-- No Epics
	AND DJS.sprint_id <> 867					-- Skips a specific sprint.

