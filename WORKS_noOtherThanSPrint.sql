
DECLARE @sprintID  varchar(20)

SET @sprintID = '2029'

SELECT 	FJI.jira_issue_dwkey
	,	DJI.jira_issue_key_cd
	,  sprint_id
	,	sprint_name
	,	sprint_start_dt
	,	sprint_end_dt
	,  sprint_complete_dt
	,  DJI.issue_creation_dt
	,  FJIH.old_value_id
	,  FJIH.field_name
	,  ISNULL(FJIH.source_created_dt, issue_creation_dt) source_created_dt_history 
	,	ISNULL(FJIH.new_value_id, sprint_id) new_value_id
into #sprint_history
FROM  fact_jira_issue FJI
		INNER JOIN dim_jira_issue DJI on DJI.jira_issue_dwkey = FJI.jira_issue_dwkey
		INNER JOIN fact_jira_issue_sprint (nolock) B on FJI.jira_issue_dwkey = B.jira_issue_dwkey
      INNER JOIN dim_jira_sprint (nolock) DJS on B.source_sprint_id = DJS.sprint_id
		LEFT OUTER JOIN fact_jira_issue_history (nolock) FJIH ON FJI.jira_issue_dwkey = FJIH.jira_issue_dwkey
WHERE DJS.sprint_id = @sprintID 

SELECT sprint_name
	, jira_issue_dwkey
	, jira_issue_key_cd
	, sprint_id
	, old_value_id
	, new_value_id
	, field_name
	, source_created_dt_history
	, sprint_start_dt
	, sprint_end_dt
	, sprint_complete_dt
	, issue_creation_dt
	, CASE WHEN source_created_dt_history between sprint_start_dt and sprint_end_dt THEN 'TRUE'  END as 'Addition_DuringSprint'  
	, CASE WHEN issue_creation_dt between sprint_start_dt and sprint_end_dt THEN 'TRUE' END as 'Issue_Creation_DuringSprint'  
	into #addition 
	FROM #sprint_history

SELECT DISTINCT sprint_name, sprint_id, jira_issue_dwkey, jira_issue_key_cd, Addition_DuringSprint, Issue_Creation_DuringSprint
FROM #addition
WHERE sprint_id = @sprintID
	AND	( ( Issue_Creation_DuringSprint IS NOT NULL  AND Addition_DuringSprint IS NOT NULL)
				 OR (
					field_name = 'Sprint' 
						AND	Addition_DuringSprint IS NOT NULL 
						AND	CASE WHEN
									CHARINDEX(@sprintID, new_value_id) <> 0 AND (old_value_id is null OR CHARINDEX(@sprintID, old_value_id) = 0)
									THEN 
										'yes'
									ELSE
										'no'
									END = 'yes' 
					)
			)
	ORDER BY jira_issue_key_cd
	
	select * from #sprint_history where jira_issue_dwkey = 160165
DROP TABLE #addition
DROP TABLE #sprint_history

