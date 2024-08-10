#Variables
$resourceGroupName = "example-resources"
$vmName = "old-vm-name"
$newVmName = "new-vm-name"
$location = "West Europe"


# Get the VM
$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName

# Stop the VM
Stop-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -Force

# Deallocate the VM
Stop-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -StayProvisioned -Force

# Get the VM configuration
$vmConfig = New-AzVMConfig -VMSize $vm.HardwareProfile.VmSize -VMName $newVmName

# Set the OS disk
Set-AzVMOSDisk -VM $vmConfig -ManagedDiskId $vm.StorageProfile.OsDisk.ManagedDisk.Id -CreateOption Attach -Windows

# Set the network interface
$nic = Get-AzNetworkInterface -ResourceGroupName $resourceGroupName -Name $vm.NetworkProfile.NetworkInterfaces[0].Id.Split('/')[-1]
Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id

# Remove the old VM
Remove-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -Force

# Create the new VM with the same resources
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig

# Start the new VM
Start-AzVM -ResourceGroupName $resourceGroupName -Name $newVmName
