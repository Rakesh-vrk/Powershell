
#If you wanted soft-delete option for a specific vault

$vaultId = (Get-AzRecoveryServicesVault -Name "recovery-services" -ResourceGroupName 'frontend-servers-rg').id

(Get-AzRecoveryServicesVaultProperty -VaultId $vaultId).SoftDeleteFeatureState


#If you wanted soft-delete option for all vault 

$vaults = Get-AzRecoveryServicesVault 

foreach($vault in $vaults) { 
    $properties = Get-AzRecoveryServicesVaultProperty -VaultId $vault.Id
    if($properties.SoftDeleteFeatureState -eq 'Enabled') {
        Write-Host "Soft delete feature is" $properties.SoftDeleteFeatureState "for" $vault.Name "`n" `
                -ForeGroundColor Green
    } else {
        Write-Host "Soft delete feature is" $properties.SoftDeleteFeatureState "for" $vault.Name "`n" `
                -ForeGroundColor Red
    }
 }