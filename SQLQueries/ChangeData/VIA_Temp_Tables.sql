
DECLARE @sprintID  int
SET @sprintID = 2112
/*
		Determine all of the histories records
*/
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
	,  FJIH.source_created_dt source_created_dt_history --ISNULL(FJIH.source_created_dt, issue_creation_dt) 
	,	new_value_id --ISNULL(FJIH.new_value_id, sprint_id) new_value_id
	,  CAST(FJIH.old_value_desc as VARCHAR) old_value_desc2
	,  CAST(FJIH.new_value_desc as VARCHAR) new_value_desc2
	, FJIH.history_author changed_by
into #sprint_history
FROM  fact_jira_issue FJI
		INNER JOIN dim_jira_issue DJI on DJI.jira_issue_dwkey = FJI.jira_issue_dwkey
		INNER JOIN fact_jira_issue_sprint (nolock) B on FJI.jira_issue_dwkey = B.jira_issue_dwkey
      INNER JOIN dim_jira_sprint (nolock) DJS on B.source_sprint_id = DJS.sprint_id
		INNER JOIN fact_jira_issue_history (nolock) FJIH ON FJI.jira_issue_dwkey = FJIH.jira_issue_dwkey
WHERE DJS.sprint_id = @sprintID 

/*
		Determine any issues which were created during the sprint.
		EXCLUDE any issues which have a sprint history record because they should be caught in #sprint_history
*/
SELECT sprint_name
	, FJIS.jira_issue_dwkey
	, jira_issue_key_cd
	, FJIS.source_sprint_id
	, NULL	old_value_id
	, issue_creation_dt source_created_dt_history
	, issue_creation_dt
	, CAST(FJIS.source_sprint_id AS VARCHAR) new_value_id
	, 'Sprint' field_name
	, 'TRUE' Occuring_DuringSprint
	, 'TRUE' Addition_DuringSprint
	, 'TRUE' Issue_Creation_DuringSprint
	, old_value_desc old_value_string
	, DJS.sprint_name new_value_string
	, DJI.issue_reporter changed_by
INTO #CreatedIntoSprint
FROM Dim_jira_issue DJI
	INNER JOIN fact_jira_issue_sprint FJIS on dji.jira_issue_dwkey = FJIS.jira_issue_dwkey
	INNER JOIN dim_jira_sprint DJS on FJIS.source_sprint_id = DJS.sprint_id
	LEFT OUTER JOIN fact_jira_issue_history FJIH 
		ON DJI.jira_issue_dwkey = FJIH.jira_issue_dwkey AND
			FJIH.field_name = 'Sprint' AND
			(FJIH.old_value_id IS NULL AND FJIH.new_value_id =FJIS.source_sprint_id) 
	WHERE FJIS.source_sprint_id = @sprintID
		AND issue_creation_dt > sprint_start_dt
		AND FJIH.jira_issue_dwkey IS NULL

/*
		Merge the two into this new table which will make determinations if the changes occurred during the sprint,
			if they were added during the sprint, 
			if they were created during the sprint. 
*/
SELECT sprint_name
	, jira_issue_dwkey
	, jira_issue_key_cd
	, sprint_id
	, old_value_id
	, new_value_id
	, field_name
	, source_created_dt_history
	, issue_creation_dt
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
	,  CASE WHEN field_name = 'Sprint'
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
		END Addition_DuringSprint  
	,	CASE WHEN issue_creation_dt between sprint_start_dt and sprint_end_dt 
			THEN 'TRUE' 
		END Issue_Creation_DuringSprint  
		, old_value_desc2 old_value_string
		, new_value_desc2 new_value_string
		, changed_by
INTO #sprint_history_decisions
FROM #sprint_history


SELECT DISTINCT newID() history_ID, * -- sprint_name, sprint_id, jira_issue_dwkey, jira_issue_key_cd, field_name, Occuring_DuringSprint, Addition_DuringSprint, Issue_Creation_DuringSprint, old_value_id, new_value_id
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
				, source_created_dt_history
				, issue_creation_dt
				, Occuring_DuringSprint
				, Addition_DuringSprint  
				, Issue_Creation_DuringSprint  
				, old_value_string
				, new_value_string
				, changed_by
				FROM #sprint_history_decisions
		)	
		UNION 
		(
			select sprint_name
				, jira_issue_dwkey
				, jira_issue_key_cd
				, source_sprint_id
				, NULL	old_value_id
				, CAST(source_sprint_id AS VARCHAR) new_value_id
				, 'SprintAAA' field_name
				, source_created_dt_history
				, issue_creation_dt
				, 'TRUE' Occuring_DuringSprint
				, 'TRUE' Addition_DuringSprint
				, 'TRUE' Issue_Creation_DuringSprint
				, old_value_string
				, new_value_string
				, changed_by
			FROM #CreatedIntoSprint
		) 
	) JIRA_Changes
WHERE sprint_id = @sprintID --And jira_issue_dwkey = 101602
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

/*
SELECT * FROM #sprint_history where jira_issue_key_cd = 'INFUOP-1166'
SELECT * FROM #CreatedIntoSprint where jira_issue_key_cd = 'INFUOP-1166'
SELECT * FROM #sprint_history_decisions WHERE Issue_Creation_DuringSprint = 'TRUE'	*/
SELECT * FROM #CheckIt where field_name like 'Sprint%' and Occuring_DuringSprint = 'TRUE'  --where jira_issue_key_cd = 'INFUOP-1166'-- field_name = 'Sprint' and Addition_DuringSprint = 'TRUE' 
ORDER BY jira_issue_key_cd
--WHERE field_name = 'Sprint' AND Occuring_DuringSprint = 'FALSE' and (old_value_id is null or CHARINDEX(CAST(sprint_id AS varchar), old_value_id) = 0) AND CHARINDEX(cast(sprint_id as Varchar), new_value_id) <> 0

DROP TABLE #sprint_history
DROP TABLE #sprint_history_decisions
DROP TABLE #CreatedIntoSprint
DROP TABLE #CheckIt

/*select FJIH.*, DJI.jira_issue_key_cd from 
	fact_jira_issue_history FJIH 
	INNER JOIN dim_jira_issue DJI 
		oN FJIh.jira_issue_dwkey = DJI.jira_issue_dwkey
	WHERE DJI.jira_issue_key_cd = 'INFUOP-605'
	and field_name = 'Sprint'


select * from fact_jira_issue where jira_issue_dwkey = 101602
*/	