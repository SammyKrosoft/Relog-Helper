Function Update-CommandLine {
    if ($wpf.txtBLGFileName.text -eq "Select File To Load")
    {
        $global:CommandLineValid = $false
    } Else {
        if ($wpf.txtOutputFolder.text -notmatch "\\$"){$wpf.txtOutputFolder.text = $wpf.txtOutputFolder.text + '\'}
        $DateTimeTag = Get-Date -F ddMMyyyy_hhmmss
        $wpf.lblOutputFileExtention.content = $DateTimeTag + ".CSV"
        $strCommand = ('relog.exe ') + ('"') + ($wpf.txtBLGFileName.text) + ('"') + (' -f CSV -o ') + ('"') + ($wpf.txtOutputFolder.text) + ($wpf.txtOutputFileName.text) + ('_') + $DateTimeTag + ('.csv"')
        $global:CommandLineValid = $true
        $wpf.txtCmd.Text = $strCommand
    
        if (($global:CommandLineValid) -and ($global:ExecExist)){
            $wpf.btnRun.IsEnabled = $true
            $wpf.graphBusy.Visibility = "Hidden"
            $wpf.graphReady.Visibility = "Visible"
            $wpf.graphGrey.Visibility = "Hidden"
        } Else {
            $wpf.btnRun.IsEnabled = $false
            $wpf.graphBusy.Visibility = "Hidden"
            $wpf.graphReady.Visibility = "Hidden"
            $wpf.graphGrey.Visibility = "Visible"
        }
    }
}


Function Check-Exec {
    $FileExists = Test-Path $(($wpf.txtExecLocation.text) + ("\relog.exe"))
    If ($FileExists){
        $global:ExecExist = $true
        $wpf.lblExecStatus.Content = "Executable is there !"
        $wpf.lblExecStatus.Foreground = "Green"
    } Else {
        $global:ExecExist = $false
        $wpf.lblExecStatus.Content = "Executable is missing ... try another path and click the [Check] button "
        $wpf.lblExecStatus.Foreground = "Red"
    }

    if (($global:CommandLineValid) -and ($global:ExecExist)){
        $wpf.btnRun.IsEnabled = $true
        $wpf.graphBusy.Visibility = "Hidden"
        $wpf.graphReady.Visibility = "Visible"
        $wpf.graphGrey.Visibility = "Hidden"
    } Else {
        $wpf.btnRun.IsEnabled = $false
        $wpf.graphBusy.Visibility = "Hidden"
        $wpf.graphReady.Visibility = "Hidden"
        $wpf.graphGrey.Visibility = "Visible"
    }

}

# Load a WPF GUI from a XAML file build with Visual Studio
Add-Type -AssemblyName presentationframework, presentationcore
$wpf = @{ }
# NOTE: Either load from a XAML file or paste the XAML file content in a "Here String"
#$inputXML = Get-Content -Path ".\WPFGUIinTenLines\MainWindow.xaml"
$inputXML = @"
<Window x:Name="frmRelogExec" x:Class="Launch_Y_CMD.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:Launch_Y_CMD"
        mc:Ignorable="d"
        Title="Relog.exe command generator" Height="450" Width="800">
<Grid>
    <Button x:Name="btnRun" Content="Relog !" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75" Margin="10,216,0,0"/>
    <TextBox x:Name="txtCmd" HorizontalAlignment="Left" Height="43" Margin="10,163,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="744" IsReadOnly="True" Background="Black" Foreground="Yellow"/>
    <TextBox x:Name="txtExecLocation" HorizontalAlignment="Left" Height="49" Margin="326,291,0,0" TextWrapping="Wrap" Text="C:\Windows\System32" VerticalAlignment="Top" Width="294" IsReadOnly="True"/>
    <Label x:Name="lbl3" Content="Location of relog.exe:" HorizontalAlignment="Left" Margin="326,260,0,0" VerticalAlignment="Top"/>
    <Button x:Name="btnCheckExec" Content="Check" HorizontalAlignment="Left" Margin="326,345,0,0" VerticalAlignment="Top" Width="75"/>
    <Label x:Name="lblExecStatus" Content="Label" HorizontalAlignment="Left" Margin="326,370,0,0" VerticalAlignment="Top"/>
    <Ellipse x:Name="graphReady" Fill="Green" HorizontalAlignment="Left" Height="100" Margin="87,265,0,0" Stroke="Black" VerticalAlignment="Top" Width="100" Visibility="Hidden"/>
    <Ellipse x:Name="graphGrey" Fill="Gray" HorizontalAlignment="Left" Height="100" Margin="87,265,0,0" Stroke="Black" VerticalAlignment="Top" Width="100"/>
    <Rectangle x:Name="graphBusy" Fill="Red" HorizontalAlignment="Left" Height="100" Margin="87,265,0,0" Stroke="Black" VerticalAlignment="Top" Width="100" Visibility="Hidden"/>
    <TextBox x:Name="txtOutputFolder" HorizontalAlignment="Left" Height="23" Margin="124,122,0,0" TextWrapping="Wrap" Text="C:\temp" VerticalAlignment="Top" Width="496" IsReadOnly="True"/>
    <Label x:Name="lbl2" Content="Output location" HorizontalAlignment="Left" Margin="10,119,0,0" VerticalAlignment="Top" Width="95"/>
    <Button x:Name="btnLoadBLG" Content="Load BLG" HorizontalAlignment="Left" Margin="21,21,0,0" VerticalAlignment="Top" Width="84" Height="43"/>
    <TextBox x:Name="txtBLGFileName" HorizontalAlignment="Center" Height="43" Margin="124,21,172,0" TextWrapping="Wrap" Text="Select File To Load" VerticalAlignment="Top" Width="496" VerticalContentAlignment="Center" IsReadOnly="True"/>
    <Label x:Name="lbl1" Content="Output File Name" HorizontalAlignment="Left" Margin="10,87,0,0" VerticalAlignment="Top" Height="27" Width="109"/>
    <TextBox x:Name="txtOutputFileName" HorizontalAlignment="Left" Height="28" Margin="124,86,0,0" TextWrapping="Wrap" Text="Output File Name" VerticalAlignment="Top" Width="202" VerticalContentAlignment="Center"/>
    <Label x:Name="lblOutputFileExtention" Content=".CSV" HorizontalAlignment="Left" Margin="342,88,0,0" VerticalAlignment="Top"/>
</Grid>
</Window>
"@

$inputXMLClean = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace 'x:Class=".*?"','' -replace 'd:DesignHeight="\d*?"','' -replace 'd:DesignWidth="\d*?"',''
[xml]$xaml = $inputXMLClean
$reader = New-Object System.Xml.XmlNodeReader $xaml
$tempform = [Windows.Markup.XamlReader]::Load($reader)
$namedNodes = $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")
$namedNodes | ForEach-Object {$wpf.Add($_.Name, $tempform.FindName($_.Name))}

#Get the form name to be used as parameter in functions external to form...
$FormName = $NamedNodes[0].Name
# write-host $FormName
# exit
#Define events functions
#region Load, Draw (render) and closing form events
#Things to load when the WPF form is loaded aka in memory
$wpf.$FormName.Add_Loaded({
    #Update-Cmd
})
#Things to load when the WPF form is rendered aka drawn on screen
$wpf.$FormName.Add_ContentRendered({
    Update-CommandLine
    Check-Exec
})
$wpf.$FormName.add_Closing({
    $msg = "bye bye !"
    write-host $msg
})
#endregion Load, Draw and closing form events
#End of load, draw and closing form events

#region buttons events
#endregion button events
#End of button events

#region text box events
$wpf.btnRun.add_click({
    Check-Exec #check if relog.exe has not been modified last minute (bruh ?))
    If ($global:ExecExist) {
        Update-CommandLine 
        #[string]$CommandWithFullPath = ("cmd.exe /C ") + ('"') + ($wpf.txtExecLocation.text) + ('\') + ($wpf.txtCmd.Text) + ('"')
        [string]$CommandWithFullPath = ($wpf.txtExecLocation.text) + ('\') + ($wpf.txtCmd.Text)
        $wpf.graphBusy.Visibility = "Visible"
        $wpf.graphReady.Visibility = "Hidden"
        $wpf.graphGrey.Visibility = "Hidden"
        $wpf.$FormName.IsEnabled = $false
        $wpf.$FormName.Dispatcher.Invoke("Render",[action][scriptblock]{})

        Invoke-Expression "cmd /C $CommandWithFullPath"

        $wpf.$FormName.IsEnabled = $true
        $wpf.graphBusy.Visibility = "Hidden"
        $wpf.graphReady.Visibility = "Visible"
        $wpf.graphGrey.Visibility = "Hidden"
        $wpf.$FormName.Dispatcher.Invoke("Render",[action][scriptblock]{})
    }
})

$wpf.btnLoadBLG.add_Click({
    $wpf.graphBusy.Visibility = "Visible"
    $wpf.graphReady.Visibility = "Hidden"
    $wpf.graphGrey.Visibility = "Hidden"
    $wpf.$FormName.IsEnabled = $false
    $wpf.$FormName.Dispatcher.Invoke("Render",[action][scriptblock]{})

    $OpenFileDialog = New-Object Microsoft.Win32.OpenFileDialog
    #$OpenFileDialog.FileName = $wpf.txtBLGFileName.Text
    $OpenFileDialog.DefaultExt = ".blg"
    $OpenFileDialog.Filter = "blg files (.blg)|*.blg"
    #$OpenFileDialog.InitialDirectory = $PSScriptRoot
    $OpenFileDialog.InitialDirectory = "$($env:userprofile)\Documents"
    $Result = $OpenFileDialog.ShowDialog()
    if ($Result) {
        $FileName = $OpenFileDialog.FileName
        #$SimpleFileName = Split-Path -Leaf -Path $FileName
        $wpf.txtBLGFileName.text = $FileName
    }

    Update-CommandLine

    $wpf.$FormName.IsEnabled = $true
    $wpf.graphBusy.Visibility = "Hidden"
    $wpf.graphReady.Visibility = "Visible"
    $wpf.graphGrey.Visibility = "Hidden"
    $wpf.$FormName.Dispatcher.Invoke("Render",[action][scriptblock]{})
 
})

$wpf.txtOutputFileName.add_TextChanged({
    Update-CommandLine
})

$wpf.txtOutputFolder.add_TextChanged({
    Update-CommandLine
})

$wpf.btnCheckExec.add_Click({
    Check-Exec
})
#endregion text box events
#End of text box events


#HINT: to update progress bar and/or label during WPF Form treatment, add the following:
# ... to re-draw the form and then show updated controls in realtime ...
$wpf.$FormName.Dispatcher.Invoke("Render",[action][scriptblock]{})


# Load the form:
# Older way >>>>> $wpf.MyFormName.ShowDialog() | Out-Null >>>>> generates crash if run multiple times
# Newer way >>>>> avoiding crashes after a couple of launches in PowerShell...
# USing method from https://gist.github.com/altrive/6227237 to avoid crashing Powershell after we re-run the script after some inactivity time or if we run it several times consecutively...
$async = $wpf.$FormName.Dispatcher.InvokeAsync({
    $wpf.$FormName.ShowDialog() | Out-Null
})
$async.Wait() | Out-Null