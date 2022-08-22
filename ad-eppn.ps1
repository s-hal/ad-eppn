param (
    [Parameter(
        Mandatory,
        HelpMessage="The name of the attribute that holds the ePPN"
    )]
    [string]$Attribute,
    [Parameter(
        Mandatory,
        HelpMessage="Specifies an Active Directory path to search under"
    )]
    [ValidateScript({[adsi]::Exists("LDAP://$_")})]
    [string]$SearchBase,
    [Parameter(
        Mandatory,
        HelpMessage="The length of the ePPN i.e, EppnLen 3, will generate ePPN's from 001 to zzz"
    )]
    [int]$EppnLen,
    [Parameter(
        HelpMessage='If set, the value "@$Scope" will be appended to the ePPN'
    )]
    [string]$Scope
)

$DebugPreference = "Continue"

function IncStr
{
    [CmdletBinding()]
    param ([string]$eppnPre="")

    $alphabet = "0123456789abcdefghijklmnopqrstuvwxyz"
    $alen = $alphabet.Length - 1
    $incremented = ""
    foreach ($i in $eppnPre.tolower()[$eppnPre.length..0])
    {
        $count++
        $index = $alphabet.IndexOf($i)
        if ($alphabet.IndexOf($i) -eq $alen)
        {
            $index = 0
        } else {
            $incremented = $eppnPre.Substring(0, $eppnPre.Length - $count) + $alphabet.Substring($index +1 ,1) + $incremented
            break
        }
        $incremented = $alphabet.Substring($index,1)+$incremented
        if ($count -eq $eppnPre.length)
        {
            $incremented = $alphabet.Substring(1,1)+$incremented
        }

    }
    $incremented
}

$newUsers = Get-ADUser -Filter {-not($Attribute -like "*")} -Properties $Attribute -SearchBase $SearchBase -ErrorAction Stop
if ($newUsers) {
    $users = Get-ADUser -Filter '$Attribute -like "*"' -Properties $Attribute | Select-Object $Attribute
    $eppn = "0"
    $users | ForEach-Object {
        $prefix = ($_.$Attribute -split "@")[0]
        if ($prefix -gt $eppn) {
            $eppn = $prefix
        }
    }
    $newUsers  | ForEach-Object {
        $eppn = (IncStr -eppnPre $eppn).PadLeft($EppnLen,'0')
        if ($eppn.Length -gt $EppnLen){
            throw "ePPN lenght overflows EppnLen: $EppnLen"
        }
        if ($Scope) {
            $params= @{"Identity" = $_
            $Attribute = "$eppn@$Scope"}
        } else {
            $params= @{"Identity" = $_
            $Attribute = $eppn}
         }
        Set-ADUser @params
	    Write-Debug "Added $eppn"
    }
    Write-Debug "New Users added"
}
