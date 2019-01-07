/*
	Returns the count of sprints an issue was in.
	Ignores Epics and sub-tasks
	Only includes COMPLETED sprints
*/

SELECT *
 		, Rolling_Months = 
		CASE WHEN [Latest Sprint] > DATEADD(mm,-3,CURRENT_TIMESTAMP)
			THEN
				'Last 3 Months'
			ELSE 
				CASE WHEN [Latest Sprint] > DATEADD(mm,-6,CURRENT_TIMESTAMP)
				THEN
					'Last 6 Months'
				ELSE 
					CASE WHEN [Latest Sprint] > DATEADD(mm,-12,CURRENT_TIMESTAMP)
					THEN
						'Last 12 Months'
					ELSE
						'All'
					END
				END
			END
FROM (
	SELECT
		 	  jira_issue_dwkey 'DW Unique Issue ID'
			, Current_year
			, story_points
			, Count(jira_sprint_dwkey) 'Number of Sprints'  
			, MIN(sprint_start_dt) 'Earliest Sprint'  
			, MAX(sprint_end_dt) 'Latest Sprint'  
	FROM (
			SELECT DISTINCT
				  FJI.jira_issue_dwkey
				, DJS.jira_sprint_dwkey 
				, DJI.story_points
				, sprint_start_dt
				, sprint_end_dt = 
					CASE WHEN ABS(datediff("dd", DJS.sprint_end_dt, DJS.sprint_complete_dt)) > 2
						THEN 
							DJS.sprint_complete_dt
						ELSE
							DJS.Sprint_end_dt
					END
				, Current_year =
				CASE YEAR(sprint_start_dt)
					WHEN YEAR(CURRENT_TIMESTAMP)
						THEN
							'Yes'
						ELSE
							'No'
					END
			FROM fact_jira_issue FJI
				INNER JOIN dim_jira_issue DJI
					ON FJI.jira_issue_dwkey = DJI.jira_issue_dwkey
				INNER JOIN fact_jira_issue_sprint FJIS
					ON FJI.jira_issue_dwkey = FJIS.jira_issue_dwkey
				INNER JOIN dim_jira_sprint DJS
					ON DJS.jira_sprint_dwkey = FJIS.jira_sprint_dwkey
				INNER JOIN dim_jira_proj DJP ON
					FJI.jira_proj_dwkey = DJP.jira_proj_dwkey
				INNER JOIN (
					SELECT * 
					FROM dim_jira_issue_type  
					WHERE CHARINDEX('sub-task', issue_type_desc ) = 0 AND Issue_type <> 'Epic'
					) DJIT
				ON DJIT.jira_issue_type_dwkey = FJI.jira_issue_type_dwkey
				WHERE DJP.jira_proj_key_cd IN ('WI', 'NAS', 'STOR', 'INFAOP', 'INFUOP')
					AND DJS.sprint_status_desc = 'Completed'
					AND FJI.jira_issue_dwkey = 182969
			) SprintCounts
	GROUP BY jira_issue_dwkey
		, Current_year
		, story_points
		) Issue_Range