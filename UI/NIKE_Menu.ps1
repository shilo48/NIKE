Add-Type -assembly System.Windows.Forms
$NIKE_VER = "1.0.0"

$button1_click = {
    $custom_form = New-Object System.Windows.Forms.Form
    $custom_form.Text ='Custom'
    $custom_form.Width = 150
    $custom_form.Height = 600
    $custom_form.AutoSize = $true
    $custom_form.BackColor = "Black"

    $packages_list = @("Notepad++", "MobaXterm", "VS Code", "WinScp", "VirtualBox", "Wireshark")
    $button_y = 10
    foreach ($package in $packages_list)
    {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.size = '350,20'
        $checkbox.Location = "10,$($button_y)"
        $checkbox.Text = $package
        $checkbox.ForeColor = "White"
        $custom_form.Controls.Add($checkbox)

        $button_y += 30
    }

    $custom_form.ShowDialog()
}

Function profile_click()
{
    Param($radio_buttons, $prof_packages_list, $profile_index, $textBox1)
    
    if ($radio_buttons[$profile_index].Checked) {
        $textBox1.Text = $prof_packages_list[$profile_index]
        $textBox1.Refresh()
        Write-Output "Clicked"
    }
}
Function init_textbox2()
{
    $powershell_ver = $PSVersionTable.PSVersion
    $execution_policy = Get-ExecutionPolicy
    $textBox2.Text += "NIKE version: $NIKE_VER"
    $textBox2.Text += $new_line
    $textBox2.Text += "Powershell version: $powershell_ver"
    $textBox2.Text += $new_line
    $textBox2.Text += "Execution Policy: $execution_policy"
    $textBox2.Text += $new_line
   
    if($execution_policy -ne "Unrestricted"){
        $textBox2.Text += "***Note! You must change the Execution Policy to Unrestricted"
        $textBox2.Text += $new_line
        $textBox2.Text += "***Run the following command via Powershell in Administrator mode:"
        $textBox2.Text += $new_line
        $textBox2.Text += "     Set-ExecutionPolicy Unrestricted"
        $textBox2.Text += $new_line
    }
}

$new_line = "`r`n"
$font = New-Object System.Drawing.Font("Times New Roman",12,[System.Drawing.FontStyle]::Italic)


$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='NIKE'
$main_form.Width = 600
$main_form.Height = 700
$main_form.AutoSize = $true
$main_form.BackColor = "Black"
$main_form.Font = $font

$groupBox1 = New-Object System.Windows.Forms.GroupBox
$groupBox1.Location = '20,20'
$groupBox1.size = '120,250'
$groupBox1.text = "Profiles:"
$groupBox1.ForeColor = "White"

#$profiles_list = @("CU", "DU", "SIG", "SVG")
$profiles_list = @()
$prof_packages_list = @()

Get-ChildItem "$($PSScriptRoot)\..\Profiles" -Filter *.config | 
Foreach-Object {
    $profiles_list += ($_.BaseName)

    $packages_list = ""
    
    [xml]$xml = Get-Content $_.FullName
    $nodes = Select-Xml "//package/@id" $xml
    $nodes | ForEach-Object {
        $packages_list += ($_.Node.Value)
        $packages_list += $new_line
    }
    
    $prof_packages_list += ($packages_list)
}

#$profiles_list.Length
#$profiles_list
#$prof_packages_list.Length
#$prof_packages_list

$textBox1 = New-Object System.Windows.Forms.TextBox
$textBox1.Location = New-Object System.Drawing.Point(150,20)
$textBox1.Size = New-Object System.Drawing.Size(400,250)
$textBox1.AutoSize = $true
$textBox1.Multiline = $true
$textBox1.ScrollBars = 'Both'
#$textBox1.Text = "Notepad++ $($new_line)Beyond Compare $($new_line)VS Code $($new_line)SecureCrt"
$main_form.Controls.Add($textBox1)

$button_y = 30
$profile_index = 0
$radio_buttons = @()
foreach ($prof in $profiles_list)
{
    $radioBtn = New-Object System.Windows.Forms.RadioButton
    $radioBtn.size = '350,20'
    $radioBtn.Location = "30,$($button_y)"
    $radioBtn.Text = $prof
    $radioBtn.ForeColor = "White"
    $radioBtn.Add_Click({profile_click $radio_buttons $prof_packages_list $profile_index $textBox1})

    $groupBox1.Controls.Add($radioBtn)

    $button_y += 30
    $profile_index += 1
    $radio_buttons += $radioBtn
}
$main_form.Controls.Add($groupBox1)

$button1 = New-Object System.Windows.Forms.Button
$button1.Location = New-Object System.Drawing.Point(20,280)
$button1.Size = New-Object System.Drawing.Size(120,30)
$button1.Text = "Custom"
$button1.ForeColor = "White"
$button1.Add_Click($button1_click)
$main_form.Controls.Add($button1)

$button2 = New-Object System.Windows.Forms.Button
$button2.Location = New-Object System.Drawing.Point(450,280)
$button2.Size = New-Object System.Drawing.Size(120,30)
$button2.Text = "Install"
$button2.ForeColor = "White"
$main_form.Controls.Add($button2)

$textBox2 = New-Object System.Windows.Forms.TextBox
$textBox2.Location = New-Object System.Drawing.Point(20,320)
$textBox2.Size = New-Object System.Drawing.Size(550,280)
$textBox2.AutoSize = $true
$textBox2.Multiline = $true
$textBox2.ScrollBars = 'Both'
$textBox2.Text = ""
init_textbox2
$main_form.Controls.Add($textBox2)



$batches = @(1,2,3,4,5,6,7,8,9,10)
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = '20, 610'
$progressBar.Size = '550,35'
$progressBar.Maximum = $batches.Count
$progressBar.Minimum = 0
$main_form.Controls.Add($progressBar)

#$ShownFormAction = {
#    $main_form.Activate()
#    foreach ($b in $batches) {
#        $progressBar.Increment(1)
#        Start-Sleep -Seconds 1
#    }
#    $main_form.Dispose()
#}
#$main_form.Add_Shown($ShownFormAction)

$main_form.ShowDialog()
