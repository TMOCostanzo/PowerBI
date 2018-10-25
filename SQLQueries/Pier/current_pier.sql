
SELECT 'PIER' Application, 
	CONVERT(VARCHAR(50), tt.tt_id)		Task_Number, 
	grp.group_name								Assignee_Group, 
	requested_by, 
	''												manager, 
	ad.fullname									Created_By, 
	''												RIT_Opened_User, 
	tt.created_date							Task_Created_Date, 
	''												RIT_Opened_Date, 
	''												RIT_Closed_Date, 
	CASE 
		WHEN tt.resolved_date IS NULL 
			THEN tt.closed_date 
			ELSE tt.resolved_date 
	END											Task_Closed_Date, 
	inc.element_id								Config_Item, 
	''												stage,
	''												approval, 
	''												approval_history, 
	-- VP value 
	usr.full_name								         Assignee, 
	grp.group_name								Assignee_Group, 
	''												number, 
	tt.created_date							Task_Opened_Date, 
	tt.tt_description, 
	''												cmdb_ci, 
	sym.Symptom_Desc							short_description, 
	sts.status_desc, 
	pri.priority_description, 
	tt.resolution_comments, 
	ad2.fullname Closed_By, 
	tt.ticket_sla								SLA,
	CASE 
		WHEN tt.status IN ( 2, 4, 8 )	
			THEN Datediff(mi, tt.created_date, 
			CASE 
				WHEN tt.resolved_date IS NULL 
				THEN tt.closed_date 
				ELSE tt.resolved_date 
			END) 
		ELSE 
			Datediff(mi, tt.created_date, Getutcdate()) 
		END										Duration, 
		Row_number() 
			OVER( 
				partition BY tt.created_date 
			ORDER BY tt.created_date DESC) AS Row 
FROM BI_Semantics.rpt_tm.v_trouble_ticket tt WITH (nolock) 
		INNER JOIN BI_Semantics.usergroup.v_gu_group grp WITH (nolock) 
			ON tt.assignee_group = grp.group_id 
		INNER JOIN BI_Semantics.troublemgmt.v_status sts WITH (nolock) 
			ON sts.status = tt.status 
		INNER JOIN BI_Semantics.troublemgmt.v_ref_priority pri WITH (nolock) 
			ON pri.priority_id = tt.priority_id 
		INNER JOIN BI_Semantics.usergroup.v_gu_user usr WITH (nolock) 
			ON tt.assignee = usr.user_code 
		INNER JOIN BI_Semantics.rpt_tm.v_incident inc WITH (nolock) 
			ON inc.tt_id = tt.tt_id 
		INNER JOIN BI_Semantics.TroubleMgmt.v_Symptom sym WITH (nolock)
			ON sym.Symptom_Id = tt.Symptom_ID
		LEFT OUTER JOIN BI_Semantics.adinfo.v_activedirectory_accounts ad WITH (nolock) 
			ON ad.loginname = tt.created_by 
		LEFT OUTER JOIN BI_Semantics.adinfo.v_activedirectory_accounts ad2 WITH (nolock) 
			ON ad2.loginname = tt.closed_by 
WHERE grp.group_name IN ( 'EIT Inf Ops Support UNIX Tier 2' ) 
		AND tt.created_date >= '1/1/2017' 
		and sym.Symptom_Desc = 'Degraded Service'