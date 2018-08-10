
DECLARE @sprintID  varchar(20)

SET @sprintID = '2029'
SELECT DISTINCT
	dspr.sprint_name
	, f.jira_issue_dwkey
	, jira_issue_key_cd
	, dspr.sprint_id
	, f.old_value_id
	, f.new_value_id
	, f.field_name
	, f.source_created_dt source_created_dt_history
	, sprint_start_dt
	, sprint_end_dt
	, sprint_complete_dt
	, i.issue_creation_dt
INTO #Sprint_history
FROM [dbo].[fact_jira_issue_history] f (nolock)
	INNER JOIN [dbo].[fact_jira_issue_sprint] spr (nolock) on case when isnumeric(f.new_value_id)=1 then f.new_value_id else -9999 end=spr.source_sprint_id
	INNER JOIN [dbo].[dim_jira_sprint] dspr (nolock) on spr.[jira_sprint_dwkey]=dspr.jira_sprint_dwkey
	INNER JOIN dim_jira_issue i (nolock) on f.jira_issue_dwkey=i.[jira_issue_dwkey]
	INNER JOIN fact_jira_issue J (nolock) on i.jira_issue_dwkey = j.jira_issue_dwkey
	LEFT OUTER JOIN dim_jira_issue_type K (nolock) on j.jira_issue_type_dwkey = k.jira_issue_type_dwkey
WHERE dspr.sprint_id = @sprintID 


SELECT DISTINCT sprint_name, sprint_id, jira_issue_dwkey, jira_issue_key_cd, field_name, Occuring_DuringSprint, Addition_DuringSprint, Issue_Creation_DuringSprint, old_value_id, new_value_id
	INTO #CheckIt
FROM
	( 
		(	SELECT sprint_name
				, jira_issue_dwkey
				, jira_issue_key_cd
				, sprint_id
				, old_value_id
				, new_value_id
				, field_name
				, CASE WHEN source_created_dt_history between sprint_start_dt and sprint_end_dt
					THEN 
						CASE WHEN 
							(old_value_id is null or CHARINDEX(CAST(sprint_id AS varchar), old_value_id) = 0) AND CHARINDEX(cast(sprint_id as Varchar), new_value_id) <> 0
						THEN
							'TRUE' 
						ELSE
							'FALSE'
						END
					ELSE
						'FALSE'
					END Occuring_DuringSprint
				, CASE WHEN field_name = 'Sprint'
						THEN 
							CASE WHEN source_created_dt_history between sprint_start_dt and sprint_end_dt 
							THEN 
								CASE WHEN 
									(old_value_id is null OR CHARINDEX(CAST(sprint_id AS VARCHAR), old_value_id) = 0)				-- There isn't an original value OR the current sprint is not part of the source
								THEN
									CASE WHEN 
										CHARINDEX(CAST(sprint_id AS VARCHAR), new_value_id) <> 0											-- It's marked for the current sprint
									THEN
										'TRUE'
									END
								END
							END
					END 'Addition_DuringSprint'  
				, CASE WHEN issue_creation_dt between sprint_start_dt and sprint_end_dt THEN 'TRUE' END as 'Issue_Creation_DuringSprint'  
				FROM #sprint_history
		)	
		UNION 
		(
			select sprint_name
				, FJIS.jira_issue_dwkey
				, jira_issue_key_cd
				, FJIS.source_sprint_id
				, NULL	old_value_id
				, CAST(FJIS.source_sprint_id AS VARCHAR) new_value_id
				, 'Sprint_a' field_name
				, 'TRUE' Occuring_DuringSprint
				, 'TRUE' Addition_DuringSprint
				, 'TRUE' Issue_Creation_DuringSprint

				 from Dim_jira_issue DJI
				INNER JOIN fact_jira_issue_sprint FJIS on dji.jira_issue_dwkey = FJIS.jira_issue_dwkey
				INNER JOIN dim_jira_sprint DJS on FJIS.source_sprint_id = DJS.sprint_id
				LEFT OUTER JOIN fact_jira_issue_history FJIH 
					ON DJI.jira_issue_dwkey = FJIH.jira_issue_dwkey AND
						FJIH.field_name = 'Sprint' AND
						(FJIH.old_value_id IS NULL AND FJIH.new_value_id =FJIS.source_sprint_id)
				WHERE FJIS.source_sprint_id = @sprintID
					AND issue_creation_dt > sprint_start_dt
					AND FJIH.jira_issue_dwkey IS NULL
		) 
	) JIRA_Changes
WHERE sprint_id = @sprintID-- And jira_issue_dwkey = 155816
--	AND	(Addition_DuringSprint = 'TRUE'
--	OR		field_name <> 'Sprint')
/*	AND	( ( Issue_Creation_DuringSprint IS NOT NULL  AND Addition_DuringSprint IS NOT NULL)
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
*/	ORDER BY jira_issue_key_cd
	
SELECT * FROM #CheckIt WHERE field_name = 'Sprint' AND Occuring_DuringSprint = 'FALSE' and (old_value_id is null or CHARINDEX(CAST(sprint_id AS varchar), old_value_id) = 0) AND CHARINDEX(cast(sprint_id as Varchar), new_value_id) <> 0
SELECT * FROM #sprint_history WHERE field_name = 'Sprint' AND jira_issue_key_cd IN
('INFAOP-198'
,'INFUOP-815'
,'INFUOP-602'
,'INFUOP-1131'
,'INFUOP-1008'

)






DROP TABLE #sprint_history
DROP TABLE #CheckIt
