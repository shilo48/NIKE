Add-Type -assembly System.Windows.Forms
$NIKE_VER = "1.0.0"
$global:current_config_file_name = ""
$scriptDir = if (-not $PSScriptRoot) { Split-Path -Parent (Convert-Path ([environment]::GetCommandLineArgs()[0])) } else { $PSScriptRoot }
$new_line = "`r`n"
$font = New-Object System.Drawing.Font("Times New Roman",13)

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
    Param($packages_list_copy, $profiles_list, $prof_packages_list, $groupBox1, $radio_buttons, $button_y)

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
        $customRadioBtn.Location = New-Object System.Drawing.Point(30,$($button_y))
        $customRadioBtn.Text = "customProfile"
        $customRadioBtn.ForeColor = "White"
        $customRadioBtn.Add_Click({profile_click $profiles_list $prof_packages_list})
        $customRadioBtn.Checked = $true
        $customRadioBtn.PerformClick()

        $groupBox1.Controls.Add($customRadioBtn)
        $groupBox1.Refresh()

        $button_y += 30
        $radio_buttons.Add($customRadioBtn)
    }
    $groupBox1.Refresh()
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
    Param($packages_list, $profiles_list, $prof_packages_list, $groupBox1, $radio_buttons, $profile_button_y)

    $custom_form = New-Object System.Windows.Forms.Form
    $custom_form.Text ='Custom'
    $custom_form.Width = 150
    $custom_form.Height = 600
    $custom_form.AutoSize = $true
    $custom_form.BackColor = "Black"
    $custom_form.Font = $font
    $custom_form.AutoSize = $true

    #$packages_list = $prof_packages_list #@("Notepad++", "MobaXterm", "VS Code", "WinScp", "VirtualBox", "Wireshark")
    [System.Collections.ArrayList]$packages_list_copy = $packages_list
    $button_y = 10
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
    }
    

    $custom_ok_button = New-Object System.Windows.Forms.Button
    $custom_ok_button.Location = New-Object System.Drawing.Point(20,480)
    $custom_ok_button.Size = New-Object System.Drawing.Size(120,30)
    $custom_ok_button.Text = "OK"
    $custom_ok_button.ForeColor = "White"
    $custom_ok_button.Add_Click({custom_ok_button_click $packages_list_copy $profiles_list $prof_packages_list $groupBox1 $radio_buttons $profile_button_y})
    $custom_form.Controls.Add($custom_ok_button)

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

$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='NIKE'
$main_form.Width = 600
$main_form.Height = 700
$main_form.AutoSize = $true
$main_form.BackColor = "Black"
$main_form.Font = $font

$groupBox1 = New-Object System.Windows.Forms.GroupBox
$groupBox1.Location = '20,20'
$groupBox1.size = '280,250'
$groupBox1.text = "Profiles:"
$groupBox1.ForeColor = "White"

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
$textBox1.ScrollBars = 'Both'
$main_form.Controls.Add($textBox1)

$button_y = 30
[System.Collections.ArrayList]$radio_buttons = @()
foreach ($prof in $profiles_list)
{
    $radioBtn = New-Object System.Windows.Forms.RadioButton
    $radioBtn.size = '350,20'
    $radioBtn.Location = "30,$($button_y)"
    $radioBtn.Text = $prof
    $radioBtn.ForeColor = "White"
    $radioBtn.Add_Click({profile_click $profiles_list $prof_packages_list})


    $groupBox1.Controls.Add($radioBtn)

    $button_y += 30
    $radio_buttons += $radioBtn
    
    
}

$main_form.Controls.Add($groupBox1)

$custom_button = New-Object System.Windows.Forms.Button
$custom_button.Location = New-Object System.Drawing.Point(20,280)
$custom_button.Size = New-Object System.Drawing.Size(120,30)
$custom_button.Text = "Custom"
$custom_button.ForeColor = "White"
$custom_button.Add_Click({custom_button_click $packages_list $profiles_list $prof_packages_list $groupBox1 $radio_buttons $button_y})
$main_form.Controls.Add($custom_button)

$install_button = New-Object System.Windows.Forms.Button
$install_button.Location = New-Object System.Drawing.Point(450,280)
$install_button.Size = New-Object System.Drawing.Size(120,30)
$install_button.Text = "Install"
$install_button.ForeColor = "White"
$install_button.Add_Click($install_button_click)
$main_form.Controls.Add($install_button)

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

    