Add-Type -AssemblyName System.Windows.Forms | Out-Null

$form = New-Object Windows.Forms.Form
$form.AutoSize = $true
$form.AutoSizeMode = 'GrowAndShrink'

$form.Text = 'Window Title'

$label = New-Object Windows.Forms.Label
$label.Text = 'some text'
$label.AutoSize = $true
$form.Controls.Add($label)

$form.ShowDialog()