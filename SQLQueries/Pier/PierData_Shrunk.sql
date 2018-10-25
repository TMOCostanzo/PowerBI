	SELECT 
		'PIER'										Application_Name, 
		CONVERT(VARCHAR(50), tt.tt_id)		Task_Number, 
		grp.group_name								Assignee_Group, 
		inc.element_id								cat_item, 
		''												requested_for, 
		ad.fullname									Created_By, 
		tt.created_date							Task_Created_Date,
		tt.created_date							Task_Opened_Date,
		CASE 
			WHEN tt.resolved_date IS NULL 
				THEN tt.closed_date 
				ELSE tt.resolved_date 
		END											Task_Closed_Date, 
		ad3.fullname								assigned_to, 
		sym.Symptom_Desc							short_description,   -- <<<<< ADDED THIS
		sts.status_desc, 
		pri.priority_description				Task_priority, 
		tt.resolution_comments, 
		ad2.fullname								Closed_By, 
		tt.ticket_sla								Ticket_SLA,						-- <<<<< ADDED THIS
		CASE 
		WHEN sts.is_open = 0													-- <<<<< Changed this in case there is another closed status added	
				THEN Datediff(mi, tt.created_date, 
				CASE 
					WHEN tt.resolved_date IS NULL 
					THEN tt.closed_date 
					ELSE tt.resolved_date 
				END) 
			ELSE 
				Datediff(mi, tt.created_date, Getutcdate()) 
		END											Task_Duration,
		tt.tt_description							Long_Description ,
		null Made_SLA
	FROM BI_Semantics.rpt_tm.v_trouble_ticket tt WITH (nolock) 
			INNER JOIN BI_Semantics.usergroup.v_gu_group grp WITH (nolock) 
				ON tt.assignee_group = grp.group_id 
			INNER JOIN BI_Semantics.troublemgmt.v_status sts WITH (nolock) 
				ON sts.status = tt.status 
			INNER JOIN BI_Semantics.troublemgmt.v_ref_priority pri WITH (nolock) 
				ON pri.priority_id = tt.priority_id 
			INNER JOIN BI_Semantics.rpt_tm.v_incident inc WITH (nolock) 
				ON inc.tt_id = tt.tt_id 
			INNER JOIN BI_Semantics.troublemgmt.[v_Symptom] sym WITH (nolock)	-- <<<<< ADDED THIS
				ON sym.Symptom_Id = tt.Symptom_ID												-- <<<<< ADDED THIS
			LEFT OUTER JOIN BI_Semantics.adinfo.v_activedirectory_accounts ad WITH (nolock) 
				ON ad.loginname = tt.created_by 
			LEFT OUTER JOIN BI_Semantics.adinfo.v_activedirectory_accounts ad2 WITH (nolock) 
				ON ad2.loginname = tt.closed_by 
			LEFT OUTER JOIN BI_Semantics.adinfo.v_activedirectory_accounts ad3 WITH (nolock) 
				ON ad2.loginname = tt.assignee 
	WHERE			grp.group_name IN ( 'EIT Inf Ops Support UNIX Tier 2', 'EIT Inf Ops Support UNIX' ) 
			AND	tt.created_date >= '1/1/' +  CAST(YEAR(CURRENT_TIMESTAMP) - 1 AS varchar)

