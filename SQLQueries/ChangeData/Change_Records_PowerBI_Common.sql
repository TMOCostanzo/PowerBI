
DECLARE @sprintID  int
SET @sprintID = 1878

SELECT * FROM dim_jira_sprint where sprint_id = @sprintID

/*
		Determine all of the histories records
*/

/*
		Determine any issues which were created during the sprint.
		EXCLUDE any issues which have a sprint history record because they should be caught in #sprint_history
		NB If the sprint isn't complete, anything added since the start date is a change, this is why CURRENT_TIMESTAMP is used when null
*/

/*
		Merge the two into this new table which will make determinations if the changes occurred during the sprint,
			if they were added during the sprint, 
			if they were created during the sprint. 
*/


SELECT DISTINCT newID() history_ID, jira_issue_dwkey 'DW Unique Issue ID', JS.*, AD.full_name Who_Changed_Full_Name
INTO #CheckIt
FROM
	( 
		(	SELECT sprint_name
				, jira_issue_dwkey
				, jira_issue_key_cd
				, sprint_id
				, sprint_start_dt
				, old_value_id
				, new_value_id
				, field_name
				, source_created_dt_history
				, issue_creation_dt
				, CASE WHEN source_created_dt_history between sprint_start_dt and  ISNULL(sprint_complete_dt , CURRENT_TIMESTAMP)
					THEN 
						CASE WHEN field_name = 'Sprint'
							THEN 
								CASE WHEN 
									(old_value_id is null or CHARINDEX(CAST(sprint_id AS varchar), old_value_id) = 0) AND CHARINDEX(cast(sprint_id as Varchar), new_value_id) <> 0
								THEN
									'TRUE' 
								ELSE
									'FALSE'
								END
							ELSE
								'TRUE'
						END 
					ELSE
						'FALSE'
					END Occurred_During_Sprint
				,  CASE WHEN field_name = 'Sprint'
					THEN 
						CASE WHEN source_created_dt_history between sprint_start_dt and ISNULL(sprint_complete_dt , CURRENT_TIMESTAMP)  -- JIRA bases changes upon the sprint_complete_dt. If the sprint hasn't closed, it's still running so use current date.
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
					END Added_DuringSprint
				,  NULL Removed_DuringSprint
				,	CASE WHEN issue_creation_dt between sprint_start_dt and  ISNULL(sprint_complete_dt , CURRENT_TIMESTAMP) 
						THEN 'TRUE' 
					END Issue_Created_DuringSprint
				,	jira_proj_key_cd  
				, old_value_desc2 old_value_string
				, new_value_desc2  new_value_string
				, changed_by
				, Current_year =
					CASE YEAR(sprint_start_dt)
						WHEN YEAR(CURRENT_TIMESTAMP)
							THEN
								'Yes'
							ELSE
								'No'
						END
			FROM 
			(
				SELECT 	sprint_name
					,	FJI.jira_issue_dwkey
					,	DJI.jira_issue_key_cd
					,  sprint_id
					,	sprint_start_dt
					,	sprint_end_dt
					,  sprint_complete_dt
					,  DJI.issue_creation_dt
					,  FJIH.old_value_id
					,	new_value_id 
					,  FJIH.field_name
					,  FJIH.source_created_dt source_created_dt_history 
					,  jira_proj_key_cd
					,  CAST(FJIH.old_value_desc as VARCHAR) old_value_desc2
					,  CAST(FJIH.new_value_desc as VARCHAR) new_value_desc2
					, FJIH.history_author changed_by
					, Current_year =
						CASE YEAR(sprint_start_dt)
							WHEN YEAR(CURRENT_TIMESTAMP)
								THEN
									'Yes'
								ELSE
									'No'
							END
				FROM  fact_jira_issue FJI
						INNER JOIN dim_jira_issue DJI on DJI.jira_issue_dwkey = FJI.jira_issue_dwkey
						INNER JOIN dim_jira_proj DJP on DJP.jira_proj_dwkey = FJI.jira_proj_dwkey
						INNER JOIN fact_jira_issue_sprint (nolock) B on FJI.jira_issue_dwkey = B.jira_issue_dwkey
						INNER JOIN dim_jira_sprint (nolock) DJS on B.source_sprint_id = DJS.sprint_id
						INNER JOIN fact_jira_issue_history (nolock) FJIH ON FJI.jira_issue_dwkey = FJIH.jira_issue_dwkey
				WHERE jira_proj_key_cd  IN ('INFAOP', 'INFUOP')
				AND FJIH.field_name IN (	
					'Blocked Reason', 'Description', 'Expected Unblocked Date', 'IssueType', 'Priority', 'Project', 'Rank', 'Sprint', 'Story Points', 'Summary'
					)
					AND FJI.jira_issue_type_dwkey <> 2
			) Sprint_History
		)	
		UNION 
		(
				SELECT sprint_name
					, FJIS.jira_issue_dwkey
					, jira_issue_key_cd
					, FJIS.source_sprint_id
					, sprint_start_dt
					, NULL	old_value_id
					, CAST(FJIS.source_sprint_id AS VARCHAR) new_value_id
					, 'Sprint' field_name
					, issue_creation_dt source_created_dt_history
					, issue_creation_dt
					, 'TRUE' Occurred_DuringSprint
					, 'TRUE' Added_DuringSprint
					, NULL Removed_DuringSprint
					, 'TRUE' Issue_Created_DuringSprint
					, DJP.jira_proj_key_cd
					, old_value_desc old_value_string
					, DJS.sprint_name new_value_string
					, DJI.issue_reporter changed_by
					, Current_year =
						CASE YEAR(sprint_start_dt)
							WHEN YEAR(CURRENT_TIMESTAMP)
								THEN
									'Yes'
								ELSE
									'No'
							END
				FROM Dim_jira_issue DJI
					INNER JOIN fact_jira_issue FJI 
						ON DJI.jira_issue_dwkey = FJI.jira_issue_dwkey
					INNER JOIN dim_jira_proj DJP 
						ON DJP.jira_proj_dwkey = FJI.jira_proj_dwkey
					INNER JOIN fact_jira_issue_sprint FJIS on dji.jira_issue_dwkey = FJIS.jira_issue_dwkey
					INNER JOIN dim_jira_sprint DJS on FJIS.source_sprint_id = DJS.sprint_id
					LEFT OUTER JOIN fact_jira_issue_history FJIH 
						ON DJI.jira_issue_dwkey = FJIH.jira_issue_dwkey AND
							FJIH.field_name = 'Sprint' AND
							((FJIH.old_value_id IS NULL OR CHARINDEX(CAST(FJIS.source_sprint_id as varchar), FJIH.old_value_id ) =0) AND  CHaRINDEX(CAST(FJIS.source_sprint_id as varchar), FJIH.new_value_id) > 0 )
					WHERE jira_proj_key_cd  IN ('INFAOP', 'INFUOP')
						AND 
							issue_creation_dt > sprint_start_dt
						AND FJIH.jira_issue_dwkey IS NULL
						AND FJI.jira_issue_type_dwkey <> 2
		) 
	) JS
