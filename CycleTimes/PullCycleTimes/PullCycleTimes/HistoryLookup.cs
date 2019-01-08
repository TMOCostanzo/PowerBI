using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace PullCycleTimes
{
   public partial class HistoryLookup : Form
   {
      public HistoryLookup()
      {
         InitializeComponent();
      }

      private void LookupDWKey_Click(object sender, EventArgs e)
      {
         if (String.IsNullOrEmpty(JIRAKeyValue.UserValue) == false)
         {

            using (SqlConnection connection = new SqlConnection("Data Source=PSQLODS02,53000;Initial Catalog=JIRA_Datamart;Integrated Security=True"))
            {
               try
               {
                  if (connection.State == ConnectionState.Closed)
                     connection.Open();
               }
               catch (SqlException sqlException)
               {
                  MessageBox.Show("SQL Exception: " + sqlException.ToString());
                  return;
               }

               try
               {
                  string SQLQuery = "SELECT jira_issue_dwkey FROM dim_jira_issue WHERE jira_issue_key_cd = '" + JIRAKeyValue.UserValue + "'";
                  SqlDataAdapter JIRADataAdapter = new SqlDataAdapter(SQLQuery, connection);

                  DataSet customerOrders = new DataSet();

                  JIRADataAdapter.Fill(customerOrders, "Customers");

                  foreach (DataRow dr in customerOrders.Tables["Customers"].Rows)
                  {
                     string value = dr["jira_issue_dwkey"].ToString();
                     DWKeyValue.UserValue = value;
                  }
               }
               catch (SqlException sqlException)
               {
                  MessageBox.Show("SQL Exception: " + sqlException.ToString());
                  return;
               }
               finally
               {
                  if (connection.State == ConnectionState.Open)
                     connection.Close();
               }
            }
         }
         else
            MessageBox.Show("A JIRA Key is required", "Missing Data", MessageBoxButtons.OK, MessageBoxIcon.Stop);
      }

      private void LookupHistory_Click(object sender, EventArgs e)
      {
         List<TimeRecord> timings = new List<TimeRecord>();
         string ExecuteSQLStatement = string.Empty;

         if (String.IsNullOrEmpty(DWKeyValue.UserValue) == false)
         {

            using (SqlConnection connection = new SqlConnection("Data Source=PSQLODS02,53000;Initial Catalog=JIRA_Datamart;Integrated Security=True"))
            {
               try
               {
                  if (connection.State == ConnectionState.Closed)
                     connection.Open();
               }
               catch (SqlException sqlException)
               {
                  MessageBox.Show("SQL Exception (Open Connection): " + sqlException.ToString());
                  return;
               }

               try
               {
                  DataSet DSHistoryRecords = PullData(connection);
                  HistoryBox.Items.Clear();
                  string value;
                  string lastStatus = "To Do";
                  DateTime Issue_Creation_Date = (DateTime)DSHistoryRecords.Tables["Histories"].Rows[0]["Issue Creation Date"];
                  DateTime lastDateTime = Issue_Creation_Date;
                  int JIRA_DWKey = 0;
                  string JIRA_DWkey_Source = DSHistoryRecords.Tables["Histories"].Rows[0]["jira_issue_dwkey"].ToString();
                  int Overall_Minutes = 0;
                  Boolean SprintFound = false;
                  DateTime recordTime;

                  if (Int32.TryParse(JIRA_DWkey_Source, out int x))
                     JIRA_DWKey = Int32.Parse(JIRA_DWkey_Source);

                  HistoryBox.Items.Add(lastDateTime.ToString() + ":creation:To Do");
                  foreach (DataRow dr in DSHistoryRecords.Tables["Histories"].Rows)
                  {
                     recordTime = (DateTime)dr["History Creation Date"];
                     if (dr["field_name"].ToString() == "Sprint")
                     {
                        if (SprintFound == false)           // If we have found a sprint record, then this starts the clock as it's the first valid sprint
                        {
                           SprintFound = true;              // Prevents any other sprint records from being used
                           lastDateTime = recordTime;       // Resets the clock
                           HistoryBox.Items.Add(lastDateTime.ToString() + ":sprint: START THE CLOCK");
                        }
                     }
                     else
                     {
                        if (dr["Old_Value_Desc"].ToString() != dr["New_Value_Desc"].ToString())
                        {
                           // record the time here
                           //int minutes = (int)Math.Round()
                           TimeSpan span = recordTime.Subtract(lastDateTime);
                           int minutes = (int)Math.Round(span.TotalMinutes, 0);

                           Overall_Minutes += minutes;
                           value = dr["History Creation Date"] + ":" + dr["Field_Name"].ToString() + ":" + dr["New_Value_Desc"].ToString();
                           value += String.Format("--> {0} : {1} : {2}", lastDateTime.ToString(), recordTime.ToString(), minutes.ToString());

                           int id = timings.FindIndex(itemSearch => itemSearch.IssueState == lastStatus);
                           if (id == -1)
                              timings.Add(new TimeRecord(JIRA_DWKey, Issue_Creation_Date, lastStatus, minutes));
                           else
                           {
                              minutes += timings[id].TotalTime;
                              timings[id].TotalTime = minutes;
                           }
                           HistoryBox.Items.Add(value);
                           lastStatus = dr["New_Value_Desc"].ToString();
                           lastDateTime = recordTime;
                        }
                     }
                  }

                  if (DSHistoryRecords.Tables[0].Rows[0]["IsOpen"].ToString() == "Open")
                  {
                     recordTime = DateTime.Now;
                     TimeSpan span = recordTime.Subtract(lastDateTime);
                     int minutes = (int)Math.Round(span.TotalMinutes, 0);
                     Overall_Minutes += minutes;
                     HistoryBox.Items.Add(recordTime + ": Blocked : Open");
                  }
                  timings.Add(new TimeRecord(JIRA_DWKey, Issue_Creation_Date, "Total", Overall_Minutes));

                  HistoryBox.Items.Add("");
                  foreach (TimeRecord timingRecords in timings)
                     HistoryBox.Items.Add(timingRecords.IssueState + ":" + timingRecords.TotalTime + " minutes");

               }
               catch (SqlException sqlException)
               {
                  MessageBox.Show("SQL Exception: " + sqlException.ToString());
                  return;
               }
               catch (Exception ex)
               {
                  MessageBox.Show("General Exception: " + ex.ToString());
                  return;
               }
               finally
               {
                  if (connection.State == ConnectionState.Open)
                     connection.Close();
               }
            }

            using (SqlConnection connection = new SqlConnection("Data Source=WABOTHLP0793434\\SQLEXPRESS;Initial Catalog=CycleTime;Integrated Security=True"))
            {
               ExecuteSQLStatement = CreateSQLExecutionString(timings, ExecuteSQLStatement);

               try
               {
                  if (connection.State == ConnectionState.Closed)
                     connection.Open();
               }
               catch (SqlException sqlException)
               {
                  MessageBox.Show("SQL Exception (Open): " + sqlException.ToString());
                  return;
               }

               try
               {
                  ExecuteSQLRecords(ExecuteSQLStatement, connection);
               }
               catch (SqlException sqlException)
               {
                  MessageBox.Show("SQL Exception: " + sqlException.ToString());
                  return;
               }
               catch (Exception ex)
               {
                  MessageBox.Show("General Exception: " + ex.ToString());
                  return;
               }
               finally
               {
                  if (connection.State == ConnectionState.Open)
                     connection.Close();
               }
            }
         }
         else
            MessageBox.Show("A DW Key is required", "Missing Data", MessageBoxButtons.OK, MessageBoxIcon.Stop);

      }

      private DataSet PullData(SqlConnection connection)
      {

         try
         {

            string SQLQuery = "SELECT * FROM (" +
               "SELECT FJIH.jira_issue_dwkey ,field_name, old_value_id, old_value_desc , new_value_id , new_value_desc " +
               ", DJI.source_created_dt 'Issue Creation Date' " +
               ", FJIH.source_created_dt 'History Creation Date' " +
               ", sprint_status_desc " +
               ", CASE WHEN field_name = 'Sprint' " +
               "  THEN " +
               "     CASE WHEN sprint_status_desc = 'Active' OR sprint_status_desc = 'Completed' " +
               "         THEN " +
               "   			'Keep' " +
               "			ELSE" +
               "				'Skip' " +
               "      END " +
               "  ELSE " +
               "      'Keep' " +
               "  END Record_Status " +
               ", CASE ISNULL(source_resolution_id, 1) " +
               "       WHEN 1 " +
               "          THEN 'Open' " +
               "          ELSE 'Closed' " +
               "  END 'IsOpen'  " +
               "FROM JIRA_Datamart.dbo.fact_jira_issue_history FJIH " +
               "LEFT JOIN dim_jira_sprint DJS ON FJIH.new_value_id = CONVERT(varchar(50), DJS.sprint_id) " +
               "INNER JOIN dim_jira_issue DJI ON FJIH.jira_issue_dwkey = DJI.jira_issue_dwkey " +
               "WHERE Field_Name IN ('Sprint', 'Status') AND FJIH.jira_issue_dwkey = " + DWKeyValue.UserValue.ToString() +
               ") Results " +
               "WHERE Record_Status = 'Keep' " +
               "ORDER BY jira_issue_dwkey, [History Creation Date] ";

            SqlDataAdapter JIRADataAdapter = new SqlDataAdapter(SQLQuery, connection);

            DataSet DSHistoryRecords = new DataSet();

            JIRADataAdapter.Fill(DSHistoryRecords, "Histories");
            return DSHistoryRecords;
         }

         catch (Exception ex)
         {
            throw ex;
         }

      }

      private string CreateSQLExecutionString(List<TimeRecord> timeRecords, string currentSQLStatement)
      {
         string SQLStatement = string.Empty;
         bool FirstInsert = false;
         if (currentSQLStatement == string.Empty)
         {
            SQLStatement = "INSERT INTO dbo.UpdateData (Issue_Create_Month, dwKey, IssueState, Time_hr) VALUES ";
            FirstInsert = true;
         }
         else
            SQLStatement = currentSQLStatement;

         foreach (TimeRecord value in timeRecords)
         {
            if (FirstInsert == false)
            {
               SQLStatement += ", ";
            }
            else
            {
               FirstInsert = false;
            }
            SQLStatement += string.Format("('{0}-{1}-01', {2}, '{3}', {4})", value.Issue_Creation_Date.Year, value.Issue_Creation_Date.Month, value.JIRA_DW_Key, value.IssueState, value.TotalTime);

         }

         return SQLStatement;

      }

      private bool ExecuteSQLRecords(string insertSQLStatement, SqlConnection connection )
      {

         bool returnValue = false;
         
         try
         {
            string SQLStatement = "DELETE FROM dbo.UpdateData";
            SqlCommand sqlCommand = connection.CreateCommand();
            using (sqlCommand)
            {
               sqlCommand.CommandText = SQLStatement;
               sqlCommand.CommandType = CommandType.Text;
               sqlCommand.ExecuteNonQuery();
            }

            using (sqlCommand)
            {
               sqlCommand.CommandText = insertSQLStatement;
               sqlCommand.CommandType = CommandType.Text;
               sqlCommand.ExecuteNonQuery();
            }

            returnValue = true;
         }
         catch (Exception ex)
         {
            MessageBox.Show("General Exception: " + ex.Message.ToString());
         }
         finally
         {
            if (connection.State == ConnectionState.Open)
               connection.Close();
         }

         return returnValue;
      }
   }
}
