use jira_Datamart
Go

SELECT  jira_proj_key_cd, SUM(story_points) RemainingStoryPoints, COUNT(story_points) Pointed_Stories, COUNT(DJI.jira_issue_dwkey) Total_Stories
/* Audit Fields
	DJI.source_jira_issue_id, story_points, dji.jira_issue_key_cd, jira_issue_type_dwkey
*/
	FROM dim_jira_issue DJI
	INNER JOIN fact_jira_issue FJI 
	ON FJI.jira_issue_dwkey = DJI.jira_issue_dwkey
	INNER JOIN dim_jira_proj DJP
	ON DJP.jira_proj_dwkey = FJI.jira_proj_dwkey
		LEFT JOIN (													-- Get the stories which are in the active sprint
		SELECT FJI.jira_issue_dwkey
			FROM fact_jira_issue FJI
			INNER JOIN fact_jira_issue_sprint FJIS
			ON fji.jira_issue_dwkey = FJIS.jira_issue_dwkey
			INNER JOIN dim_jira_sprint DJS
			ON DJS.jira_sprint_dwkey = FJIs.jira_sprint_dwkey
			INNER JOIN dim_jira_proj DJP
			ON DJP.jira_proj_dwkey = FJI.jira_proj_dwkey
				WHERE resolution_date_datawarehousekey < 0 
			AND jira_issue_type_dwkey NOT IN (2,1,5,40)	-- Sub-Task, Epic, ConfigItem, Improvement (Prevents another join)
			AND djs.sprint_status_desc = 'Active'
			) Ignore
			ON Ignore.jira_issue_dwkey = DJI.jira_issue_dwkey
	WHERE 
		DJP.jira_proj_key_cd in ('INFAOP', 'INFUOP', 'NAS', 'STOR', 'CF')
		AND resolution_dt IS NULL								-- Looking for unresolved issues
		AND jira_issue_type_dwkey NOT IN (2,1,5,40)		-- Sub-Task, Epic, ConfigItem, Improvement (Prevents another join)
		AND ignore.jira_issue_dwkey IS NULL					-- If it's null then it's not in the active sprint (LEFT JOIN group)
GROUP BY jira_proj_key_cd