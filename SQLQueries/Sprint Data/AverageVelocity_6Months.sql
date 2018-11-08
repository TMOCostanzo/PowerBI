use jira_Datamart
Go

SELECT project, FLOOR(avg(sprint_velocity)) Average_Velocity, FLOOR(AVG(Sprint_Velocity_Issues)) Average_Issue_Velocity
FROM (
	SELECT Project, sprint_name, sum(story_points) Sprint_velocity, count(Project)  Sprint_velocity_Issues
	FROM (
		SELECT 
		djp.jira_proj_key_cd 	Project
			, story_points
			, sprint_name
/*	--	Audit Fields		
			,[jira_issue_sprint_dwkey]
			,DJI.[jira_issue_dwkey]
			, sprint_complete_dt
*/
	  FROM [JIRA_Datamart].[dbo].[fact_jira_issue_sprint] FJIS
	  INNER JOIN dim_jira_sprint DJS								-- Get the sprint name, start and end dates
	  ON FJIs.jira_sprint_dwkey = DJS.jira_sprint_dwkey
	  inner join dim_jira_issue DJI								-- Get story points and resolution date
	  on fjis.jira_issue_dwkey = DJI.jira_issue_dwkey
	  INNER JOIN fact_jira_Issue FJI								-- Get the project
	  ON FJis.jira_issue_dwkey = FJI.jira_issue_dwkey
	  INNER JOIN dim_jira_proj DJP
	  ON FJI.jira_proj_dwkey = DJP.jira_proj_dwkey
	  WHERE DJI.resolution_dt is not null and dji.resolution_short_desc = 'Done'
	  AND sprint_complete_dt > dateadd(mm,-6,getdate())
	  AND jira_proj_key_cd in ('STOR')
	  and resolution_dt between sprint_start_dt AND  sprint_complete_dt
	  and DJS.sprint_id <> 1494
	  ) StoriesInEachSprint
  GROUP BY project, sprint_name
  )  VelocityBySprint
GROUP BY project
