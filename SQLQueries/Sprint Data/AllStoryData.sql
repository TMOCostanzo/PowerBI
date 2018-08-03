

	-- missing assignee
SELECT DISTINCT FJI.jira_issue_dwkey 'DW Unique Issue ID'
		, jira_issue_key_cd 'Issue Key'
		,'https://jira.t-mobile.com/browse/' + DJI.jira_issue_key_cd Issue_URL
		, summary
		,DJIT.issue_type 'Issue Type'
		,issue_reporter 'Reporter'
		, DJI.created_by_id 'Created By ID', DJI.source_created_dt 'Issue Created'
		, jira_proj_key_cd 'Project Key'
		,story_points 'Story Points'
		,label_desc 'Labels'
		,Epic_Key 'Epic Key'
		, DJI.resolution_dt 'Resolution Date'
		,assignee_datawarehousekey  'Assignee'
		,FJI.jira_issue_status 'Status'
		,InAnySprint = CASE ISNULL(FJIS.jira_issue_dwkey, 1) WHEN 1 THEN 'no' ELSE 'yes' END
		,jira_issue_key_cd + '-' + summary CombinedSummary
		, Epic_Name
		,DJI.resolution_short_desc
		,version_name
		, 'https://jira.t-mobile.com/rest/api/2/issue/' + CAST(FJI.source_jira_issue_id AS VARCHAR(10)) Rest_URL
		, FJI.source_jira_issue_id 'JIRA Unique Issue ID'

FROM fact_jira_issue FJI
	INNER JOIN dim_jira_issue DJI ON
		DJI.jira_issue_dwkey = FJI.jira_issue_dwkey
	INNER JOIN dim_jira_proj DJP ON
		FJI.jira_proj_dwkey = DJP.jira_proj_dwkey
	INNER JOIN dim_jira_issue_type DJIT
		ON DJIT.jira_issue_type_dwkey = FJI.jira_issue_type_dwkey
	LEFT JOIN fact_jira_issue_sprint FJIS ON
		FJIS.jira_issue_dwkey = FJI.jira_issue_dwkey
	LEFT JOIN (
		SELECT version_name, jira_issue_dwkey 
		FROM dim_jira_version DJV
		INNER JOIN fact_jira_issue_version JIV ON
			JIV.jira_version_dwkey = DJV.jira_version_dwkey
		) VER ON
		VER.jira_issue_dwkey = FJI.jira_issue_dwkey
	LEFT JOIN (
		SELECT DJI.issue_desc Epic_Name
				, DJI.jira_issue_key_cd Epic_Key
				, FIL.tgt_jira_issue_dwkey Story_DWK  
				, FIL.src_jira_issue_dwkey Epic_DWK
		FROM 
			dim_jira_issue DJI
		INNER JOIN fact_issue_link FIL
			ON DJI.jira_issue_dwkey = FIL.src_jira_issue_dwkey
		WHERE
			issue_link_type_id = 10200
		) EPIC
		ON EPIC.Story_DWK = DJI.jira_issue_dwkey

	WHERE DJP.jira_proj_key_cd IN ('WI', 'NAS', 'STOR', 'INFAOP', 'INFUOP')
		AND FJI.jira_issue_type_dwkey = 9
		--AND FJI.jira_issue_dwkey = 33812
		-- AND DJI.jira_issue_key_cd = 'INFUOP-217'


	/*

	

SELECT * FROM (
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
		, DJIT.issue_type
		, 'https://jira.t-mobile.com/browse/' + DJI.jira_issue_key_cd JIRAURL
		, sprint_name_corrected =
		CASE 
			WHEN CHARINDEX('backlog', sprint_name) >0
				THEN 
					'Backlog'
				ELSE
					sprint_name
		END
		, sprint_start_dt, sprint_complete_dt, sprint_end_dt, 'None' sprint_goal,  jira_proj_name
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
		INNER JOIN dim_jira_issue_type DJIT
			ON DJIT.jira_issue_type_dwkey = FJI.jira_issue_type_dwkey
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
			jira_proj_key_cd IN( 'INFAOP', 'INFUOP')
		and 
			sprint_Id is not null and sprint_id <> 867	
	) Combined
	
	WHERE
			sprint_status != 'Backlog'

			*/