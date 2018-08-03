SELECT DISTINCT DJS.*, FJI.jira_issue_dwkey FROM dim_jira_sprint DJS
INNER JOIN fact_jira_issue_sprint FJIS ON
	FJIS.jira_sprint_dwkey = DJS.jira_sprint_dwkey
INNER JOIN fact_jira_issue FJI ON
	FJI.jira_issue_dwkey = FJIS.jira_issue_dwkey
INNER JOIN dim_jira_proj DJP ON
	FJI.jira_proj_dwkey = DJP.jira_proj_dwkey
WHERE jira_proj_key_cd in ('INFAOP', 'INFUOP', 'NAS', 'STOR', 'WI')
