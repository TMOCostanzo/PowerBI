
SELECT top 5 
	'PIER'										Application_Name, 
	CONVERT(VARCHAR(50), tt.tt_id)		Issue_ID, 
	grp.group_name								Assignee_Group, 
	inc.element_id								cat_item, 
	''												requested_for, 
	ad.fullname									Created_By, 
	tt.created_date							Created_Date,
	tt.created_date							Opened_Date,
	CASE 
		WHEN tt.resolved_date IS NULL 
			THEN tt.closed_date 
			ELSE tt.resolved_date 
	END											Closed_Date, 
	usr.full_name								assigned_to, 
	sym.Symptom_Desc							short_description,   -- <<<<< ADDED THIS
	sts.status_desc, 
	pri.priority_description				priority_desc, 
	tt.resolution_comments, 
	ad2.fullname Closed_By, 
	tt.ticket_sla								SLA,						-- <<<<< ADDED THIS
	CASE 
		WHEN sts.is_open = 0												-- <<<<< Changed this in case there is another closed status added	
			THEN Datediff(mi, tt.created_date, 
			CASE 
				WHEN tt.resolved_date IS NULL 
				THEN tt.closed_date 
				ELSE tt.resolved_date 
			END) 
		ELSE 
			Datediff(mi, tt.created_date, Getutcdate()) 
	END											Duration,
	null Made_SLA
FROM rpt_tm.v_trouble_ticket tt WITH (nolock) 
		INNER JOIN usergroup.v_gu_group grp WITH (nolock) 
			ON tt.assignee_group = grp.group_id 
		INNER JOIN troublemgmt.v_status sts WITH (nolock) 
			ON sts.status = tt.status 
		INNER JOIN troublemgmt.v_ref_priority pri WITH (nolock) 
			ON pri.priority_id = tt.priority_id 
		INNER JOIN usergroup.v_gu_user usr WITH (nolock) 
			ON tt.assignee = usr.user_code 
		INNER JOIN rpt_tm.v_incident inc WITH (nolock) 
			ON inc.tt_id = tt.tt_id 
		INNER JOIN [BI_Semantics].[TroubleMgmt].[v_Symptom] sym WITH (nolock)	-- <<<<< ADDED THIS
			ON sym.Symptom_Id = tt.Symptom_ID												-- <<<<< ADDED THIS
		LEFT OUTER JOIN adinfo.v_activedirectory_accounts ad WITH (nolock) 
			ON ad.loginname = tt.created_by 
		LEFT OUTER JOIN adinfo.v_activedirectory_accounts ad2 WITH (nolock) 
			ON ad2.loginname = tt.closed_by 
WHERE grp.group_name IN ( 'EIT Inf Ops Support UNIX Tier 2' ) 
		AND tt.created_date >= '1/1/' +  CAST(YEAR(CURRENT_TIMESTAMP) - 1 AS varchar)

UNION

select DISTINCT TOP 5
	'SNOW'										Application_Name,
	c.request									Issue_ID, 
	c.assignment_group						Assignee_Group,
	b.cat_item									cat_item,
	a.requested_for							requested_for,
	a.opened_by									Created_By, 
	a.sys_created_on							Created_Date,
	a.opened_at									Opened_Date,
	a.closed_at									Closed_Date,
	c.assigned_to								assigned_to,					 
	c.short_description						short_description, 
	CASE CHARINDEX('Closed', c.state)
		WHEN 0 
		THEN c.state
		ELSE SUBSTRING(c.state, CHARINDEX(  ' ', c.state)+1, 30)
	END											status_desc,
	c.priority									priority_desc,
	b.resolve_notes							resolution_comments,
	c.closed_by,
	null SLA,
	CASE WHEN a.closed_at = ''
		THEN	DATEDIFF(mi, a.opened_at, Getutcdate())
		ELSE	DATEDIFF(mi, a.opened_at,a.closed_at) 
	END Duration,
	b.made_sla Made_SLA
FROM 
	[ServiceNow_CMDB].[dbo].vw_sc_request a WITH (NoLock) 
	LEFT JOIN servicenow_cmdb.dbo.vw_sc_req_item b WITH (NoLock) 
		ON RIGHT(b.request_link, CHARINDEX('/', REVERSE(b.request_link))-1) = a.sys_id
	LEFT JOIN servicenow_cmdb.dbo.vw_sc_task c WITH (NoLock) 
		ON RIGHT(b.request_link, CHARINDEX('/', REVERSE(b.request_link))-1) = a.sys_id
WHERE
			c.opened_at >= '1/1/' +  CAST(YEAR(CURRENT_TIMESTAMP) - 1 AS varchar)
	AND	c.assignment_group in ('EIT Inf Ops UNIX Support Tier 2', 'EIT-Unix-Tier 2') 
GROUP BY
	c.request, 
	c.assignment_group,
	a.sys_created_on,
	a.requested_for,
	a.opened_by,
	a.opened_at,

	a.closed_at,
	b.cat_item,
	c.assigned_to,
	c.state,
	c.opened_at,
	c.closed_at,
	c.short_description, 
	c.priority,
	b.made_sla ,
	b.resolve_notes, 
	c.closed_by

