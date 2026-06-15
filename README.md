# ADNK
AnyDesk Nag Killer gets rid of that stupid fucking 90 second nag screen that wont let you use the app until you physically wait 90 seconds. Even when you use the app in a reasonable single personal use manner, this message will rear its ugly fucking head into your life. 

Either download and run the script, or, use this convenient one liner:

`irm https://s.hfnp.dev/ADNK | iex`

And press any key and let it rip.

There is a lot of fluff in the script to make it pretty, if you just want to know how to do it yourself, it is simply a self elevating powershell script with flashy colors that runs the following commands:

Stop process:
`Stop-Process -Name AnyDesk -Force`

Delete data from ProgramData:
`$anyDeskData = Join-Path $env:ProgramData 'AnyDesk'`
`Remove-Item -Path (Join-Path $anyDeskData 'service*'), (Join-Path $anyDeskData 'system*') -Force`

Relaunch process:
`$anyDeskExe = "C:\Program Files (x86)\AnyDesk\AnyDesk.exe"`
`Start-Process -FilePath $anyDeskExe`
