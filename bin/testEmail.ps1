$Outlook = New-Object -ComObject Outlook.Application
$Mail = $Outlook.CreateItem(0)

$Mail.To = 'justin_urbanek@sluz.ch' 
$Mail.Subject = 'PowerShell Test Mail'
$Mail.Body = 'it just works fvhsefiefhweohfowehfowehfowho'

$Mail.Send()

$Outlook.Quit()