# AD-ePPN

This is a sample script for adding eduPersonPrincipalName (ePPN) to users in Active Directory. The script assigns ePPN to users where the attribute is empty. The script check the AD for the highest assigned ePPN, increments it, and then assign the new ePPN. This script can be run manually or as a scheduled job. Do not execute more than one instance of the script at a time for the same SearchBase to avoid race conditions

The script creates a Base36 number (alphanumeric) that is stored as a string, padding the string left with zeros for sorting. ePPN is incremented for every new user. If we use a length of 6 (36^6), that gives us 2176782336 ePPN's before overflow occurs. Either append the scope, a owned domain, before storing the ePPN or do it later e.g., in the IdP.

## Parameters

- **Attribute \<String\>**  
REQUIRED. The name of the attribute that holds the ePPN
- **SearchBase \<String\>**  
REQUIRED. Specifies an Active Directory path to search under
- **EppnLen \<Int\>**  
REQUIRED. The length of the ePPN i.e, EppnLen 3, will generate ePPN's from 001 to zzz
- **Scope \<String\>**  
OPTIONAL. If set, the value "@$Scope" will be appended to the ePPN

## Execution

Exampel of how to execute the script.

ad-eppn.ps1 -Attribute eduPersonPrincipalName -SearchBase "OU=Pupils,DC=example,DC=com" -EppnLen 6 -Scope exampel.com
