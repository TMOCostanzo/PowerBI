
DECLARE @sprintID  int
SET @sprintID = 2079
/*
		Determine all of the histories records
*/

/*
		Determine any issues which were created during the sprint.
		EXCLUDE any issues which have a sprint history record because they should be caught in #sprint_history
*/

/*
		Merge the two into this new table which will make determinations if the changes occurred during the sprint,
			if they were added during the sprint, 
			if they were created during the sprint. 
*/


SELECT DISTINCT newID() history_ID, JS.jira_issue_dwkey 'DW Unique Issue ID', JS.*, AD.full_name Who_Changed_Full_Name
	,	CASE Added_DuringSprint 
		WHEN 'True' THEN
			DJI.story_points
		ELSE
			0
		END AS Added_StoryPoints
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
				, sprint_complete_dt
				, issue_creation_dt
				, CASE WHEN source_created_dt_history between sprint_start_dt and ISNULL(sprint_complete_dt , sprint_end_dt)
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
					END Occurred_DuringSprint
				,  CASE WHEN field_name = 'Sprint'
					THEN 
						CASE WHEN source_created_dt_history between sprint_start_dt and ISNULL(sprint_complete_dt , sprint_end_dt)
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
				,	CASE WHEN issue_creation_dt between sprint_start_dt and ISNULL( sprint_complete_dt , sprint_end_dt)
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
						INNER JOIN fact_jira_issue_history (nolock) FJIH ON FJI.jira_issue_dwkey = FJIH.jira_issue_dwkey
				-- Only are concerned with changes which occur once the item are in a sprint.
						INNER JOIN fact_jira_issue_sprint (nolock) B on FJI.jira_issue_dwkey = B.jira_issue_dwkey
						INNER JOIN dim_jira_sprint (nolock) DJS on B.source_sprint_id = DJS.sprint_id
				-- Limit to specific projects and only items which are either not completed or completed as Done, all other reasons are exclusionary
				WHERE jira_proj_key_cd  IN ('INFAOP','INFUOP') 
						AND isnull(DJI.resolution_short_desc, 'Done') = 'Done'
						AND DJS.sprint_status_desc = 'Active'
			) Sprint_History
		)	
		UNION 
		(
				SELECT sprint_name
					, FJIS.jira_issue_dwkey
					, jira_issue_key_cd
					, FJIS.source_sprint_id
					, NULL	old_value_id
					, CAST(FJIS.source_sprint_id AS VARCHAR) new_value_id
					, 'Sprint' field_name
					, issue_creation_dt source_created_dt_history
					, sprint_complete_dt
					, issue_creation_dt
					, 'TRUE' Occurred_DuringSprint
					, 'TRUE' Added_DuringSprint
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
					WHERE jira_proj_key_cd  IN ('INFAOP','INFUOP')
						AND 
							issue_creation_dt > sprint_start_dt
						AND FJIH.jira_issue_dwkey IS NULL
						AND DJS.sprint_status_desc = 'Active'
		) 
	) JS
INNER JOIN dim_jira_issue DJI
	ON DJI.jira_issue_dwkey = JS.jira_issue_dwkey
LEFT JOIN 
		nationaldw.[dbo].[dim_internal_contact] AD 
			ON JS.changed_by = AD.source_user_cd
--			Where field_name = 'Blocked Reason'
--			and (created_dt > '2018-07-11' or source_created_dt_history > '2018-07-11')

--where jira_issue_dwkey = 161384
--WHERE  (field_name = 'Sprint' AND Occurred_DuringSprint = 'TRUE' ) or field_name <> 'Sprint'
	-- OR 
	--(field_name = 'Sprint' )--AND Occurred_DuringSprint = 'TRUE')
ORDER BY jira_issue_key_cd

select @@ROWCOUNT

--SELECT * FROM #sprint_history where jira_issue_key_cd = 'INFUOP-1166'
--SELECT * FROM #CreatedIntoSprint where jira_issue_key_cd = 'INFUOP-1166'
--SELECT * FROM #sprint_history_decisions WHERE Issue_Creation_DuringSprint = 'TRUE'	
SELECT * FROM #CheckIt 
	WHERE 
	sprint_id = @sprintID and 
	--jira_issue_key_cd IN ('INFUOP-1216')
	--jira_issue_dwkey = 161384
 --WHERE Added_DuringSprint = 'TRUE' 
-- and 
 field_name LIKE 'Sprint%'
 --and jira_issue_key_cd = 'INFUOP-1232'
 and new_value_id like '%2079%'
 order by source_created_dt_history

 --and new_value_id = '1514' --where jira_issue_key_cd = 'INFUOP-1166'-- field_name = 'Sprint' and Addition_DuringSprint = 'TRUE' 
--ORDER BY jira_issue_key_cd
--WHERE field_name = 'Sprint' AND Occuring_DuringSprint = 'FALSE' and (old_value_id is null or CHARINDEX(CAST(sprint_id AS varchar), old_value_id) = 0) AND CHARINDEX(cast(sprint_id as Varchar), new_value_id) <> 0


DROP TABLE #CheckIt


select * from dim_jira_sprint where sprint_id = 2079
