SELECT 
	YearControl, jira_proj_key_cd, jira_issue_status, COUNT(jira_issue_dwkey) Count_Issues , ISNULL(SUM(story_points),0) Sum_Story_Points

FROM (


SELECT DISTINCT FJI.jira_issue_dwkey,  jira_proj_key_cd, FJI.jira_issue_status, story_points, YEAR(DJI.issue_creation_dt) YEARControl
FROM fact_jira_issue FJI
INNER JOIN dim_jira_proj DJP ON
	FJI.jira_proj_dwkey = DJP.jira_proj_dwkey
INNER JOIN dim_jira_issue DJI ON
	DJI.jira_issue_dwkey = FJI.jira_issue_dwkey
WHERE issue_creation_dt >=  '1/1/' +  CAST(YEAR(CURRENT_TIMESTAMP) - 1 AS varchar)
	AND jira_proj_key_cd IN ('WI', 'NAS', 'STOR', 'INFUOP', 'INFAOP')
	AND jira_issue_type_dwkey NOT IN (1,2, 19, 21, 40)
) JIRA_Data


GROUP BY YearControl, jira_proj_key_cd, jira_issue_status

