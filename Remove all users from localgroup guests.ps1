<#
    .SYNOPSIS
        Dit script verwijdert alle gebruikers uit de gastgroep op de lokale machine.

    .DESCRIPTION
        Het script maakt gebruik van het 'LocalGroup' cmdlet om alle gebruikers uit de gastgroep op de lokale machine te verwijderen.

    .AUTHOR
        Fabio van der Burg

    .DATE
        19 april 2023
#>

# Parameters
$guestGroupName = "Guests"

try {
    # Controleer of de gastgroep bestaat
    $guestGroup = Get-LocalGroup -Name $guestGroupName -ErrorAction Stop

    # Haal alle leden van de gastgroep op
    $guestGroupMembers = Get-LocalGroupMember -Group $guestGroupName

    # Verwijder alle leden uit de gastgroep
    foreach ($member in $guestGroupMembers) {
        Write-Host "Removing $($member.Name) from $guestGroupName group"
        Remove-LocalGroupMember -Group $guestGroup -Member $member.Name -ErrorAction Stop
    }

    Write-Host "All users removed from $guestGroupName group successfully."

} catch {
    Write-Host "Error: $($_.Exception.Message)"
}
