	SELECT FJI.jira_issue_dwkey 'DW Unique Issue ID'
		, DJI.jira_issue_key_cd 'Issue Key'
		, RTRIM(LTrim(SplitData)) 'Label'
		, 'Current Year' = ISNULL(Current_year, 
			CASE YEAR(source_created_dt)
			WHEN YEAR(CURRENT_TIMESTAMP)
				THEN
					'Yes'
				ELSE
					'No'
			END)
		, FJI.jira_issue_id 'JIRA Unique Issue ID'
	FROM
	(
		SELECT A.jira_issue_dwkey 'DW_Issue_Key',  
			Split.a.value('.', 'VARCHAR(100)') AS SplitData  
		FROM  
		(
			SELECT jira_issue_dwkey,  
				CAST ('<M>' + REPLACE(label_desc, ',', '</M><M>') + '</M>' AS XML) AS SplitData
				FROM dim_jira_issue  
		) AS A CROSS APPLY SplitData.nodes ('/M') AS Split(a) 
	) LT
	INNER JOIN 
		fact_jira_issue FJI 
	ON	
		FJI.jira_issue_dwkey = LT.DW_Issue_Key
	INNER JOIN
		dim_jira_issue DJI
	ON 
		DJI.jira_issue_dwkey = FJI.jira_issue_dwkey
	INNER JOIN
		dim_jira_proj DJP
	ON 
		FJI.jira_proj_dwkey = DJP.jira_proj_dwkey
	LEFT JOIN 
		(
		SELECT Distinct JIS.jira_issue_dwkey, 
			Current_year =
			CASE ISNULL(sprint_start_dt, 0)
					WHEN 0 
				THEN 'No'
				ELSE
					CASE YEAR(sprint_start_dt)
						WHEN YEAR(CURRENT_TIMESTAMP)
					THEN
						'Yes'
					ELSE
						'No'
					END
			END 
		FROM
			dim_jira_sprint S
		INNER JOIN fact_jira_issue_sprint JIS
			ON S.jira_sprint_dwkey = JIS.jira_sprint_dwkey
		) SP
	ON 
		SP.jira_issue_dwkey = FJI.jira_issue_dwkey			
	WHERE DJP.jira_proj_key_cd IN ('WI', 'NAS', 'STOR', 'INFAOP', 'INFUOP')
		and FJI.jira_issue_type_dwkey  <> 2
		and (resolution_short_desc is null OR resolution_short_desc = 'Done')
		and Current_year is null

