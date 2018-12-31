namespace PullCycleTimes
{
   partial class InputCombo
   {
      /// <summary> 
      /// Required designer variable.
      /// </summary>
      private System.ComponentModel.IContainer components = null;

      /// <summary> 
      /// Clean up any resources being used.
      /// </summary>
      /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
      protected override void Dispose(bool disposing)
      {
         if (disposing && (components != null))
         {
            components.Dispose();
         }
         base.Dispose(disposing);
      }

      #region Component Designer generated code

      /// <summary> 
      /// Required method for Designer support - do not modify 
      /// the contents of this method with the code editor.
      /// </summary>
      private void InitializeComponent()
      {
         this.lblDescription = new System.Windows.Forms.Label();
         this.txtUserEntry = new System.Windows.Forms.TextBox();
         this.SuspendLayout();
         // 
         // lblDescription
         // 
         this.lblDescription.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left)));
         this.lblDescription.Location = new System.Drawing.Point(0, 0);
         this.lblDescription.Name = "lblDescription";
         this.lblDescription.Size = new System.Drawing.Size(160, 20);
         this.lblDescription.TabIndex = 0;
         this.lblDescription.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
         // 
         // txtUserEntry
         // 
         this.txtUserEntry.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
         this.txtUserEntry.Location = new System.Drawing.Point(170, 0);
         this.txtUserEntry.Multiline = true;
         this.txtUserEntry.Name = "txtUserEntry";
         this.txtUserEntry.Size = new System.Drawing.Size(366, 20);
         this.txtUserEntry.TabIndex = 1;
         // 
         // InputCombo
         // 
         this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
         this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
         this.Controls.Add(this.txtUserEntry);
         this.Controls.Add(this.lblDescription);
         this.Name = "InputCombo";
         this.Size = new System.Drawing.Size(536, 20);
         this.ResumeLayout(false);
         this.PerformLayout();

      }

      #endregion

      private System.Windows.Forms.Label lblDescription;
      private System.Windows.Forms.TextBox txtUserEntry;
   }
}
