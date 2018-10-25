use [BI_Semantics]

select 
'SNOW',
c.request, 
c.assignment_group,
c.number as Task_Number,
a.requested_for,
d.manager,
a.opened_by as REQ_Opened_User, -- in sc_request
b.opened_by as RIT_Opened_User, -- in sc_req_item
a.opened_at as REQ_Opened_Date,
b.opened_at as RIT_Opened_Date,
b.closed_at as RIT_Closed_Date,
a.closed_at as REQ_Closed_Date,
b.cat_item,
b.stage,
b.approval,
b.approval_history,
--d.u_vp,
c.assigned_to, -- in sc_task
c.assignment_group,
c.request_item as number,
c.opened_at as Task_Opened_Date,
c.closed_at as Task_Closed_Date,
c.description, 
c.cmdb_ci,
c.short_description, 
c.state, 
c.priority,
c.work_notes_list,
c.closed_by,
--datediff(mi, c.opened_at, c.work_end) Duration
datediff(mi, c.opened_at,c.closed_at) Duration
,1 as Row#
--c.request_item rit_numbe
--c.parent task_number
from [ServiceNow_CMDB].[dbo].vw_sc_request a with (nolock) 
left join servicenow_cmdb.dbo.vw_sc_req_item b with (nolock) on reverse(left(reverse(b.request_link), charindex('/', reverse(b.request_link)) -1)) = a.sys_id
--left join servicenow_cmdb.dbo.vw_sc_req_item b with (nolock) on b.request = a.sc_request_sys_id
left join servicenow_cmdb.dbo.vw_sc_task c with (nolock) on reverse(left(reverse(c.request_link), charindex('/', reverse(c.request_link)) -1)) = a.sys_id
left join servicenow_cmdb.dbo.vw_sys_user d with (nolock) on d.manager = a.requested_for
--left join servicenow_cmdb.dbo.vw_sc_request b with (nolock) on b.sc_request_sys_id = a.request
where c.opened_at >= '1/01/2017'
and c.assignment_group in ('EIT Inf Ops UNIX Support Tier 2', 'EIT-Unix-Tier 2') 
--and c.request = 'REQ0080120'
--and c.number = 'TASK0197962'
group by
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
c.opened_at,
c.closed_at,
c.description, 
c.cmdb_ci,
c.short_description, 
c.state, 
c.priority,
c.work_notes_list,
c.closed_by
