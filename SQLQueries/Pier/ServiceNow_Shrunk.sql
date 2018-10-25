select DISTINCT top 3000 
	'SNOW'										Application_Name,
	c.request									Issue_ID, 
	c.assignment_group						Assignee_Group,
	b.cat_item,
	a.requested_for,
	a.opened_by									Created_By, 
	a.sys_created_on							Created_Date,
	a.opened_at									Opened_Date,
	a.closed_at									Closed_Date,
	c.assigned_to, 
	c.short_description, 
	c.priority,
	c.state Source_State,
	CASE CHARINDEX('Closed', c.state)
		WHEN 0 
		THEN c.state
		ELSE SUBSTRING(c.state, CHARINDEX(  ' ', c.state)+1, 30)
	END status_desc,
	c.closed_by,
	null SLA,
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
/*GROUP BY
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
	c.closed_by*/



	select Distinct assignment_group from servicenow_cmdb.dbo.vw_sc_task where assignment_group like '%Unix%'