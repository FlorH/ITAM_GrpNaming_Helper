<#

.SYNOPSIS
	AATools allows the provisining in AD following the CIRRUS Security model
	
.DESCRIPTION
	This tool is a comprehensive script which allows performing of multiple functions
	while following the CIRRUS security model and naming standards.  
		
.INPUTS
	GUI
	
.OUTPUTS
	Updates AD
	Creates an log file and User reports saved at c:\cg\psreports

.LINK
	The Capital Group Compnaies
	Brought to you by the Directory Services L3 Team, another @YesJustFlor production
	
.EXAMPLE
	run the EXE
	

.Notes 
	Company:			Capital Group Companies
	Author:				FEH
	Date Created: 		January 2016
	Reveiwer:			FEH
	Date Released		07/12/2017
	Current Version:	1.22 
	***************************************************************************************
	Version History
	01/01/2016	FEH	1.00	Script Creation
	07/12/2017	FEH	1.21	FIXED - ability to add users to BTE groups
							FIXED - incorrectly identified front end groups as outside of CIRRUS zone
							Removed debug write statements
	07/18/2017	FEH	1.22	FIXED - form close statements to remove errors when closing compiled exe
						
#
#######################################################################################>

########################################################################################################################
########################################################################################################################
#
#	Windows Presentation Forms using XAML for GUI
#
#########################################################################################################################
#########################################################################################################################
$ScriptVersion="02.00"

$inputXML = @"

