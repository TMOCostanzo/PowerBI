

	-- missing assignee
SELECT DISTINCT 
		  FJI.source_jira_issue_id 'JIRA Unique Issue ID'
		, FJI.jira_issue_dwkey 'DW Unique Issue ID'
		, jira_issue_key_cd 'Epic Key'
		, summary 'Epic Summary'
		, jira_proj_key_cd 'Project Key'
		, InitLink.Initiative_Link 'Initiative Link' 
		, label_desc 'Labels'
		, 'https://jira.t-mobile.com/browse/' + DJI.jira_issue_key_cd Epic_URL
		, 'https://jira.t-mobile.com/rest/api/2/issue/' + CAST(FJI.source_jira_issue_id AS VARCHAR(10)) Rest_URL
		, EpicStatus.[Epic Closed]
		, DJIT.issue_type 'Issue Type'
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
/*	LEFT JOIN (
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
*/
	LEFT JOIN (
			SELECT 'Epic Closed' = 
				CASE custom_field_derived_value 
					WHEN 'Done'
						THEN 'Y'
					ELSE 
						'N'
				END
			, jira_issue_dwkey
			FROM fact_jira_custom_field
			WHERE source_custom_field_name_id = 10007
		) EpicStatus
		ON EpicStatus.jira_issue_dwkey = FJI.jira_issue_dwkey
	LEFT JOIN (
			SELECT string_value Initiative_Link 
			, jira_issue_dwkey
			FROM fact_jira_custom_field
			WHERE source_custom_field_name_id = 11200
		) InitLink
		ON InitLink.jira_issue_dwkey = FJI.jira_issue_dwkey	
		WHERE --DJP.jira_proj_key_cd IN ('WI', 'NAS', 'STOR', 'INFAOP', 'INFUOP')
		DJP.jira_proj_key_cd IN ('CF')
		AND DJIT.issue_type = 'Epic'
		AND label_desc = 'PCF-SSH'
		AND FJI.jira_issue_dwkey = 177637