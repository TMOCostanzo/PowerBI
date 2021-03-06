﻿namespace PullCycleTimes
{
   partial class HistoryLookup
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

      #region Windows Form Designer generated code

      /// <summary>
      /// Required method for Designer support - do not modify
      /// the contents of this method with the code editor.
      /// </summary>
      private void InitializeComponent()
      {
         this.LookupDWKey = new System.Windows.Forms.Button();
         this.LookupHistory = new System.Windows.Forms.Button();
         this.DWKeyValue = new PullCycleTimes.InputCombo();
         this.JIRAKeyValue = new PullCycleTimes.InputCombo();
         this.HistoryBox = new System.Windows.Forms.ListBox();
         this.SuspendLayout();
         // 
         // LookupDWKey
         // 
         this.LookupDWKey.Location = new System.Drawing.Point(569, 9);
         this.LookupDWKey.Name = "LookupDWKey";
         this.LookupDWKey.Size = new System.Drawing.Size(123, 23);
         this.LookupDWKey.TabIndex = 1;
         this.LookupDWKey.Text = "Lookup DWKey";
         this.LookupDWKey.UseVisualStyleBackColor = true;
         this.LookupDWKey.Click += new System.EventHandler(this.LookupDWKey_Click);
         // 
         // LookupHistory
         // 
         this.LookupHistory.Location = new System.Drawing.Point(569, 38);
         this.LookupHistory.Name = "LookupHistory";
         this.LookupHistory.Size = new System.Drawing.Size(123, 23);
         this.LookupHistory.TabIndex = 4;
         this.LookupHistory.Text = "Lookup History";
         this.LookupHistory.UseVisualStyleBackColor = true;
         this.LookupHistory.Click += new System.EventHandler(this.LookupHistory_Click);
         // 
         // DWKeyValue
         // 
         this.DWKeyValue.LabelValue = "Datawarehouse Key";
         this.DWKeyValue.Location = new System.Drawing.Point(12, 38);
         this.DWKeyValue.Name = "DWKeyValue";
         this.DWKeyValue.Size = new System.Drawing.Size(536, 23);
         this.DWKeyValue.TabIndex = 3;
         this.DWKeyValue.UserValue = "";
         // 
         // JIRAKeyValue
         // 
         this.JIRAKeyValue.LabelValue = "JIRA Key Value";
         this.JIRAKeyValue.Location = new System.Drawing.Point(12, 9);
         this.JIRAKeyValue.Name = "JIRAKeyValue";
         this.JIRAKeyValue.Size = new System.Drawing.Size(536, 23);
         this.JIRAKeyValue.TabIndex = 2;
         this.JIRAKeyValue.UserValue = "";
         // 
         // HistoryBox
         // 
         this.HistoryBox.FormattingEnabled = true;
         this.HistoryBox.Location = new System.Drawing.Point(32, 109);
         this.HistoryBox.Name = "HistoryBox";
         this.HistoryBox.Size = new System.Drawing.Size(741, 277);
         this.HistoryBox.TabIndex = 5;
         // 
         // HistoryLookup
         // 
         this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
         this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
         this.ClientSize = new System.Drawing.Size(800, 450);
         this.Controls.Add(this.HistoryBox);
         this.Controls.Add(this.LookupHistory);
         this.Controls.Add(this.DWKeyValue);
         this.Controls.Add(this.JIRAKeyValue);
         this.Controls.Add(this.LookupDWKey);
         this.Name = "HistoryLookup";
         this.Text = "Form1";
         this.ResumeLayout(false);

      }

      #endregion
      private System.Windows.Forms.Button LookupDWKey;
      private InputCombo JIRAKeyValue;
      private InputCombo DWKeyValue;
      private System.Windows.Forms.Button LookupHistory;
      private System.Windows.Forms.ListBox HistoryBox;
   }
}

