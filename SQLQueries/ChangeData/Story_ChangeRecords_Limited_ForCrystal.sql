
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


SELECT DISTINCT newID() history_ID, JS.jira_issue_dwkey 'DW Unique Issue ID',  jira_proj_key_cd,  jira_issue_key_cd, source_created_dt_history,  issue_creation_dt, field_name, new_value_string, AD.full_name Who_Changed_Full_Name
INTO #CheckIt
FROM
		(	SELECT jira_issue_dwkey
				, jira_issue_key_cd
				, old_value_id
				, new_value_id
				, field_name
				, source_created_dt_history
				, issue_creation_dt
				, jira_proj_key_cd
				, old_value_desc2 old_value_string
				, new_value_desc2  new_value_string
				, changed_by
			FROM 
			(
				SELECT 	FJI.jira_issue_dwkey
					,	DJI.jira_issue_key_cd
					,  DJI.issue_creation_dt
					,  FJIH.old_value_id
					,	new_value_id 
					,  FJIH.field_name
					,  FJIH.source_created_dt source_created_dt_history 
					,  jira_proj_key_cd
					,  CAST(FJIH.old_value_desc as VARCHAR) old_value_desc2
					,  CAST(FJIH.new_value_desc as VARCHAR) new_value_desc2
					, FJIH.history_author changed_by
				FROM  fact_jira_issue FJI
						INNER JOIN dim_jira_issue DJI on DJI.jira_issue_dwkey = FJI.jira_issue_dwkey
						INNER JOIN dim_jira_proj DJP on DJP.jira_proj_dwkey = FJI.jira_proj_dwkey
						INNER JOIN fact_jira_issue_history (nolock) FJIH ON FJI.jira_issue_dwkey = FJIH.jira_issue_dwkey
				-- Only are concerned with changes which occur once the item are in a sprint.
				--		INNER JOIN fact_jira_issue_sprint (nolock) B on FJI.jira_issue_dwkey = B.jira_issue_dwkey
				--		INNER JOIN dim_jira_sprint (nolock) DJS on B.source_sprint_id = DJS.sprint_id
				-- Limit to specific projects and only items which are either not completed or completed as Done, all other reasons are exclusionary
				WHERE jira_proj_key_cd  IN ('CF') AND isnull(DJI.resolution_short_desc, 'Done') = 'Done' and story_points <> 0
			) Sprint_History
		) JS
LEFT JOIN 
		nationaldw.[dbo].[dim_internal_contact] AD 
			ON changed_by = AD.source_user_cd
--			Where field_name = 'Blocked Reason'
--			and (created_dt > '2018-07-11' or source_created_dt_history > '2018-07-11')

--where jira_issue_dwkey = 161384
--WHERE  (field_name = 'Sprint' AND Occurred_DuringSprint = 'TRUE' ) or field_name <> 'Sprint'
	-- OR 
	--(field_name = 'Sprint' )--AND Occurred_DuringSprint = 'TRUE')
--ORDER BY jira_issue_key_cd


--SELECT * FROM #sprint_history where jira_issue_key_cd = 'INFUOP-1166'
--SELECT * FROM #CreatedIntoSprint where jira_issue_key_cd = 'INFUOP-1166'
--SELECT * FROM #sprint_history_decisions WHERE Issue_Creation_DuringSprint = 'TRUE'	
SELECT * FROM #CheckIt 
	WHERE /*
	[DW Unique Issue ID] IN (
	102156,
102838,
103380,
103819,
103911,
107066,
109250,
109289,
110555,
118220,
120669,
120740,
120744,
122650,
124776,
126763,
126844,
127283,
136779,
148221,
149241,
149250,
161354,
161355,
165028,
168037,
176364,
181370,
181999,
186585



	)*/
	new_value_string = 'In Progress' OR field_name = 'Story Points' --in ('Status', 'Story Points')
	order by [DW Unique Issue ID], source_created_dt_history

	/*
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
*/