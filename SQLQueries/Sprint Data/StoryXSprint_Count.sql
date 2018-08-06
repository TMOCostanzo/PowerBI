SELECT 	  jira_issue_dwkey 'DW Unique Issue ID'
		, source_jira_issue_id 'JIRA Unique Issue ID'
		, Current_year
		, Count(Current_year) 'Number of Sprints'  
FROM (
	SELECT DISTINCT
		  FJI.jira_issue_dwkey 
		, FJI.source_jira_issue_id 
		, Current_year =
		CASE YEAR(sprint_start_dt)
			WHEN YEAR(CURRENT_TIMESTAMP)
				THEN
					'Yes'
				ELSE
					'No'
			END
	FROM fact_jira_issue FJI
		INNER JOIN fact_jira_issue_sprint FJIS
			ON FJI.jira_issue_dwkey = FJIS.jira_issue_dwkey
		INNER JOIN dim_jira_sprint DJS
			ON DJS.jira_sprint_dwkey = FJIS.jira_sprint_dwkey
		INNER JOIN dim_jira_proj DJP ON
			FJI.jira_proj_dwkey = DJP.jira_proj_dwkey
		WHERE DJP.jira_proj_key_cd IN --('WI', 'NAS', 'STOR', 'INFAOP', 'INFUOP')
			('INFAOP', 'INFUOP')
			AND FJI.jira_issue_dwkey = 101269
	) SprintCounts
GROUP BY jira_issue_dwkey
	, source_jira_issue_id 
	, Current_year


	select * from dim_jira_issue where jira_issue_dwkey = 101269