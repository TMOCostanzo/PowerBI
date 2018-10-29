use [BI_Semantics]

DROP TABLE #SNOW
Go

select DISTINCT
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
	c.state									Source_State,
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
	END										RTIM_Duration,
	c.number									Task_Number,
	c.opened_at 							Task_Opened_Date,
	c.closed_at 							Task_Closed_Date,
	CASE CHARINDEX('Closed', c.state)
		WHEN 0
		THEN null
		ELSE DATEDIFF(mi, c.opened_at, c.closed_at)
	END										TASK_Duration,
	c.assigned_to,
	b.made_sla								Made_SLA,
	CONCAT('https://tmus.service-now.com/sc_request.do?sys_id=', a.sys_id) TicketURL
INTO #SNOW
FROM [ServiceNow_CMDB].[dbo].vw_sc_request a with (nolock) 
	LEFT JOIN servicenow_cmdb.dbo.vw_sc_req_item b with (nolock) on reverse(left(reverse(b.request_link), charindex('/', reverse(b.request_link)) -1)) = a.sys_id
	LEFT JOIN servicenow_cmdb.dbo.vw_sc_task c with (nolock) on reverse(left(reverse(c.parent_link), charindex('/', reverse(c.parent_link	)) -1)) = b.sys_id
	LEFT JOIN servicenow_cmdb.dbo.vw_sys_user d with (nolock) on d.manager = a.requested_for
WHERE
			CONVERT(DATETIME, a.opened_at,101) >= '1/1/' +  CAST(YEAR(CURRENT_TIMESTAMP) - 1 AS varchar)
	AND	--c.assignment_group in (
		--'EIT Inf Ops Support UNIX Tier2', 'EIT-Unix-Tier 2'
		--'EIT-Storage Tier', 'EIT-Storage-Tier2',
		--'EIT Inf Ops Support Storage Tier 2',
--		'EIT-NAS', 'ENG-SAN'
		--'EIT Infra Storage', 'EIT Infra Storage Cap Add'
--		)  
	a.number = 'REQ0264867'
	--and	(CHARINDEX('Close', c.state) = 0) and a.state in ('Open', 'In Progress')
	order by Request_ID

select count(request_ID) from #snow
select * from #snow
select * from ServiceNow_CMDB..vw_sc_request where number = 'REQ0264867'
/*select Round(DateDiff(day,Task_Opened_Date,CURRENT_TIMESTAMP),0) TaskAge, *
FROM #SNOW
where assigned_to= 'Mammar Rashid'
*/
--where assigned_to like '%Chr%'



/*

•	EIT-Storage Tier 1
•	EIT-Storage-Tier2
•	EIT Inf Ops Support Storage Tier 2
•	EIT-NAS
•	ENG-SAN 
•	EIT Infra Storage
•	EIT Infra Storage Cap Add (still used for requests for ESX storage) 

*/