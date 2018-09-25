select DJI.jira_version_dwkey, version_name, version_start_dt, version_release_dt, jira_issue_dwkey
FROM dim_jira_version DJI
	INNER JOIN fact_jira_issue_version FJIV
ON DJI.jira_version_dwkey = FJIV.jira_version_dwkey
where version_name  LIKE '%puppet%'


SELECT dji.jira_issue_key_cd, dji.summary, dji.story_points , dji.source_created_dt, dji.resolution_dt, jira_version_dwkey
FROM dim_jira_issue DJI
INNER JOIN 
	fact_jira_issue FJI
	ON FJI.jira_issue_dwkey = DJI.jira_issue_dwkey
LEFT JOIN (
		SELECT DJI.issue_desc Epic_Name
				, DJI.jira_issue_key_cd Epic_Key
				, FIL.src_jira_issue_dwkey Epic_DWK
				, FIL.tgt_jira_issue_dwkey Story_DWK  
		FROM 
			dim_jira_issue DJI
		INNER JOIN fact_issue_link FIL
			ON DJI.jira_issue_dwkey = FIL.src_jira_issue_dwkey
		WHERE
			issue_link_type_id = 10200 AND FIL.active_flg = 'Y' -- Link_type 10200 is epic->story
		) EPIC
	on Story_DWK = dji.jira_issue_dwkey
INNER JOIN 
	(
		SELECT jira_issue_dwkey, DJI.jira_version_dwkey
		FROM dim_jira_version DJI
			INNER JOIN fact_jira_issue_version FJIV
		ON DJI.jira_version_dwkey = FJIV.jira_version_dwkey
		where version_name  LIKE '%puppet%'	
	) VER
	ON (Epic_DWK = VER.jira_issue_dwkey OR DJI.jira_issue_dwkey = VER.jira_issue_dwkey)
WHERE jira_issue_type_dwkey > 2 -- not epic or subtask
ORDER BY source_created_dt

	/*
	select * from dim_jira_issue where jira_issue_dwkey =25515
	
	SELECT jira_version_dwkey, version_name, version_start_dt 
	FROM dim_jira_version 
	WHERE version_name  LIKE '%puppet%'
	
	SELECT jira_version_dwkey, jira_issue_dwkey 
	FROM fact_jira_issue_version 
	WHERE jira_version_dwkey = 3501
	
	SELECT jira_issue_dwkey, jira_issue_key_cd , issue_desc
	FROM dim_jira_issue 
	WHERE jira_issue_key_cd = 'INFUOP-802'
	
	SELECT  FJI.jira_issue_dwkey, DJI.jira_issue_key_cd, issue_desc , DJP.jira_proj_key_cd
	FROM fact_jira_issue FJI
	INNER JOIN 
		dim_jira_issue DJI
		ON DJI.jira_issue_dwkey = fji.jira_issue_dwkey
	INNER JOIN 
		dim_jira_proj DJP
		ON DJP.jira_proj_dwkey = FJI.jira_proj_dwkey
	WHERE FJI.jira_issue_dwkey = 25515
	*/