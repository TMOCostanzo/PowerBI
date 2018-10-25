use [BI_Semantics]

select top 5
	'SNOW'									Application_Name,
	a.number									Request_ID, 
	a.state									Request_State,
	c.assignment_group					Assignee_Group,
	c.priority								Request_Priority,
	b.cat_item,
	a.requested_for						,
	a.opened_by								Created_By,
	a.opened_at								REQ_Created_Date,
	a.closed_at 							REQ_Closed_Date,
	c.description							REQ_Description, 
	b.number 								RITM_number,
	b.state									RITM_State,
	b.opened_at								RIT_Opened_Date,
	b.closed_at								RIT_Closed_Date,
	c.state Source_State,
	CASE CHARINDEX('Closed', c.state)
		WHEN 0 
		THEN c.state
		ELSE SUBSTRING(c.state, CHARINDEX(  ' ', c.state)+1, 30)
	END										status_desc,
	c.closed_by,
	null										SLA,
	CASE WHEN charIndex('Close', b.state) = 0 -- Get the duration of the tasks, should equal the entire ticket open/close but 
												-- each task could be a different team
		THEN	CASE WHEN charindex('Close', a.state) = 0 
				THEN DATEDIFF(mi, b.opened_at, Getutcdate())
				ELSE DATEDIFF(mi, b.opened_at, a.closed_at)
				END 
		ELSE	DATEDIFF(mi, b.opened_at,b.closed_at) 
	END										Duration,
	c.number									Task_Number,
	c.opened_at 							Task_Opened_Date,
	c.closed_at 							Task_Closed_Date,
	c.assigned_to,
	b.made_sla								Made_SLA
FROM [ServiceNow_CMDB].[dbo].vw_sc_request a with (nolock) 
	LEFT JOIN servicenow_cmdb.dbo.vw_sc_req_item b with (nolock) on reverse(left(reverse(b.request_link), charindex('/', reverse(b.request_link)) -1)) = a.sys_id
--	LEFT JOIN servicenow_cmdb.dbo.vw_sc_task c with (nolock) on reverse(left(reverse(c.request_link), charindex('/', reverse(c.request_link)) -1)) = a.sys_id
--	LEFT JOIN servicenow_cmdb.dbo.vw_sc_task c ON b.number = c.request_item
	LEFT JOIN servicenow_cmdb.dbo.vw_sc_task c with (nolock) on reverse(left(reverse(c.parent_link), charindex('/', reverse(c.parent_link	)) -1)) = b.sys_id
	LEFT JOIN servicenow_cmdb.dbo.vw_sys_user d with (nolock) on d.manager = a.requested_for
WHERE
--			c.opened_at >= '1/1/' +  CAST(YEAR(CURRENT_TIMESTAMP) - 1 AS varchar)
			a.opened_at >= '10/1/2018'
	AND	c.assignment_group in ('EIT Inf Ops UNIX Support Tier 2', 'EIT-Unix-Tier 2') 
--		c.request = 'REQ0245948'
--		c.request = 'REQ0010445'
--		c.request = 'REQ0232275'
--and c.number = 'TASK0197962'
/*group by
	c.request, 
	c.assignment_group,
	c.number,
	a.requested_for,
	d.manager,
	a.opened_by,
	b.opened_by,
	a.opened_at,
	b.opened_at,
	b.closed_at,
	a.closed_at,
	b.cat_item,
	b.stage,
	b.approval,
	b.approval_history,
	c.assigned_to,
	c.assignment_group,
	c.request_item,
--	b.number,
	c.opened_at,
	c.closed_at,
	c.description, 
	c.cmdb_ci,
	c.short_description, 
	c.state, 
	c.priority,
	c.work_notes_list,
	c.closed_by,
	b.made_sla
	*/
	order by Request_ID

	--REQ0232275