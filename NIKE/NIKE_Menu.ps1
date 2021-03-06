Add-Type -assembly System.Windows.Forms
$NIKE_VER = "1.0.0"
$global:current_config_file_name = ""
$scriptDir = if (-not $PSScriptRoot) { Split-Path -Parent (Convert-Path ([environment]::GetCommandLineArgs()[0])) } else { $PSScriptRoot }
$new_line = "`r`n"
$font = New-Object System.Drawing.Font("Microsoft Sans Serif",10)

$install_button_click = {
    $textBox2.Text += "Create packages.config file"
    $textBox2.Text += $new_line
    $textBox2.Refresh()
    $src_path = "$($scriptDir)\..\Profiles\$($global:current_config_file_name).config"
    $des_path = "$($scriptDir)\..\Profiles\res\packages.config"
    Copy-Item -Path $src_path -Destination $des_path

    $textBox2.Text += "packages install - RUN"
    $textBox2.Text += $new_line
    $textBox2.Refresh()
    cd $scriptDir\..\INFRA
    .\install.ps1 ..\Profiles\res\packages.config
    cd $scriptDir
    $textBox2.Text += "packages install - FINISH"
    $textBox2.Text += $new_line
    $textBox2.Refresh()
}
Function checkbox_click  {
    Param($packages_list_copy)
    if ($this.Checked -eq $false)
    {
        $packages_list_copy.Remove($this.Text)
    }
    else{
        $packages_list_copy.Add($this.Text)
    }
}
Function profile_click()
{
    Param($profiles_list, $prof_packages_list)

    if ($this.Checked) {
        $i = 0
        foreach ($profile in $profiles_list) {
            if ($this.Text -eq $profile) {
                $global:current_config_file_name = $this.Text
                $textBox1.Text = $prof_packages_list[$i]
                $textBox1.Refresh()
                break
            }
            ++$i
        }

    }
}
Function custom_ok_button_click  {
    Param($packages_list_copy, $profiles_list, $prof_packages_list, $panel, $radio_buttons, $button_y)

    custom_xml_profile_xml $packages_list_copy
    
    
    $packages_list_copy_str = ""
    foreach ($package in $packages_list_copy) {
        $packages_list_copy_str += $package
        $packages_list_copy_str += $new_line
    }
    
    $customProfilefound = $false
    $i = 0
    foreach ($profile in $profiles_list) {
        if ("customProfile" -eq $profile) {
            $prof_packages_list[$i] = $packages_list_copy_str
            $customProfilefound = $true
            $radio_buttons[$i].Checked = $true
            $radio_buttons[$i].PerformClick()
        }
        else {
            $radio_buttons[$i].Checked = $false
        }
        $i += 1
    }
    if($customProfilefound -eq $false){
        $prof_packages_list.Add($packages_list_copy_str)
        $profiles_list.Add("customProfile")

        $customRadioBtn = New-Object System.Windows.Forms.RadioButton
        $customRadioBtn.size = '350,20'
        $customRadioBtn.Location = New-Object System.Drawing.Point(10,$($button_y))
        $customRadioBtn.Text = "customProfile"
        $customRadioBtn.ForeColor = "White"
        $customRadioBtn.Add_Click({profile_click $profiles_list $prof_packages_list})
        $customRadioBtn.Checked = $true
        $customRadioBtn.PerformClick()

        $panel.Controls.Add($customRadioBtn)
        $panel.Refresh()

        $button_y += 30
        $radio_buttons.Add($customRadioBtn)
    }
    $panel.Refresh()
    $custom_form.Close()
}

