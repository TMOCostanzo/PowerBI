SELECT 	  jira_issue_dwkey 'DW Unique Issue ID'
		, Current_year
		, story_points
		, Count(jira_sprint_dwkey) 'Number of Sprints'  
FROM (
	SELECT DISTINCT
		  FJI.jira_issue_dwkey
		, DJS.jira_sprint_dwkey 
		, DJI.story_points
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
		WHERE DJP.jira_proj_key_cd IN ('WI', 'NAS', 'STOR', 'INFAOP', 'INFUOP')
	) SprintCounts
GROUP BY jira_issue_dwkey
	, Current_year
	, story_points


	select * from dim_jira_issue where jira_issue_dwkey = 101269