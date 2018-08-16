		SELECT 
				  FIL.tgt_jira_issue_dwkey Story_jira_issue_dwky  
				, FIL.src_jira_issue_dwkey Epic_jira_issue_dwky
				, DJIE.jira_issue_key_cd Epic_Key
				, DJIE.issue_desc Epic_Name
				, DJIS.jira_issue_key_cd Story_Key
				, DJIs.issue_desc Story_Summary
		INTO #Epic_View
		FROM 
			fact_issue_link FIL
		INNER JOIN dim_jira_issue DJIE
			ON DJIE.jira_issue_dwkey = FIL.src_jira_issue_dwkey
		INNER JOIN dim_jira_issue DJIS
			ON DJIS.jira_issue_dwkey = FIL.tgt_jira_issue_dwkey
		WHERE
			issue_link_type_id = 10200 AND FIL.active_flg = 'Y'

		SELECT DISTINCT EV.Epic_Key, EV.Story_Key
			, DJI.Summary
			, DJI.story_points
			, FJI.jira_issue_status
			, DJP.jira_proj_key_cd
		FROM dim_jira_issue DJI
		INNER JOIN fact_jira_issue FJI
			ON DJI.jira_issue_dwkey = FJI.jira_issue_dwkey
		INNER JOIN dim_jira_proj DJP
			ON DJP.jira_proj_dwkey =  FJI.jira_proj_dwkey
		INNER JOIN #Epic_View  EV
			ON EV.Story_jira_issue_dwky = DJI.jira_issue_dwkey
		WHERE DJP.jira_proj_key_cd = 'INFAOP'
			AND fji.jira_issue_type_dwkey <> 2

	DROP TABLE #Epic_View
		