<Window x:Name="MainForm" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="ITAM Group Naming Helper - v$ScriptVersion" Background="#FFE5E5E5" Height="840" Width="870" BorderBrush="#FF8B9295" BorderThickness="2" FontSize="14" Margin="0" ResizeMode="CanResizeWithGrip" ScrollViewer.HorizontalScrollBarVisibility="Auto" ScrollViewer.VerticalScrollBarVisibility="Auto">
    <Grid x:Name="MainGrid" Margin="0">
        <Label x:Name="LB1" Content="ITAM Group Naming Helper for cguser.capgroup.com" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" Width="520" FontSize="20" FontWeight="SemiBold"/>
        <TextBox HorizontalAlignment="Left" Height="50" Margin="10,50,0,0" TextWrapping="Wrap" Text="Use this tool to help you find backend or craft front-end groups for your application as it moves into the CIRRUS zones.   Front-end groups should be used within your application to define permissions granted to the users." VerticalAlignment="Top" Width="780" Background="#FFE5E5E5"/>
        <Label x:Name="LB2" Content="The Helper does not update Active Directory! It creates a CSV file which can be used to attach to your ARMS." HorizontalAlignment="Left" Margin="10,101,0,0" VerticalAlignment="Top" RenderTransformOrigin="-0.162,0.55" Width="808" Height="31" FontSize="16" FontWeight="SemiBold"/>

        <GroupBox x:Name="GB_Type" Header="Front or Backend Groups" HorizontalAlignment="Left" Margin="10,135,0,0" VerticalAlignment="Top" Height="90" Width="185" FontSize="14" TabIndex="3">
            <Grid HorizontalAlignment="Left" Height="70" Margin="0,0,-2,0" VerticalAlignment="Top" Width="175">
                <RadioButton x:Name="Radio_Front" Content="Front-end User Groups" HorizontalAlignment="Left" Margin="10,5,0,0" VerticalAlignment="Top" Width="165" TabIndex="11" Height="30" />
                <RadioButton x:Name="Radio_Back" Content="Backend Admin Groups" HorizontalAlignment="Left" Margin="10,40,0,0" VerticalAlignment="Top" Width="165" TabIndex="12" Height="30" />
            </Grid>
        </GroupBox>

        <GroupBox x:Name="GB_Zone" Header="Zone" HorizontalAlignment="Left" Margin="200,135,0,0" VerticalAlignment="Top" Height="60" Width="250" FontSize="14" TabIndex="3">
            <Grid HorizontalAlignment="Left" Height="45" Margin="0,0,-2,0" Width="240">
                <RadioButton x:Name="Radio_AZ" Content="AZ" HorizontalAlignment="Left" Margin="180,10,0,0" VerticalAlignment="Top" TabIndex="1" />
                <RadioButton x:Name="Radio_CPZ" Content="CPZ" HorizontalAlignment="Left" Margin="120,10,0,0" VerticalAlignment="Top" TabIndex="2"/>
                <RadioButton x:Name="Radio_SNP" Content="SNP" HorizontalAlignment="Left" Margin="60,10,0,0" VerticalAlignment="Top" TabIndex="3" />
                <RadioButton x:Name="Radio_OZ" Content="OZ" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" TabIndex="1" />
            </Grid>
        </GroupBox>

        <GroupBox x:Name="GB_Envir" Header="Environment" HorizontalAlignment="Left" Margin="455,135,0,0" VerticalAlignment="Top" Height="60" Width="242" FontSize="14" TabIndex="2">
            <Grid HorizontalAlignment="Left" Margin="0,0,-2,0" Width="232">
                <RadioButton x:Name="Radio_EnvInfra" Content="Inf" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" TabIndex="6" />
                <RadioButton x:Name="Radio_EnvOne" Content="ACT" HorizontalAlignment="Left" Margin="67,10,-13,0" VerticalAlignment="Top" TabIndex="7" />
                <RadioButton x:Name="Radio_EnvTwo" Content="DEV" HorizontalAlignment="Left" Margin="122,10,-69,0" VerticalAlignment="Top" TabIndex="7" />
                <RadioButton x:Name="Radio_EnvThree" Content="TST" HorizontalAlignment="Left" Margin="183,10,-126,0" VerticalAlignment="Top" TabIndex="7" />
            </Grid>
        </GroupBox>

        <Label x:Name="LB3" Content="AD OU aka CGID" HorizontalAlignment="Left" Margin="10,231,0,0" VerticalAlignment="Top" Width="185"/>
        <ListBox x:Name="LB_CurrentOUs" HorizontalAlignment="Left" Height="490" Margin="10,260,0,0" VerticalAlignment="Top" Width="185"/>
        <Button x:Name="Btn_SelectOU" Content="Select OU" HorizontalAlignment="Left" Margin="55,765,0,0" VerticalAlignment="Top" Width="75"/>
        <Label x:Name="LB4" Content="Current Groups" HorizontalAlignment="Left" Margin="210,231,0,0" VerticalAlignment="Top" Width="175"/>
        <ListBox x:Name="LB_CurrentGrps" HorizontalAlignment="Left" Height="200" Margin="210,260,0,0" VerticalAlignment="Top" Width="376"/>
        <Label x:Name="LB5" Content="Current Members" HorizontalAlignment="Left" Margin="609,231,0,0" VerticalAlignment="Top" Width="120"/>
        <ListBox x:Name="LB_CurrentGrpMembers" HorizontalAlignment="Left" Height="200" Margin="609,260,0,0" VerticalAlignment="Top" Width="230"/>

        <Button x:Name="Btn_GetMembers" Content="Get Members" HorizontalAlignment="Left" Margin="491,460,0,0" VerticalAlignment="Top" Width="95" Height="30"/>
        <Button x:Name="Btn_ExportMembers" Content="Export Members" HorizontalAlignment="Left" Margin="724,460,0,0" VerticalAlignment="Top" Width="115" Height="30"/>

        <Label x:Name="LB_6" Content="New Groups for ARMS" HorizontalAlignment="Left" Margin="520,500,0,0" VerticalAlignment="Top" Width="190"/>
        <ListBox x:Name="LB_NewGrps" HorizontalAlignment="Left" Height="220" Margin="520,530,0,0" VerticalAlignment="Top" Width="320"/>
        <Button x:Name="Btn_RemoveGrp" Content="Remove Grp" HorizontalAlignment="Left" Margin="320,720,0,0" VerticalAlignment="Top" Width="86" Height="30"/>
        <Button x:Name="Btn_ExportGrps" Content="Export Grps" HorizontalAlignment="Left" Margin="425,720,0,0" VerticalAlignment="Top" Width="85" Height="30"/>

        <Label x:Name="LB_7" Content="Prefix for the groups" HorizontalAlignment="Left" Margin="212,480,0,0" VerticalAlignment="Top" Width="238"/>
        <ListBox x:Name="TB_Prefix" HorizontalAlignment="Left" Height="40" Margin="210,509,0,0" VerticalAlignment="Top" Width="240"/>
        <Label x:Name="LB_8" Content="New Group Name" HorizontalAlignment="Left" Margin="212,555,0,0" VerticalAlignment="Top" Width="188"/>
        <TextBox x:Name="TB_NewGrpName" HorizontalAlignment="Left" Height="40" Margin="212,585,0,0" TextWrapping="Wrap" Text="TextBox" VerticalAlignment="Top" Width="188"/>
        <Label x:Name="LB_9" Content="Group Description" HorizontalAlignment="Left" Margin="212,631,0,0" VerticalAlignment="Top" Width="238"/>
        <TextBox x:Name="TB_NewGrpDesc" HorizontalAlignment="Left" Height="40" Margin="210,660,0,0" TextWrapping="Wrap" Text="TextBox" VerticalAlignment="Top" Width="240"/>
        <Button x:Name="Btn_AddGrp" Content="Add Group" HorizontalAlignment="Left" Margin="212,720,0,0" VerticalAlignment="Top" Width="90" Height="30"/>

        <Button x:Name="Btn_ClearForm" Content="Clear Form" HorizontalAlignment="Left" Margin="744,151,0,0" VerticalAlignment="Top" Width="74" Height="30"/>
        <Button x:Name="Btn_EXIT" Content="EXIT" HorizontalAlignment="Left" Margin="764,762,0,0" VerticalAlignment="Top" Width="75" Height="30" FontWeight="Bold"/>
              
    </Grid>
