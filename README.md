# Workshop_AzureBlueprints

## Før du starter
Før du begynner må du:
1. Installer powershellmoduler: 
  i. Install-Module -Name Az -Repository PSGallery -AllowClobber -Force
  ii. Install-Module -Name Az.Blueprint -AllowClobber -Force
2. Opprett en Service Principal
  i. Gi den owner-rettigheter på din subscription (Subscriptions --> Access Control --> Role Assignments)
 
## Oppgave
Naviger til "Oppgave" og fullfør avsnittene med "TODOs" i scriptene. 

* Begynn med scriptet "createAndPublishBlueprint.ps1". Det importerer blueprintdefinisjonen og artifaktene til Azure og "oppretter" blueprintet.
* Gå deretter løs på scriptet "assignBlueprint.ps1". Dette assigner blueprintet ressursene i Azure. 

Dersom du står fast kan du se hvordan det er satt opp i "Solution". 