Function custom_xml_profile_xml ([string[]]$packages_list) {
    Write-Output $packages_list
    $custom_profile_xml_path = "$($scriptDir)\..\Profiles\customProfile.config"
    New-Item $custom_profile_xml_path  -ItemType File -Force
    Set-Content $custom_profile_xml_path '<?xml version="1.0" encoding="utf-8"?>'
    Add-Content $custom_profile_xml_path '<packages>'
    foreach ($package in $packages_list) {
        Add-Content $custom_profile_xml_path "`t<package id=`"$($package)`" />"
    }
    Add-Content $custom_profile_xml_path '</packages>'
}

Function custom_button_click  {
    Param($packages_list, $profiles_list, $prof_packages_list, $panel, $radio_buttons, $profile_button_y)

    $custom_form = New-Object System.Windows.Forms.Form
    $custom_form.Text ='Custom'
    $custom_form.Width = 100
    $custom_form.Height = 500
    $custom_form.AutoSize = $true
    $custom_form.ForeColor = "White"
    $custom_form.BackColor = '#101f51'
    $custom_form.Font = $font
    
    $custom_form.FormBorderStyle = 3
    $custom_form.AutoSize = $true
    $custom_form.MaximizeBox = $false
    $custom_form.MinimizeBox = $false

    #$packages_list = $prof_packages_list #@("Notepad++", "MobaXterm", "VS Code", "WinScp", "VirtualBox", "Wireshark")
    [System.Collections.ArrayList]$packages_list_copy = $packages_list
    $button_y = 10
    [System.Collections.ArrayList]$checkbox_list = @()
    foreach ($package in $packages_list)
    {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.size = '350,20'
        $checkbox.Location = "10,$($button_y)"
        $checkbox.Text = $package
        $checkbox.ForeColor = "White"
        $checkbox.Checked = $true
        $checkbox.Add_Click({checkbox_click $packages_list_copy})
        $custom_form.Controls.Add($checkbox)

        $button_y += 30
        $checkbox_list.Add($checkbox)
    }
    

    $custom_ok_button = New-Object System.Windows.Forms.Button
    $custom_ok_button.Location = New-Object System.Drawing.Point(10,$button_y)
    $custom_ok_button.Size = New-Object System.Drawing.Size(120,30)
    $custom_ok_button.Text = "OK"
    $custom_ok_button.ForeColor = "White"
    $custom_ok_button.Add_Click({custom_ok_button_click $packages_list_copy $profiles_list $prof_packages_list $panel $radio_buttons $profile_button_y})
    $custom_form.Controls.Add($custom_ok_button)

    $custom_deselect_all_button = New-Object System.Windows.Forms.Button
    $custom_deselect_all_button.Location = New-Object System.Drawing.Point(135,$button_y)
    $custom_deselect_all_button.Size = New-Object System.Drawing.Size(120,30)
    $custom_deselect_all_button.Text = "Deselect All"
    $custom_deselect_all_button.ForeColor = "White"
    $custom_deselect_all_button.Add_Click({custom_deselect_all_button_click $packages_list_copy $checkbox_list})
    $custom_form.Controls.Add($custom_deselect_all_button)

    $custom_select_all_button = New-Object System.Windows.Forms.Button
    $custom_select_all_button.Location = New-Object System.Drawing.Point(260,$button_y)
    $custom_select_all_button.Size = New-Object System.Drawing.Size(120,30)
    $custom_select_all_button.Text = "Select All"
    $custom_select_all_button.ForeColor = "White"
    $custom_select_all_button.Add_Click({custom_select_all_button_click $packages_list_copy $checkbox_list})
    $custom_form.Controls.Add($custom_select_all_button)

    $custom_form.ShowDialog()
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

Function clear_button_click()
{
    $textBox2.Text = ""
    init_textbox2
    $textBox2.Refresh()
}

Function custom_deselect_all_button_click()
{
    Param($packages_list_copy, $checkbox_list)

    $packages_list_copy.Clear()
    foreach ($checkbox in $checkbox_list)
    {
        $checkbox.Checked = $false
    }
}

Function custom_select_all_button_click()
{
    Param($packages_list_copy, $checkbox_list)

    $packages_list_copy.Clear()
    foreach ($checkbox in $checkbox_list)
    {
        $packages_list_copy.Add($checkbox.Text)
        $checkbox.Checked = $true
    }
}

$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='NIKE'
$main_form.Width = 600
$main_form.Height = 700
$main_form.BackColor = "#0d1a44"
$main_form.AutoSize = $true
$main_form.FormBorderStyle = 3
$main_form.MaximizeBox = $false
$main_form.MinimizeBox = $false
$main_form.Font = $font
$main_form.Icon = "$($scriptDir)\..\INFRA\NIKE-icon.ico"

$groupBox1 = New-Object System.Windows.Forms.GroupBox
$groupBox1.Location = '20,20'
$groupBox1.size = '265,250'
$groupBox1.text = "Profiles:"
$groupBox1.ForeColor = "White"
$groupBox1.BackColor = '#101f51'
$groupBox1.Cursor = 'Hand'
$groupBox1.Padding = 0

$panel = New-Object System.Windows.Forms.Panel
$panel.Location = '20,20'
$panel.Size = '240,220'
$panel.ForeColor = "White"
$panel.BackColor = '#101f51'
$panel.Cursor = 'Hand'
$panel.Padding = 0
$panel.AutoScroll = $true
$panel.VerticalScroll.Enabled = $true
$panel.VerticalScroll.Visible = $true
$panel.HorizontalScroll.Enabled = $true
$panel.HorizontalScroll.Visible = $true
$groupBox1.Controls.Add($panel)

$packages_list = @()
[System.Collections.ArrayList]$profiles_list = @()
[System.Collections.ArrayList]$prof_packages_list = @()

Get-ChildItem "$($scriptDir)\..\Profiles" -Filter *.config | 
Foreach-Object {
    $profiles_list += ($_.BaseName)

    $packages_str = ""
    
    [xml]$xml = Get-Content $_.FullName
    $nodes = Select-Xml "//package/@id" $xml
    $nodes | ForEach-Object {
        $packages_str += ($_.Node.Value)
        $packages_str += $new_line
        if(($_.Node.Value) -notin $packages_list){
            $packages_list += ($_.Node.Value)
        }
    }
    
    $prof_packages_list += ($packages_str)
}

$textBox1 = New-Object System.Windows.Forms.TextBox
$textBox1.Location = New-Object System.Drawing.Point(310,20)
$textBox1.Size = New-Object System.Drawing.Size(260,250)
$textBox1.AutoSize = $true
$textBox1.Multiline = $true
$textBox1.BackColor = '#8c99c3'
$textBox1.ScrollBars = 'Both'
$main_form.Controls.Add($textBox1)

$button_y = 20
[System.Collections.ArrayList]$radio_buttons = @()
foreach ($prof in $profiles_list)
{
    $radioBtn = New-Object System.Windows.Forms.RadioButton
    $radioBtn.size = '200,20'
    $radioBtn.Location = "10,$($button_y)"
    $radioBtn.Text = $prof
    $radioBtn.ForeColor = "White"
    $radioBtn.Add_Click({profile_click $profiles_list $prof_packages_list})


    $panel.Controls.Add($radioBtn)

    $button_y += 30
    $radio_buttons += $radioBtn
    
    
}

$main_form.Controls.Add($groupBox1)

$custom_button = New-Object System.Windows.Forms.Button
$custom_button.Location = New-Object System.Drawing.Point(20,280)
$custom_button.Size = New-Object System.Drawing.Size(120,30)
$custom_button.Text = "Custom"
$custom_button.ForeColor = "White"
$custom_button.BackColor = "#101f51"
$custom_button.Cursor = 'Hand'
$custom_button.Add_Click({custom_button_click $packages_list $profiles_list $prof_packages_list $panel $radio_buttons $button_y})
$main_form.Controls.Add($custom_button)

$install_button = New-Object System.Windows.Forms.Button
$install_button.Location = New-Object System.Drawing.Point(450,280)
$install_button.Size = New-Object System.Drawing.Size(120,30)
$install_button.Text = "Install"
$install_button.ForeColor = "White"
$install_button.BackColor = "#101f51"
$install_button.Cursor = 'Hand'
$install_button.Add_Click($install_button_click)
$main_form.Controls.Add($install_button)

$img = [System.Drawing.Image]::Fromfile("$($scriptDir)\..\INFRA\NIKE-icon.png");
$pictureBox = New-Object System.Windows.Forms.PictureBox
$pictureBox.Location = New-Object System.Drawing.Point(400,520)
$pictureBox.Size = New-Object System.Drawing.Size(130,100)
$pictureBox.Image = $img
$main_form.Controls.Add($pictureBox)

$textBox2 = New-Object System.Windows.Forms.TextBox
$textBox2.Location = New-Object System.Drawing.Point(20,320)
$textBox2.Size = New-Object System.Drawing.Size(550,320)
$textBox2.AutoSize = $true
$textBox2.Multiline = $true
$textBox2.ScrollBars = 'Both'
$textBox2.BackColor = '#8c99c3'
$textBox2.Text = ""
init_textbox2
$main_form.Controls.Add($textBox2)

$clear_button = New-Object System.Windows.Forms.Button
$clear_button.Location = New-Object System.Drawing.Point(20,650)
$clear_button.Size = New-Object System.Drawing.Size(120,30)
$clear_button.Text = "Clear"
$clear_button.ForeColor = "White"
$clear_button.BackColor = "#101f51"
$clear_button.Cursor = 'Hand'
$clear_button.Add_Click({clear_button_click})
$main_form.Controls.Add($clear_button)

$main_form.ShowDialog()

    