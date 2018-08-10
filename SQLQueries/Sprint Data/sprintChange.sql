DECLARE @sprintID  varchar(20)

SET @sprintID = '1878'

DROP TABLE #addition
DROP TABLE #sprint_history

SELECT 
CASE WHEN field_name = 'Sprint' THEN new_value_desc end as 'Sprint'
,	A.source_created_dt
,	DJI.jira_issue_key_cd
,	A.jira_issue_dwkey
,	C.sprint_start_dt
,	C.sprint_end_dt
,	sprint_name
,  C.sprint_id
,  a.old_value_id
,  a.new_value_id
into #sprint_history
FROM fact_jira_issue_history (nolock) A 
													INNER JOIN fact_jira_issue FJI ON FJI.jira_issue_dwkey = a.jira_issue_dwkey AND  FJI.jira_proj_dwkey = 317
													INNER JOIN dim_jira_issue DJI on DJI.jira_issue_dwkey = FJI.jira_issue_dwkey

LEFT OUTER JOIN fact_jira_issue_sprint (nolock) B on A.jira_issue_dwkey = B.jira_issue_dwkey
                                                                   LEFT OUTER JOIN dim_jira_sprint (nolock) C on B.source_sprint_id = C.sprint_id
                                                                   LEFT OUTER JOIN fact_jira_issue (nolock) D on A.jira_issue_dwkey = D.jira_issue_dwkey
WHERE field_name in ('Sprint') and CASE WHEN field_name = 'Sprint' THEN new_value_desc end is not null
order by a.source_created_dt asc

SELECT sprint_name,jira_issue_dwkey
	, jira_issue_key_cd
	, sprint_id
	, old_value_id
	, new_value_id
	, source_created_dt
	, sprint_start_dt
	, sprint_end_dt
	, CASE WHEN source_created_dt between sprint_start_dt and sprint_end_dt THEN 'Added During Sprint' Else 'Not added during Sprint' END as 'Sprint Addition'  into #addition FROM #sprint_history

SELECT DISTINCT sprint_name, jira_issue_key_cd, jira_issue_dwkey, sprint_id
	, old_value_id, new_value_id
	, [Sprint Addition]
	, source_created_dt, sprint_start_dt,sprint_start_dt,  sprint_start_dt, sprint_end_dt FROM #addition
WHERE charindex('2017',sprint_name ) = 0 
	and sprint_id = 1878
	AND jira_issue_key_cd = 'INFAOP-445'
	AND new_value_id like '%1878%'
	ORDER BY jira_issue_key_cd

DROP TABLE #addition
DROP TABLE #sprint_history

/*	AND (old_value_id NOT LIKE '%' +  CAST(sprint_id AS varchar(200)) + '%' OR old_value_id IS NULL)
	AND jira_issue_dwkey IN (114346
, 121189
, 133147
, 133149
, 140476

	AND source_created_dt --BETWEEN sprint_start_dt and sprint_end_dt
			between convert(varchar(25),sprint_start_dt,101) and convert(varchar(25),sprint_end_dt,101)
)*/
/*
SELECT * FROM #sprint_history where jira_issue_dwkey IN (111006, 115794)
--AND source_created_dt between sprint_start_dt and sprint_end_dt
and sprint_id = 1878
*/


/*
select * from dim_jira_sprint
select CONVERT(datetime, sprint_start_dt, 101), * from v_dim_jira_sprint
WHERE sprint_id = 1878

SELECT 1 
WHERE '1368, 1695, 1744' LIKE '%'+ @sprintID & '%'


select sprint_id
	, FJIH.jira_issue_dwkey
	, field_name
	, old_value_id
	, new_value_id
	, FJIH.created_dt
	, is_it = CASE WHEN FJIH.created_dt between sprint_start_dt and sprint_end_dt THEN 'Add' ELSE 'Huh' END

FROM fact_jira_issue_history FJIH
INNER JOIN fact_jira_issue_sprint FJIS ON 
	FJIS.jira_issue_dwkey = FJIH.jira_issue_dwkey
INNER JOIN dim_jira_sprint DJS 
	ON DJS.jira_sprint_dwkey = FJIS.jira_sprint_dwkey
WHERE field_name = 'Sprint'
	AND FJIH.jira_issue_dwkey IN (111006, 115794)
	AND sprint_id= 1878
	AND FJIH.created_dt > DJS.sprint_start_dt
	AND FJIH.created_dt < DJS.sprint_end_dt
	AND old_value_id NOT LIKE '%1878%'


	*/