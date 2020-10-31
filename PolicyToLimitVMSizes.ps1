$a = (Get-AzSubscription).Id

$policyJSON = @'
  {
    "if": {
        "allOf": [
           {
                "field": "type",
                "equals": "Microsoft.Compute/virtualMachines"
           },
           {
                "not": {
                    "field": "Microsoft.Compute/virtualMachines/sku.name",
                    "in" : ["Standard_D1", "Standard_D2", "Standard_DS2", "Basic_A0", "Basic_A1", "Basic_A2", "Standard_A0", "Standard_A1", "Standard_A2", "Standard_A5", "Standard_DS1_v2", "Standard_DS2_v2", "Standard_B2s", "Standard_B2ms", "Standard_B1s", "Standard_B1ms", "Standard_B1ls", "Standard_F1s", "Standard_F2s", "Standard_D2s_v3"]
                }
           }
        ]
    },
    "then": {
        "effect": "deny"
    }
  }
'@

$policy = New-AzPolicyDefinition -Name 'VMSizeRestriction' -DisplayName 'VM Size Restrictions by VRK' -Policy $policyJSON

New-AzPolicyAssignment -Name 'VMSizeRestrictionToSubscription' -PolicyDefinition $policy -Scope "/subscriptions/$a"