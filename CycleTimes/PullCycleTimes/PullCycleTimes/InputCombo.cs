using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace PullCycleTimes
{
   public partial class InputCombo : UserControl
   {
      public InputCombo()
      {
         InitializeComponent();
      }

      [Category("Control Values")]
     public string LabelValue
      {

         get
         {
            return lblDescription.Text;
         }
         set
         {
            lblDescription.Text = value;
         }
      }

      [Category("Control Values")]
      public string UserValue
      {
         get
         {
            return txtUserEntry.Text;
         }

         set
         {
            txtUserEntry.Text = value;
         }
      }


   }
  }