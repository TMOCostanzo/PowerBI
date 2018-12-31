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
   public partial class LookupHistory : Form
   {
      public LookupHistory()
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
   }
}
