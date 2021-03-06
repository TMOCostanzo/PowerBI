
	SELECT Distinct
		DJI.jira_issue_dwkey
		, S.sprint_id
		, JP.jira_proj_key_cd
		, DJI.summary
		, DJI.story_points
		, DJI.jira_issue_key_cd
		, issue_reporter
		, DJI.created_dt
		, resolution_short_desc
		, FJI.jira_issue_status
		, resolution_dt
		, 'https://jira.t-mobile.com/browse/' + DJI.jira_issue_key_cd JIRAURL
		, sprint_name_corrected =
		CASE 
			WHEN CHARINDEX('backlog', sprint_name) >0
				THEN 
					'Backlog'
				ELSE
					sprint_name
		END
		, sprint_start_dt, sprint_complete_dt, sprint_end_dt, 'None' sprint_goal, JP.jira_proj_dwkey, jira_proj_key_cd, jira_proj_name
		 , sprint_status = 
		 CASE ISNULL( sprint_start_dt, 0) 
			WHEN 0 THEN 
				CASE WHEN CHARINDEX('backlog', sprint_name) >  0
					THEN 
						'Backlog'
					ELSE 
						'Future'
					END 
			ELSE 
				CASE closed_indicator
				WHEN 1 
					THEN 'Closed'
				ELSE
					'Active'
				END
		END
	FROM
		dim_jira_issue DJI
		INNER JOIN fact_jira_issue FJI
			ON FJI.jira_issue_dwkey = DJI.jira_issue_dwkey 
		INNER JOIN dim_jira_proj JP
			ON JP.jira_proj_dwkey = FJI.jira_proj_dwkey
		LEFT JOIN ( SELECT number_value AS Story_Points,  jira_issue_dwkey 
					 FROM fact_jira_custom_field 
					 WHERE source_custom_field_name_id = 10005
					 ) SP
			ON SP.jira_issue_dwkey = DJI.jira_issue_dwkey 
		LEFT JOIN fact_jira_issue_sprint JIS
			ON FJI.jira_issue_dwkey = JIS.jira_issue_dwkey
		LEFT JOIN dim_jira_sprint S
			ON S.jira_sprint_dwkey = JIS.jira_sprint_dwkey
	WHERE
			--jira_proj_key_cd IN( 'INFAOP')
			DJI.jira_issue_key_cd = 'INFUOP-1182'
	

--	select * from dim_jira_issue where jira_issue_key_cd IN ('INFUOP-528', 'INFUOP-1182')
--	SELECT TOP 1 * FROM fact_jira_custom_field WHERE source_custom_field_name_id IN ( 10005, 10006) and jira_issue_dwkey = 56493
--	SELECT * From fact_jira_custom_field where source_custom_value_field_id BETWEEN 10000 and 10010
--	SELECT * FROM dim_jira_issue where jira_issue_dwkey = 83686

select DISTINCT DJI.jira_issue_key_cd JIRA_ID
	, DJI.summary JIRA_Title
	, JIT.issue_type Issue_Type
	, FIL.Epic_ID 
	, Fil.Epic_Name 
	, FIL.Epic_DWK
	FROM dim_jira_issue DJI
	INNER JOIN fact_jira_issue FJI ON
		FJI.jira_issue_dwkey = DJI.jira_issue_dwkey
	INNER JOIN dim_jira_issue_type JIT ON 
		JIT.jira_issue_type_dwkey = FJI.jira_issue_type_dwkey
		LEFT JOIN (
		SELECT DJI.issue_desc Epic_ID
				, DJI.jira_issue_key_cd Epic_Name
				, FIL.tgt_jira_issue_dwkey Story_DWK  
				, FIL.src_jira_issue_dwkey Epic_DWK
		FROM 
			dim_jira_issue DJI
		INNER JOIN fact_issue_link FIL
			ON DJI.jira_issue_dwkey = FIL.src_jira_issue_dwkey
		WHERE
			issue_link_type_desc = 'Epic-Story Link'
		) FIL
		ON FIL.Story_DWK = DJI.jira_issue_dwkey

	WHERE DJI.jira_issue_dwkey = 160724



SELECT * from fact_issue_link where (tgt_jira_issue_dwkey = 56493 or src_jira_issue_dwkey = 56493) and  issue_link_type_id <> 10200 -- 10200 = epic-story link

-- Shows no records exist for any issues.
SELECT * from fact_jira_custom_field WHERE source_custom_field_name_id = 21004