</Window>



"@       

$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'
[xml]$XAML = $inputXML
$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
Try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
Catch{
	$StartScript={
		$Wshell = New-Object -ComObject Wscript.Shell -ErrorAction Stop
		$Wshell.popup("Unable to load Windows.Markup.XamlReader. .Net and Powershell must both be installed on this workstation for this script to work properly.",25,"Naming Helper Version $ScriptVersion")
	}
	$null = Start-Job -Name "AAError" -ScriptBlock $StartScript
	$null = Remove-Job "AAStart"
	$null = remove-job "AAError"
	#[System.Runtime.InteropServices.Marshal]::ReleaseComObject($Wshell) 
		Return}

# Load XAML Objects In PowerShell
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF_$($_.Name)" -Value $Form.FindName($_.Name)}

# Housekeeping
[Array]$GrpArray=$null
[Array]$UserArray=$null
[Array]$Script:ExportGrpList=$null 
[Array]$Script:ExportUserList=$null 
[Array]$Script:NewGrps=$null 
[Array]$Script:NewUsers=$null 
[Array]$Script:GrpMembers=$null
[Array]$Script:NewMembers=$null
[Bool]$Script:GroupsFound=$false
[Bool]$Script:GroupSelected=$false
[Bool]$Script:ValidOU=$false
[String]$Script:GrpsDN=$null
[String]$Script:Zone=$null
[Bool]$Script:GroupCreated=$false
[Bool]$Script:ClearData = $false 

