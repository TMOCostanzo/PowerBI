SELECT DISTINCT FJI.jira_issue_dwkey 'DW Unique Issue ID'
	, FJI.source_jira_issue_id 'JIRA Unique Issue ID'
	, DJI.jira_issue_key_cd 'Issue Key'
	, DJI.story_points
	, DJIS.sprint_id
	, DJI.resolution_dt
	, FJI.jira_issue_status 'Status'
FROM dim_jira_sprint DJIS
	INNER JOIN fact_jira_issue_sprint FJIS ON
		FJIS.jira_sprint_dwkey = DJIS.jira_sprint_dwkey
	INNER JOIN fact_jira_issue FJI ON
		FJI.jira_issue_dwkey = FJIS.jira_issue_dwkey
	INNER JOIN dim_jira_proj DJP ON
		FJI.jira_proj_dwkey = DJP.jira_proj_dwkey
	INNER JOIN dim_jira_issue DJI ON
		FJI.jira_issue_dwkey = DJI.jira_issue_dwkey
WHERE jira_proj_key_cd in ('INFAOP', 'INFUOP', 'NAS', 'STOR', 'WI')
	AND fji.jira_issue_type_dwkey = 9
