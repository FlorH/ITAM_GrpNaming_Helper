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
    Title="ITAM Group Naming Helper - v$ScriptVersion" Background="#FFE5E5E5" Height="900" Width="840" BorderBrush="#FF8B9295" BorderThickness="2" FontSize="14" Margin="0" ResizeMode="CanResizeWithGrip" ScrollViewer.HorizontalScrollBarVisibility="Auto" ScrollViewer.VerticalScrollBarVisibility="Auto">
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
                <RadioButton x:Name="TA_Radio_AZ" Content="AZ" HorizontalAlignment="Left" Margin="180,10,0,0" VerticalAlignment="Top" TabIndex="1" />
                <RadioButton x:Name="TA_Radio_CPZ" Content="CPZ" HorizontalAlignment="Left" Margin="120,10,0,0" VerticalAlignment="Top" TabIndex="2"/>
                <RadioButton x:Name="TA_Radio_SNP" Content="SNP" HorizontalAlignment="Left" Margin="60,10,0,0" VerticalAlignment="Top" TabIndex="3" />
                <RadioButton x:Name="TA_Radio_OZ" Content="OZ" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" TabIndex="1" />
            </Grid>
        </GroupBox>

        <GroupBox x:Name="GB_Envir" Header="Environment" HorizontalAlignment="Left" Margin="455,135,0,0" VerticalAlignment="Top" Height="60" Width="242" FontSize="14" TabIndex="2">
            <Grid HorizontalAlignment="Left" Margin="0,0,-2,0" Width="232">
                <RadioButton x:Name="TA_Radio_EnvInfra" Content="Inf" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" TabIndex="6" />
                <RadioButton x:Name="TA_Radio_EnvOne" Content="ACT" HorizontalAlignment="Left" Margin="67,10,-13,0" VerticalAlignment="Top" TabIndex="7" />
                <RadioButton x:Name="TA_Radio_EnvTwo" Content="DEV" HorizontalAlignment="Left" Margin="122,10,-69,0" VerticalAlignment="Top" TabIndex="7" />
                <RadioButton x:Name="TA_Radio_EnvThree" Content="TST" HorizontalAlignment="Left" Margin="183,10,-126,0" VerticalAlignment="Top" TabIndex="7" />
            </Grid>
        </GroupBox>

        <Label x:Name="LB3" Content="AD OU aka CGID" HorizontalAlignment="Left" Margin="10,231,0,0" VerticalAlignment="Top" Width="185"/>
        <ListBox x:Name="LB_CurrentOUs" HorizontalAlignment="Left" Height="500" Margin="10,260,0,0" VerticalAlignment="Top" Width="185"/>
        <Button x:Name="Btn_SelectOU" Content="Select OU" HorizontalAlignment="Left" Margin="55,765,0,0" VerticalAlignment="Top" Width="75"/>
        <Label x:Name="LB4" Content="Current Groups" HorizontalAlignment="Left" Margin="210,231,0,0" VerticalAlignment="Top" Width="175"/>
        <ListBox x:Name="LB_CurrentGrps" HorizontalAlignment="Left" Height="200" Margin="210,260,0,0" VerticalAlignment="Top" Width="350"/>
        <Label x:Name="LB5" Content="Current Groups Members" HorizontalAlignment="Left" Margin="575,231,0,0" VerticalAlignment="Top" Width="175"/>
        <ListBox x:Name="LB_CurrentGrpMembers" HorizontalAlignment="Left" Height="200" Margin="575,260,0,0" VerticalAlignment="Top" Width="230"/>

        <Button x:Name="Btn_GetMembers" Content="Get Members" HorizontalAlignment="Left" Margin="465,460,0,0" VerticalAlignment="Top" Width="95" Height="30"/>
        <Button x:Name="Btn_ExportMembers" Content="Export Members" HorizontalAlignment="Left" Margin="691,460,0,0" VerticalAlignment="Top" Width="115" Height="30"/>

        <Label x:Name="LB_6" Content="New Groups for ARMS" HorizontalAlignment="Left" Margin="210,485,0,0" VerticalAlignment="Top" Width="190"/>
        <ListBox x:Name="LB_NewGrps" HorizontalAlignment="Left" Height="245" Margin="465,514,0,0" VerticalAlignment="Top" Width="340"/>
        <Button x:Name="Btn_RemoveGrp" Content="Remove Grp" HorizontalAlignment="Left" Margin="334,715,0,0" VerticalAlignment="Top" Width="85" Height="30"/>
        <Button x:Name="Btn_ExportGrps" Content="Export Grps" HorizontalAlignment="Left" Margin="720,769,0,0" VerticalAlignment="Top" Width="85" Height="30"/>

        <ListBox x:Name="TB_Prefix" HorizontalAlignment="Left" Height="40" Margin="210,514,0,0" VerticalAlignment="Top" Width="240"/>
        <TextBox x:Name="TB_NewGrpName" HorizontalAlignment="Left" Height="40" Margin="212,582,0,0" TextWrapping="Wrap" Text="TextBox" VerticalAlignment="Top" Width="188"/>
        <TextBox x:Name="TB_NewGrpDesc" HorizontalAlignment="Left" Height="40" Margin="210,655,0,0" TextWrapping="Wrap" Text="TextBox" VerticalAlignment="Top" Width="240"/>
        <Button x:Name="Btn_AddGrp" Content="Add Group" HorizontalAlignment="Left" Margin="212,715,0,0" VerticalAlignment="Top" Width="90" Height="30"/>


        <Button x:Name="Btn_ClearForm" Content="Clear Form" HorizontalAlignment="Left" Margin="622,826,0,0" VerticalAlignment="Top" Width="75" Height="30"/>
        <Button x:Name="Btn_EXIT" Content="EXIT" HorizontalAlignment="Left" Margin="730,826,0,0" VerticalAlignment="Top" Width="75" Height="30" FontWeight="Bold"/>

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


Function fcn_FinalClose{

	$reader.Close()
	$Form.Close()
}


$Form.ShowDialog() | out-null

$WPF_Btn_Exit.Add_Click({fcn_FinalClose})

# Closes the form
$Form.Add_Closed({fcn_FinalClose})

