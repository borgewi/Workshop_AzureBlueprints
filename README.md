# Workshop_AzureBlueprints

## Før du starter
Før du begynner må du:
1. Installer powershellmoduler: 
    1. Install-Module -Name Az -Repository PSGallery -AllowClobber -Force
    2. Install-Module -Name Az.Blueprint -AllowClobber -Force
2. Opprett en Service Principal
    1. I Azureportalen, naviger til Active Directory --> App Registrations 
    2. Klikk på "New registration" 
    3. Gi den et navn og klikk "Register"
    4. Gå inn i application du nettopp lagde og trykk "Certificates & secrets" 
    5. Klikk "New client secret" og gi den et navn under "Description".
    6. En ny secret dukker opp. Verdien under "Value" vil ikke vises igjen, så kopier og lagre denne et sted. Den skal brukes i scriptene i workshopen.
3. Gi din nye Service Principal owner-rettigheter på din subscription (Subscriptions --> Access Control --> Role Assignments) 

## Oppgave
I denne workshopen skal du lage, publisere og assigne et blueprint ved hjelp av powershell. Blueprintet inneholder et Virtual Network, et subnet og en Network Security Group.

Naviger til "Oppgave" og fullfør avsnittene med "TODOs" i scriptene. 

* Begynn med scriptet "createAndPublishBlueprint.ps1". Det importerer blueprintdefinisjonen og artifaktene til Azure og "oppretter" blueprintet.
* Gå deretter løs på scriptet "assignBlueprint.ps1". Dette oppretter ressursene i Azure i henhold til blueprintet. 

Dersom du står fast kan du se hvordan det er satt opp i "Solution". 

Guide på hvordan finne diverse parametre:


* tenant id: Når du er i Azureportalen, naviger til Azure Directory -> Properties og benytt "Directory ID".
* subscription id: Når du er i Azureportalen, naviger til Subscriptions og les av subscription ID på din subscription. Husk at Service Principal må ha owner-rettigheter på denne. 