$DirPath = "C:\CG\PSReports"
$ReportPath = "C:\CG\PSReports"
if (!(Test-Path $ReportPath)){$null = New-Item -path "C:\CG\" -name "PSReports" -type directory}

if (!(Test-Path $ReportPath)){
	Write-Output " "
	write-output ("### Unable to create $ReportPath, exiting script")
	write-output " "
	Return
}

Try {$DomainDetail = Get-ADDomain}
Catch {
	Write-Output " "
	Write-Output ("### Unable to access Domain information, exiting script")
	Write-Output " "
	Return
}

$DomainDN = $DomainDetail.DistinguishedName
$DNSRoot = $DomainDetail.DNSRoot

Function fcn_AddLogEntry {
	Param($entry)
	Write-host $Entry }

Function fcn_GetOUs{
	Param($Script:FEUserGroups, $Script:GrpOU)

	$ListOUs.Items.Clear()
	fcn_AddLogEntry ("... Retrieving OUs for $Script:GrpOU")
	#$StatusBar.Text = "Retrieving OUs, please wait ..."
	
	If ($Script:FEUserGroups){
		Try {[Array]$SubOUs = Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase $Script:GrpOU | Where-Object {$_.DistinguishedName -ne $Script:GrpOU}  | Where-Object {$_.Name -notlike "*BackEndRoles"}  | Where-Object {$_.Name -notlike "*RoleOwners*"}}
		Catch {
			Write-Host " "
			fcn_AddLogEntry ("### Unable to access OZ Group OU, exiting script")
			Write-Host " "
			Return}
	}
	Else {
		Try {[Array]$SubOUs = Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase $Script:GrpOU | Where-Object {$_.DistinguishedName -ne $Script:GrpOU}  | Where-Object {$_.Name -like "*BackEndRoles"}  | Where-Object {$_.Name -notlike "*RoleOwners*"}}
		Catch {
			Write-Host " "
			fcn_AddLogEntry ("### Unable to access OZ Group OU, exiting script")
			Write-Host " "
			Return}
	}
	
	If ($SubOUs.count -gt 0){
		[Array]$SubOUs = $SubOUs | Sort-Object -Property DistinguishedName 
		$tmpValid=$true; $a=0
		ForEach ($tmpOU in $SubOUs){
			$a++
			[String]$tmpOUName = $tmpOU.Name
			$null = $ListOUs.Items.Add($tmpOUName)
		}
	}
	Else {
		$tmpValid=$false
		$null = $ListOUs.Items.Add("%%%")
		$null = $ListOUs.Items.Add("%%% OU is not in use yet")
		$null = $ListOUs.Items.Add("%%%")
	}
	
	Return $tmpValid

}

Function fcn_SetOU{
	 #Radio_EnvInfra" Content="Inf" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" TabIndex="6" />
     #Radio_EnvOne" Content="ACT" HorizontalAlignment="Left" Margin="67,10,-13,0" VerticalAlignment="Top" TabIndex="7" />
     #Radio_EnvTwo" Content="DEV" HorizontalAlignment="Left" Margin="122,10,-69,0" VerticalAlignment="Top" TabIndex="7" />
     #Radio_EnvThree" Content="TST" HorizontalAlignment="Left" Margin="183,10,-126,0" VerticalAlignment="Top" TabIndex="7" />

	If ($WPF_Radio_OZ.Checked){$Script:Zone="OZ"
		$WPF_RadioOne.Visibility = "Visible"
		$WPF_RadioTwo.Visibility = "Visible"
		$WPF_RadioOne.Content = "Dev"
		$WPF_RadioTwo.Content  = "TST"
		If($WPF_Radio_EnvInfra.Checked){$Script:EnvirOU="INF"}
		ElseIf ($WPF_RadioOne.Checked){$Script:EnvirOU="Dev"}
		ElseIf ($WPF_RadioTwo.Checked){$Script:EnvirOU="TST"}
		Else {$Script:EnvirOU=$null}
	}
	ElseIf ($WPF_Radio_SNP.Checked){$Script:Zone="SNP"
		$WPF_RadioOne.Visibility = "Visible"
		$WPF_RadioTwo.Visibility = "Visible"
		$WPF_RadioONE.Content = "ATN"
		$WPF_RadioTWO.Content = "ATS"
		If($WPF_Radio_EnvInfra.Checked){$Script:EnvirOU="INF"}
		ElseIf ($WPF_RadioOne.Checked){$Script:EnvirOU="ATN"}
		ElseIf ($WPF_RadioTWO.Checked){$Script:EnvirOU="ATS"}
		Else {$Script:EnvirOU=$null}
		}
	ElseIf ($WPF_Radio_CPZ.Checked){$Script:Zone="CPZ"
		$WPF_RadioOne.Visibility = "Visible"
		$WPF_RadioOne.Text = "PRD"
		$WPF_RadioTwo.Visibility = "Hidden"
		$WPF_RadioThree.Visibility = "Hidden"
		If($WPF_Radio_EnvInfra.Checked){$Script:EnvirOU="INF"}
		ElseIf ($WPF_RadioOne.Checked){$Script:EnvirOU="PRD"}
		Else {$Script:EnvirOU=$null}
				
	}
	ElseIf ($WPF_Radio_AZ.Checked){$Script:Zone="AZ"
		$WPF_RadioOne.Visibility = "Hidden"
		$WPF_RadioTwo.Visibility = "Hidden"
		$WPF_RadioThree.Visibility = "Hidden"
		If($WPF_Radio_EnvInfra.Checked){$Script:EnvirOU="INF"}
		Else {$Script:EnvirOU=$null}
	}
		
	If($Script:EnvirOU -eq $null){
		$StatusBar.Items.Clear()
		$null = $StatusBar.Items.Add("Please select a Zone")
		Return
	}

	$Script:GrpsDN = "ou="+$Script:EnvirOU+ ",ou=groups,ou="+$Script:Zone+ ","+$DomainDN
	$IsValid = fcn_GetOUs $Script:FEUserGroups $Script:GrpsDN


}

Function fcn_SelectOU{
	$ListCurrentGrps.Items.Clear()
	$AppOU = $ListOUs.SelectedItem
	fcn_ClearForm
	fcn_AddLogEntry ('... OU selected is '+'"'+$AppOU+'"')
	$StatusBar.Items.Clear()
	$null = $StatusBar.Items.Add("OU selected is $AppOU")
	#$TBselectedCGID.Text = $AppOU
	
	If($WPF_Radio_Back.checked){$Script:FEUserGroups=$false}
	Else {$Script:FEUserGroups=$true}
	
	$ListCurrentGrps.Items.Clear()
	
	If ($Script:FEUserGroups){
		#$Script:GrpOU = "ou="+$AppOU+",ou="+$Script:EnvirOU+ ",ou=groups,ou="+$Script:Zone+ ","+$DomainDN
		$Script:GrpOU = "ou="+$AppOU+","+$Script:GrpsDN 
		fcn_AddLogEntry ("... SearchBase is "+$GrpOU)
		Try {
			[Array]$Groups = Get-ADGroup -LDAPFilter '(name=*)' -SearchBase $GrpOU -SearchScope Subtree -properties description
			}
		Catch {fcn_AddLogEntry ("... Unable to retrieve groups, or no groups found")
			#$StatusBar.Text = "OU not selected, pick OU then press Select OU button"
			$StatusBar.Items.Clear()
			
			$null = $StatusBar.Items.Add("OU not selected, pick OU then press Select OU button")
			Return}
	}
	Else{
		#only get the groups that start with backend
		$Script:GrpOU = "ou="+$AppOU+","+$Script:GrpsDN 
		
		fcn_AddLogEntry ("... SearchBase is "+$GrpOU)
		Try {
			[Array]$Groups = Get-ADGroup -LDAPFilter '(name=Back*)' -SearchBase $GrpOU -SearchScope Subtree -properties description, Members
			[Array]$Groups += Get-ADGroup -LDAPFilter '(name=*role*)' -SearchBase $GrpOU -SearchScope Subtree -properties description, Members
			[Array]$Groups = $Groups | Sort-Object -Property DistinguishedName
			}
		Catch {fcn_AddLogEntry ("... Unable to retrieve groups, or no groups found")
			#$StatusBar.Text = "OU not selected, pick OU then press Select OU button"
			$StatusBar.Items.Clear()
			$null = $StatusBar.Items.Add("OU not selected, pick OU then press Select OU button")
			Return}
	}

	If ($Groups.count -gt 0){
		$tmpValid=$true; $a=0
		While ($a -lt $Groups.count){
				
			#fcn_AddLogEntry ("... existing groups found, displaying on screen")
			$Script:GroupsFound=$true 
			$tmpGroupName = $Groups[$a].name
			$tmpGrpDesc = $Groups[$a].Description
			$tmpGrpDN = $Groups[$a].DistinguishedName
			
			$GrpArray = New-Object System.Object
			$GrpArray | Add-Member -type NoteProperty -name GrpName -Value $tmpGroupName 
			$GrpArray | Add-Member -type NoteProperty -name GrpOU -Value $Script:GrpOU
			$GrpArray | Add-Member -type NoteProperty -name GrpDesc -Value $tmpGrpDesc
			$GrpArray | Add-Member -type NoteProperty -name GrpDN -Value $tmpGrpDN
			$Script:ExportGrpList += $GrpArray
			$null = $WPF_LB_CurrentGrps.Items.Add($tmpGrpDN)
			$a++
		}
	}
	Else {
		$tmpValid=$false
		$null = $WPF_LB_CurrentGrps.Items.Add("%%%")
		$null = $WPF_LB_CurrentGrps.Items.Add("%%% No Groups Defined Yet %%%")
		$null = $WPF_LB_CurrentGrps.Items.Add("%%%")
		}
		
	If ($Script:FEUserGroups){
		$Script:Prefix = $Script:Zone+"_"+$Script:EnvirOU+"_"+$AppOU+"_"
		$TBPreFix.Text = $Script:Prefix
		$InGroup.ReadOnly = $false
		$InDesc.ReadOnly = $false
		$MainForm.Controls.Remove($LinkLabel)
		$MainForm.Controls.Add($ListNewGrps)}
	Else {
		$Script:Prefix = $null
		$TBPreFix.Text = $null
		$InGroup.ReadOnly = $true
		$InDesc.Readonly = $true
		$ListNewGrps.Size = New-Object System.Drawing.Size(360,125)
		$MainForm.Controls.Add($ListNewGrps)
		$null = $ListNewGrps.Items.Add("##")
		$null = $ListNewGrps.Items.Add("## The groups listed are the auto generated administrative groups. ##")
		$null = $ListNewGrps.Items.Add("## Use these groups in your ARMS to request admin access to servers ##")
		$null = $ListNewGrps.Items.Add("## in a bundle. Do not request new Backend admin groups ##")
		$null = $ListNewGrps.Items.Add("## ")
		$null = $ListNewGrps.Items.Add("## Review the onBoarding with ARMS documentation in Confluence ##")
		$null = $ListNewGrps.Items.Add(" ")
		#$null = $ListNewGrps.Items.Add("https://confluence.capgroup.com/display/CIRRUS/Onboarding+with+ARMS")
		$MainForm.Controls.Add($LinkLabel)
	}
		

}

Function fcn_GetMembers{}

Function fcn_ExportMembers{}

Function fcn_RemoveGrp{}

Function fcn_AddGrp{}

Function fcn_ExportGrps{}

Function fcn_ClearForm{}

Function fcn_FinalClose{

	$reader.Close()
	$Form.Close()
}

$WPF_Radio_Front.Add_Click({fcn_SetOU})
$WPF_Radio_Back.Add_Click({fcn_SetOU})
$WPF_Radio_AZ.Add_Click({fcn_SetOU})
$WPF_Radio_CPZ.Add_Click({fcn_SetOU})
$WPF_Radio_SNP.Add_Click({fcn_SetOU})
$WPF_Radio_OZ.Add_Click({fcn_SetOU})



$WPF_Btn_GetMembers.Add_Click({fcn_SelectOU})
$WPF_Btn_GetMembers.Add_Click({fcn_GetMembers})
$WPF_Btn_ExportMembers.Add_Click({fcn_ExportMembers})
$WPF_Btn_RemoveGrp.Add_Click({fcn_RemoveGrp})
$WPF_Btn_AddGrp.Add_Click({fcn_AddGrp})
$WPF_Btn_ExportGrps.Add_Click({fcn_ExportGrps})
$WPF_Btn_ClearForm.Add_Click({fcn_ClearForm})
$WPF_Btn_EXIT.Add_Click({write-output "EXIT";fcn_FinalClose})

Write-Output "before the show dialog"
$Form.ShowDialog() | out-null
Write-Output "after the show dialog"

# Closes the form
$Form.Add_Closed({fcn_FinalClose})

