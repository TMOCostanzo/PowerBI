SELECT
      [sprint_name]
      ,[sprint_start_dt]
      ,[sprint_end_dt]
		,story_points
		,resolution_dt 
		,source_created_dt
		,jira_issue_key_cd
		,summary
		,jira_proj_key_cd
		,label_desc
		,FJI.jira_issue_status
		, DJI.priority_desc
FROM [JIRA_Datamart].[dbo].[dim_jira_sprint] DJS
INNER JOIN fact_jira_issue_sprint FJIS
	ON FJIS.jira_sprint_dwkey = DJS.jira_sprint_dwkey
INNER JOIN dim_jira_issue DJI
	ON DJI.jira_issue_dwkey = FJIS.jira_issue_dwkey
INNER JOIN fact_jira_issue FJI
	ON FJI.jira_issue_dwkey = DJI.jira_issue_dwkey
INNER JOIN dim_jira_proj DJP
	ON DJP.jira_proj_dwkey = FJI.jira_proj_dwkey
WHERE sprint_status_desc = 'Active'
  AND jira_proj_key_cd IN ('INFAOP', 'STOR', 'INFUOP')
  AND (resolution_short_desc is NULL OR resolution_short_desc = 'Done')
ORDER BY sprint_name