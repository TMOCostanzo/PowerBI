/*select DISTINCT TOP 10 source_sprint_id, field_name, count(field_name)
FROM fact_jira_issue_sprint FJIS
INNER JOIN fact_jira_issue FJI
on FJIS.jira_issue_dwkey = FJI.jira_issue_dwkey
INNER JOIN dim_jira_proj DJP
ON FJI.jira_proj_dwkey = DJP.jira_proj_dwkey
INNER JOIN fact_jira_issue_history FJIH
ON FJIH.jira_issue_dwkey = FJI.jira_issue_dwkey
WHERE jira_proj_key_cd IN ('INFAOP', 'INFUOP', 'WI', 'STOR', 'NAS')
GROUP BY source_sprint_id, field_name

*/

SELECT Final_list.jira_proj_key_cd, Final_list.source_sprint_id, Final_list.field_name, SUM(Final_list.Field_Items) Number_Of_Items 
	FROM 
		(
			SELECT jira_proj_key_cd, source_sprint_id, field_name, count(field_name) Field_Items
			FROM fact_jira_issue_sprint FJIS
			INNER JOIN fact_jira_issue FJI
				ON FJIS.jira_issue_dwkey = FJI.jira_issue_dwkey
			INNER JOIN dim_jira_proj DJP
				ON FJI.jira_proj_dwkey = DJP.jira_proj_dwkey
			INNER JOIN fact_jira_issue_history FJIH
				ON FJIH.jira_issue_dwkey = FJI.jira_issue_dwkey
			WHERE jira_proj_key_cd IN ('INFAOP', 'INFUOP', 'WI', 'STOR', 'NAS') AND
				field_name IN ('Blocked Reason', 'Description', 'Expected Unblocked Date', 'IssueType',  'Project',  'Sprint', 'Story Points', 'Summary')
			GROUP BY jira_proj_key_cd, source_sprint_id, field_name

		UNION 
			(
			SELECT DISTINCT   sprint_name, source_sprint_id, field_name, 'Generated' Who_Changed_Full_Name, jira_proj_key_cd, 'TRUE,FALSE' Occured_During_Sprint, Current_year, 0 Field_Items
			FROM 
				(	SELECT DISTINCT field_name FROM fact_jira_issue_history
					WHERE field_name IN ('Blocked Reason', 'Description', 'Expected Unblocked Date', 'IssueType',  'Project',  'Sprint', 'Story Points', 'Summary')
				)  History
			CROSS APPLY
				(	SELECT DISTINCT DJP.jira_proj_key_cd, source_sprint_id , sprint_name
						, Current_year =
						CASE YEAR(sprint_start_dt)
							WHEN YEAR(CURRENT_TIMESTAMP)
								THEN
									'Yes'
								ELSE
									'No'
							END
					FROM fact_jira_issue_sprint FJIS
					INNER JOIN dim_jira_sprint	DJS
						ON DJS.jira_sprint_dwkey = FJIS.jira_sprint_dwkey
					INNER JOIN fact_jira_issue FJI
						ON FJIS.jira_issue_dwkey = FJI.jira_issue_dwkey
					INNER JOIN dim_jira_proj DJP
						ON FJI.jira_proj_dwkey = DJP.jira_proj_dwkey
					WHERE jira_proj_key_cd IN ('INFAOP', 'INFUOP', 'WI', 'STOR', 'NAS')
				) Sprints
			)  --- End the list of fields 
		) Final_list -- Puts it into a single table
GROUP BY Final_list.jira_proj_key_cd, Final_list.source_sprint_id, Final_list.field_name
ORDER BY Final_list.jira_proj_key_cd, Final_list.source_sprint_id, Final_list.field_name

/*


	Temp Table Version

DROP TABLE #HasValue
DROP TABLE #FieldList

		SELECT jira_proj_key_cd, source_sprint_id, field_name, count(field_name) Field_Items
		INTO #HasValue
		FROM fact_jira_issue_sprint FJIS
		INNER JOIN fact_jira_issue FJI
			ON FJIS.jira_issue_dwkey = FJI.jira_issue_dwkey
		INNER JOIN dim_jira_proj DJP
			ON FJI.jira_proj_dwkey = DJP.jira_proj_dwkey
		INNER JOIN fact_jira_issue_history FJIH
			ON FJIH.jira_issue_dwkey = FJI.jira_issue_dwkey
		WHERE jira_proj_key_cd IN ('INFAOP', 'INFUOP', 'WI', 'STOR', 'NAS')
		GROUP BY jira_proj_key_cd, source_sprint_id, field_name

		SELECT DISTINCT jira_proj_key_cd, source_sprint_id, field_name, 0 Field_Items
		INTO #FieldList
		FROM 
			(	SELECT DISTINCT field_name FROM fact_jira_issue_history)  History
		CROSS APPLY
			(	SELECT DISTINCT DJP.jira_proj_key_cd, source_sprint_id  
				FROM fact_jira_issue_sprint FJIS
				INNER JOIN fact_jira_issue FJI
					ON FJIS.jira_issue_dwkey = FJI.jira_issue_dwkey
				INNER JOIN dim_jira_proj DJP
					ON FJI.jira_proj_dwkey = DJP.jira_proj_dwkey
				WHERE jira_proj_key_cd IN ('INFAOP', 'INFUOP', 'WI', 'STOR', 'NAS')
			) Sprints



SELECT Final_list.jira_proj_key_cd, Final_list.source_sprint_id, Final_list.field_name, SUM(Final_list.Field_Items) Number_Of_Items 
FROM (
	SELECT * FROM #HasValue
UNION (
	SELECT * FROM #FieldList )
	) Final_list
GROUP BY Final_list.jira_proj_key_cd, Final_list.source_sprint_id, Final_list.field_name
HAVING source_sprint_id = 867 and field_name = 'Additional Approvers'
ORDER BY Final_list.jira_proj_key_cd, Final_list.source_sprint_id, Final_list.field_name


*/





/*



Result Desired:

(Cross reference of all sprints and all statuses) [A]
Sprint ID	Status	Zero
2112			Sprint	0
2112			Status	0
3242			Sprint	0
3242			Status	0

Then you also have [B]

2112			Sprint	3
3242			Status	4

Result would be All records from [B] and all records from [A] WHERE sprintID and Status do not exist in [B], so:
2112			Sprint	3
2112			Status	0
3242			Sprint	0
3242			Status	4



*/
