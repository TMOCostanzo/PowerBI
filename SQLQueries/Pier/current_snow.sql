use [BI_Semantics]

DROP TABLE #SNOW
Go

select DISTINCT
	'SNOW'									Application_Name,
	request.number							Request_ID, 
	request.state							Request_State,
	req_item_task.assignment_group	Assignee_Group,
	req_item_task.priority				Request_Priority,
	req_item.cat_item,
	request.requested_for,						
	request.opened_by						Created_By,
	request.opened_at						REQ_Created_Date,
	request.closed_at 					REQ_Closed_Date,
	req_item_task.description			REQ_Description, 
	req_item.number 						RITM_number,
	CASE CHARINDEX('Skipped', req_item_task.state)
		WHEN 0
		THEN 
				CASE CHARINDEX('Closed', request.state)
				WHEN 0 
					THEN req_item.state
					ELSE 'Closed Complete' 
				END
		ELSE 'Closed Skipped'
	END										RITM_State,
	req_item.opened_at					RIT_Opened_Date,
	req_item.closed_at					RIT_Closed_Date,
	req_item_task.state					Source_State,
	CASE CHARINDEX('Closed', req_item_task.state)
		WHEN 0 
		THEN req_item_task.state
		ELSE SUBSTRING(req_item_task.state, CHARINDEX(  ' ', req_item_task.state)+1, 30)
	END										status_desc,
	req_item_task.closed_by,
	null										SLA,
	CASE WHEN charIndex('Close', req_item.state) = 0 -- Get the duration of the tasks, should equal the entire ticket open/close but 
												-- each task could be a different team
		THEN	CASE WHEN charindex('Close', request.state) = 0 
				THEN DATEDIFF(mi, req_item.opened_at, Getutcdate())
				ELSE DATEDIFF(mi, req_item.opened_at, request.closed_at)
				END 
		ELSE	DATEDIFF(mi, req_item.opened_at,req_item.closed_at) 
	END										RTIM_Duration,
	req_item_task.number									Task_Number,
	req_item_task.opened_at 							Task_Opened_Date,
	req_item_task.closed_at 							Task_Closed_Date,
	CASE CHARINDEX('Closed', req_item_task.state)
		WHEN 0
		THEN null
		ELSE DATEDIFF(mi, req_item_task.opened_at, req_item_task.closed_at)
	END										TASK_Duration,
	req_item_task.assigned_to,
	req_item.made_sla								Made_SLA,
	CASE charIndex('Close', request.state)
		WHEN 0
			THEN
				CASE charIndex('Close', req_item.state)
				WHEN 0
					THEN 
						CASE charIndex('Close', req_item_task.state)
						WHEN 0
							THEN CONCAT('*', req_item_task.state, '*')
							ELSE 'Closed'
						END
					ELSE 'Closed'
				END
			ELSE 'Closed'
		END												Task_Status,
	CONCAT('https://tmus.service-now.com/sc_request.do?sys_id=', request.sys_id) TicketURL
INTO #SNOW
FROM [ServiceNow_CMDB].[dbo].vw_sc_request request with (nolock) 
	LEFT JOIN servicenow_cmdb.dbo.vw_sc_req_item req_item with (nolock) on reverse(left(reverse(req_item.request_link), charindex('/', reverse(req_item.request_link)) -1)) = request.sys_id
	LEFT JOIN servicenow_cmdb.dbo.vw_sc_task req_item_task with (nolock) on reverse(left(reverse(req_item_task.parent_link), charindex('/', reverse(req_item_task.parent_link	)) -1)) = req_item.sys_id
	LEFT JOIN servicenow_cmdb.dbo.vw_sys_user req_manager with (nolock) on req_manager.manager = request.requested_for
WHERE
			CONVERT(DATETIME, request.opened_at,101) >= '1/1/' +  CAST(YEAR(CURRENT_TIMESTAMP) - 1 AS varchar)
	AND	req_item_task.assignment_group in (
		  'EIT Inf Ops Support UNIX Tier2'
		, 'EIT-Unix-Tier 2'
		, 'EIT-Storage Tier'
		, 'EIT-Storage-Tier2'
		, 'EIT Inf Ops Support Storage Tier 2'
		, 'EIT-NAS'
		, 'ENG-SAN'
		, 'EIT Infra Storage'
		, 'EIT Infra Storage Cap Add'
		)  
	--a.number = 'REQ0264867'
	--and	(CHARINDEX('Close', req_item_task.state) = 0) and a.state in ('Open', 'In Progress')
	order by Request_ID

--select count(request_ID) from #snow
--select * from #snow
--select * from ServiceNow_CMDB..vw_sc_request where number = 'REQ0264867'
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

SELECT DISTINCT (State) FROM servicenow_cmdb.dbo.vw_sc_req_item


select distinct RITM_State FROM #SNOW

--select * from #SNOW where RITM_State Not IN ('Closed Complete', 'Closed Incomplete', 'Closed Skipped') and status_group = 'Closed'

select distinct RITM_State, Status_group 
FROM #SNOW


select distinct(state) from servicenow_cmdb.dbo.vw_sc_task

Select  * from [ServiceNow_CMDB].[dbo].vw_sc_request where number= 'REQ0219883'
select * FROM [ServiceNow_CMDB].[dbo].vw_sc_req_item where number = 'RITM0350365'

*/

select COUNT(RITM_STATE)
FROM #SNow


