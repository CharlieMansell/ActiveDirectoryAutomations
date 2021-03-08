# Init PowerShell Gui
Add-Type -AssemblyName System.Windows.Forms

# Create a new form
$ADManagementScripts                   = New-Object system.Windows.Forms.Form

# Define the size, title and background color
$ADManagementScripts.ClientSize         = '500,300'
$ADManagementScripts.text               = "Active Directory Management Scripts"


# Create a Title for our form. We will use a label for it.
$Title                           = New-Object system.Windows.Forms.Label

# The content of the label
$Title.text                      = "Active Directory Management"
# Make sure the label is sized the height and length of the content
$Title.AutoSize                  = $true
# Define the minial width and height (not needed with autosize true)
$Title.width                     = 25
$Title.height                    = 10
# Position the element
$Title.location                  = New-Object System.Drawing.Point(20,20)
# Define the font type and size
$Title.Font                      = 'Microsoft Sans Serif,13'
# Other elemtents
$Description                     = New-Object system.Windows.Forms.Label
$Description.text                = "Internal Toolset to Manage Active Directory"
$Description.AutoSize            = $false
$Description.width               = 450
$Description.height              = 25
$Description.location            = New-Object System.Drawing.Point(20,50)
$Description.Font                = 'Microsoft Sans Serif,10'
$TaskSelection                   = New-Object system.Windows.Forms.ComboBox
$TaskSelection.text               = "Please select your desired action from the list below."
$TaskSelection.width              = 170
$TaskSelection.autosize           = $true
$TaskSelection.location           = New-Object System.Drawing.Point(20,50)
$AddRunBtn                   = New-Object system.Windows.Forms.Button
$AddRunBtn.BackColor         = "#a4ba67"
$AddRunBtn.text              = "Run Script"
$AddRunBtn.height            = 45
$AddRunBtn.location          = New-Object System.Drawing.Point(370,250)
$AddRunBtn.Font              = 'Microsoft Sans Serif,10'
$AddRunBtn.ForeColor         = "#ffffff"
$cancelBtn                       = New-Object system.Windows.Forms.Button
$cancelBtn.BackColor             = "#ffffff"
$cancelBtn.text                  = "Cancel"
$cancelBtn.width                 = 90
$cancelBtn.height                = 45
$cancelBtn.location              = New-Object System.Drawing.Point(260,250)
$cancelBtn.Font                  = 'Microsoft Sans Serif,10'
$cancelBtn.ForeColor             = "#000"
$cancelBtn.DialogResult          = [System.Windows.Forms.DialogResult]::Cancel
$ADManagementScripts.CancelButton   = $cancelBtn
$ADManagementScripts.Controls.Add($cancelBtn)

# Add the items in the dropdown list
@('User Creation','User Deactivation') | ForEach-Object {[void] $TaskSelection.Items.Add($_)}

# Select the default value
$TaskSelection.SelectedIndex       = 0
$TaskSelection.location            = New-Object System.Drawing.Point(20,210)
$TaskSelection.Font                = 'Microsoft Sans Serif,10'


# Add the elements to the form
$ADManagementScripts.controls.AddRange(@($Title,$Description,$TaskSelection,$cancelBtn,$AddRunBtn))


# Display the form
[void]$ADManagementScripts.ShowDialog()
