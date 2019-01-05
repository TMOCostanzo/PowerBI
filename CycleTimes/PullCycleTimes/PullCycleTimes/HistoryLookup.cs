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

                  JIRADataAdapter.Fill(customerOrders,  "Customers");

                  foreach(DataRow dr in customerOrders.Tables["Customers"].Rows)
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
            MessageBox.Show("A JIRA Key is required",  "Missing Data", MessageBoxButtons.OK, MessageBoxIcon.Stop);
      }

      private void LookupHistory_Click(object sender, EventArgs e)
      {
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
                  MessageBox.Show("SQL Exception: " + sqlException.ToString());
                  return;
               }

               try
               {
                  string SQLQuery = 
                  "SELECT jira_issue_dwkey ,field_name, old_value_id, old_value_desc , new_value_id , new_value_desc "  +
                      ", source_created_dt, sprint_status_desc " +
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
                      "FROM JIRA_Datamart.dbo.fact_jira_issue_history FJIH " +
                      "LEFT JOIN dim_jira_sprint DJS ON FJIH.new_value_id = CONVERT(varchar(50),DJS.sprint_id )" +
                      "WHERE Field_Name IN ('Sprint', 'Status') AND jira_issue_dwkey = " + DWKeyValue.UserValue.ToString() +
                      "ORDER BY source_created_dt";

                  SqlDataAdapter JIRADataAdapter = new SqlDataAdapter(SQLQuery, connection);

                  DataSet customerOrders = new DataSet();

                  JIRADataAdapter.Fill(customerOrders, "Customers");
                  HistoryBox.Items.Clear();
                  string value;
                  foreach (DataRow dr in customerOrders.Tables["Customers"].Rows)
                  {
                     value = dr["source_created_dt"] + ":" +  dr["Field_Name"].ToString() + ":" + dr["New_Value_Desc"].ToString();
                     HistoryBox.Items.Add(value);
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
            MessageBox.Show("A DW Key is required", "Missing Data", MessageBoxButtons.OK, MessageBoxIcon.Stop);

      }
   }
}
