

function Create-User {

    $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
    $PasswordProfile.Password = "&yhngs6790#TG"

    New-AzureADUser -DisplayName "New User2" -PasswordProfile $PasswordProfile -UserPrincipalName "NewUser2@hopesthoughts.blog" -AccountEnabled $true -MailNickName "Newuser" -UsageLocation "US" 


}
Create-User