INNER JOIN 
		nationaldw.[dbo].[dim_internal_contact] AD 
			ON JS.changed_by = AD.source_user_cd
--where jira_issue_dwkey = 161384
WHERE source_created_dt_history > sprint_start_dt
ORDER BY jira_issue_key_cd


--SELECT * FROM #sprint_history where jira_issue_key_cd = 'INFUOP-1166'
--SELECT * FROM #CreatedIntoSprint where jira_issue_key_cd = 'INFUOP-1166'
--SELECT * FROM #sprint_history_decisions WHERE Issue_Creation_DuringSprint = 'TRUE'	
SELECT * FROM #CheckIt WHERE 
	--sprint_id = @sprintID --and 
	jira_issue_key_cd = 'INFUOP-921'
	--jira_issue_dwkey IN ( 105740)
	--and field_name = 'Sprint'
	--AND sprint_id = 2059

	--@sprintID = sprint_id AND (Added_DuringSprint = 'TRUE' OR Removed_DuringSprint = 'TRUE' )

 --and field_name LIKE 'Sprint%' --where jira_issue_key_cd = 'INFUOP-1166'-- field_name = 'Sprint' and Addition_DuringSprint = 'TRUE' 

ORDER BY jira_issue_key_cd, source_created_dt_history
--WHERE field_name = 'Sprint' AND Occuring_DuringSprint = 'FALSE' and (old_value_id is null or CHARINDEX(CAST(sprint_id AS varchar), old_value_id) = 0) AND CHARINDEX(cast(sprint_id as Varchar), new_value_id) <> 0

DROP TABLE #CheckIt

--select * from dim_jira_sprint where sprint_id = 2185
/*

SELECT * From dim_jira_issue where jira_issue_key_cd = 'INFUOP-921'

SELECT * FROM fact_jira_issue_history where jira_issue_dwkey = 121615 and field_name = 'Sprint' 
ORDER BY source_created_dt

*/
SELECT *, CHARINDEX(CAST(old_value_id AS VARCHAR), @sprintID), CHARINDEX(CAST(new_value_id AS VARCHAR), @sprintID)  FROM fact_jira_issue_history FJIH
WHERE jira_issue_dwkey = 121615
AND field_name = 'SPrint'
--AND source_created_dt BETWEEN '2018-06-05 20:36:19' AND '2018-06-19 15:53:00'
ORDER BY source_created_dt




