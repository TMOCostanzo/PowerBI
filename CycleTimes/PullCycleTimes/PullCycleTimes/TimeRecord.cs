using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PullCycleTimes
{
   /*public class TimeRecordIssue
   {
      private int dwKey;
      readonly List<TimeRecord> records = new List<TimeRecord>();

      public int JIRA_Issue_dwkey
      {
         get
         {
            return dwKey;
         }


         set
         {
            dwKey = value;
         }
      }

      public List<TimeRecord> StateTotals
      {
         get
         {
            return records;
         }
      }

      public TimeRecordIssue(int DW_IssueKey, string Issue_State, int Issue_Time_InState)
      {
         dwKey = DW_IssueKey;

      }
   }
   */
   public class TimeRecord
   {
      private int totalTime = 0; // Time in Minutes
      private string issueState = string.Empty; // State
      private int JIRADWKey = 0;
      private DateTime issue_CreateDate = DateTime.UtcNow;

      public int JIRA_DW_Key
      {
         get { return JIRADWKey; }
         set { JIRADWKey = value; }
      }

      public DateTime Issue_Creation_Date
      {
         get { return issue_CreateDate; }
         set { issue_CreateDate = value; }
      }

      public int TotalTime
      {
         get
         {
            return totalTime;
         }

         set
         {
            totalTime = value;
         }
      }

      public string  TotalTimeString
      { get
         { return totalTime.ToString(); }
         set

         {
            if (Int32.TryParse(value, out int x))
               totalTime = Int32.Parse(value);
            else
               totalTime = 0;
         }
   

      }

      public string IssueState
      {
         get
         {
            return issueState;
         }

         set
         {
            issueState = value;
         }
      }

      public TimeRecord(int DWKey, DateTime createDate, string IssueState, int TimeInMinutes)
      {
         JIRADWKey = DWKey;
         issue_CreateDate = createDate;
         totalTime = TimeInMinutes;
         issueState = IssueState;
      }

      public TimeRecord()
      {
      }

      public TimeRecord(string IssueState)
      {
         totalTime = 0;
         issueState = IssueState;
      }
   }



}
