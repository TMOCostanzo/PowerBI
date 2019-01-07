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
            int x;
            if (Int32.TryParse(value, out x))
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

      public TimeRecord(string IssueState, int TimeInMinutes)
      {
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
