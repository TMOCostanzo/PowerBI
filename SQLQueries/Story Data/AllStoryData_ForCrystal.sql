USE JIRA_Datamart
GO

SELECT DISTINCT FJI.jira_issue_dwkey 'DW Unique Issue ID'
		, jira_issue_key_cd 'Issue Key'
		,'https://jira.t-mobile.com/browse/' + DJI.jira_issue_key_cd Issue_URL 
		, summary
		, DJIT.issue_type 'Issue Type'
		, DIC_R.full_name 'Reporter'
		, DJI.created_by_id 'Created By ID', DJI.source_created_dt 'Issue Created'
		, jira_proj_key_cd 'Project Key'
		, story_points 'Story Points'
		, label_desc 'Labels'
		, Epic_Key 'Epic Key'
		, DJI.resolution_dt 'Resolution Date'
		, 'Assignee' = CASE assignee_datawarehousekey  
			WHEN -9999 
				THEN 'Unassigned'
			ELSE
				DIC_A.full_name
			END
		, FJI.jira_issue_status 'Status'
		, InAnySprint = CASE ISNULL(FJIS.jira_issue_dwkey, 1) WHEN 1 THEN 'no' ELSE 'yes' END
		, jira_issue_key_cd + '-' + summary CombinedSummary
		, Epic_Name
		, DJI.resolution_short_desc
		, 'https://jira.t-mobile.com/rest/api/2/issue/' + CAST(FJI.source_jira_issue_id AS VARCHAR(10)) Rest_URL
		, FJI.source_jira_issue_id 'JIRA Unique Issue ID'
		, DIC_R.source_user_cd 'Reporter_NTID'
		, DIC_A.source_user_cd 'Assignee_NTID'

FROM fact_jira_issue FJI
	INNER JOIN dim_jira_issue DJI ON
		DJI.jira_issue_dwkey = FJI.jira_issue_dwkey
	INNER JOIN dim_jira_proj DJP ON
		FJI.jira_proj_dwkey = DJP.jira_proj_dwkey
	INNER JOIN dim_jira_issue_type DJIT
		ON DJIT.jira_issue_type_dwkey = FJI.jira_issue_type_dwkey
	LEFT JOIN nationaldw.dbo.dim_internal_contact DIC_R
		ON DIC_R.internal_contact_dwkey = FJI.reporter_dwkey
	LEFT JOIN nationaldw.dbo.dim_internal_contact DIC_A 
		ON DIC_A.internal_contact_dwkey = assignee_datawarehousekey
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
			issue_link_type_id = 10200 AND FIL.active_flg = 'Y'
		) EPIC
		ON EPIC.Story_DWK = DJI.jira_issue_dwkey

	WHERE DJP.jira_proj_key_cd IN ( --'WI', 'NAS', 'STOR', 
			'CF')
		AND FJI.jira_issue_type_dwkey <> 2
--      AND FJI.jira_issue_dwkey <> 135644
--      AND FJI.jira_issue_dwkey <> -9999
		and (ISNULL(DJI.resolution_dt, '2018-01-01') >= '2018-01-01')
		and FJI.jira_issue_status NOT IN ( 'Declined', 'Cancelled', 'Pending')
		and story_points >0

