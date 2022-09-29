$interface = ""
function listarInterfaces {
    param()
    clear
    $adapters = Get-NetAdapter
    for($i = 0; $i -lt $adapters.Length; $i++){
        Write-Host "$($i+1)." $adapters[$i].InterfaceDescription
    }
    Write-Host "                                                "
    Write-Host "                                                "
    $int = Read-Host "Selecciona un adaptador: "    
    $interface = $adapters[$($int-1)].InterfaceDescription
    $global:interfaceIndex = $adapters[$($int-1)].ifIndex
    $global:interfaceName = $adapters[$($int-1)].Name
    inicio
}

function ipPersonalizada {
    param()
    $direccionIp = Read-Host "Introduzca la dirección IP deseada: "
    Write-Host "---------------------------------------------------------"
    $mascara = Read-Host "Introduzca el prefijo de la mascara de subred: "
    Write-Host "---------------------------------------------------------"
    $gateway = Read-Host "Introduzca la puerta de enlace: "
    Write-Host "---------------------------------------------------------"
    if((Get-NetAdapter -Name $interfaceName).Status -eq "Disabled"){
        Get-NetAdapter -Name $interfaceName | Enable-NetAdapter -Confirm:$false
    }
    $route = Get-NetRoute
    for($i = 0; $i -lt $route.length; $i++){
        if($route[$i].ifIndex -eq $interfaceIndex){
            Remove-NetRoute -InterfaceIndex $interfaceIndex -Confirm:$false
        }
    }    
    Remove-NetIpAddress -InterfaceIndex $interfaceIndex -Confirm:$false 
    Set-NetIPInterface -InterfaceIndex $interfaceIndex -Dhcp Disabled   
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\Interfaces\$((Get-NetAdapter -InterfaceIndex $interfaceIndex).InterfaceGuid)" -Name EnableDHCP -Value 0
    New-NetIPAddress -InterfaceIndex $interfaceIndex -IPAddress $direccionIp -PrefixLength $mascara -DefaultGateway $gateway
    Write-Host "---------------------------------------------------------"
    Write-Host "Configuración aplicada..."
    Start-Sleep -Seconds 0.5
    inicio 
}

function ip0 {
    param()
    clear
    $route = Get-NetRoute   
    for($i = 0; $i -lt $route.length; $i++){        
        if($route[$i].ifIndex -eq $interfaceIndex){
            Remove-NetRoute -InterfaceIndex $interfaceIndex -Confirm:$false
        }
    }    
    Remove-NetIpAddress -InterfaceIndex $interfaceIndex -Confirm:$false 
    Set-NetIPInterface -InterfaceIndex $interfaceIndex -Dhcp Disabled   
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\Interfaces\$((Get-NetAdapter -InterfaceIndex $interfaceIndex).InterfaceGuid)" -Name EnableDHCP -Value 0
    New-NetIPAddress -InterfaceIndex $interfaceIndex -IPAddress 192.168.0.50 -PrefixLength 24 -DefaultGateway 192.168.0.1
    Write-Host "---------------------------------------------------------"
    Write-Host "Configuración aplicada..."
    Start-Sleep -Seconds 0.5
    inicio
}

function ip1 {
    param()
    clear
    $route = Get-NetRoute
    for($i = 0; $i -lt $route.length; $i++){
        if($route.ifIndex -eq $interfaceIndex){
            Remove-NetRoute -InterfaceIndex $interfaceIndex -Confirm:$false
        }
    }    
    Remove-NetIpAddress -InterfaceIndex $interfaceIndex -Confirm:$false 
    Set-NetIPInterface -InterfaceIndex $interfaceIndex -Dhcp Disabled   
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\Interfaces\$((Get-NetAdapter -InterfaceIndex $interfaceIndex).InterfaceGuid)" -Name EnableDHCP -Value 0
    New-NetIPAddress -InterfaceIndex $interfaceIndex -IPAddress 192.168.1.50 -PrefixLength 24 -DefaultGateway 192.168.1.1
    Write-Host "---------------------------------------------------------"
    Write-Host "Configuración aplicada..."
    Start-Sleep -Seconds 0.5
    inicio
}

function restaurarDhcp {
    param()
    clear
    $route = Get-NetRoute
    for($i = 0; $i -lt $route.length; $i++){
    if($route[$i].ifIndex -eq $interfaceIndex){
            Remove-NetRoute -InterfaceIndex $interfaceIndex -Confirm:$false
        }
    }     
    Remove-NetIpAddress -InterfaceIndex $interfaceIndex -Confirm:$false    
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\Interfaces\$((Get-NetAdapter -InterfaceIndex $interfaceIndex).InterfaceGuid)" -Name EnableDHCP -Value 1
    Set-NetIPInterface -InterfaceIndex $interfaceIndex -Dhcp Enabled  
    Write-Host "---------------------------------------------------------"
    Write-Host "Configuración aplicada..."
    Start-Sleep -Seconds 1
    inicio
}


function configurarIp {
    param()
    clear
    Write-Host "#####################################################################"
    Write-Host ""
    Write-Host ""
    Write-Host "                        Configurar IP                                "
    Write-Host ""
    Write-Host ""
    Write-Host "#####################################################################"
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host "Interfaz Seleccionada: "$interface
    Write-Host ""
    Write-Host "1. Configurar Ip personalizada"
    Write-Host "2. Configurar IP 192.168.0.50"
    Write-Host "3. Configurar IP 192.168.1.50"
    Write-Host "4. Restaurar configuración por DHCP"
    Write-Host "5. Volver"
    Write-Host ""
    Write-Host "________________________"
    $opt = Read-Host "Elige una opción: "
    Write-Host "________________________"
    Write-Host ""
    Write-Host ""
    Write-Host ""    
    switch($opt){
        1 { ipPersonalizada }
        2 { ip0 }
        3 { ip1 }
        4 { restaurarDhcp }
        5 { volver }
    }
}

function configurarVlan {
    param()
    clear
    $vlanId = Read-Host "Introduzca la dirección VlanId deseada: "
    Write-Host "---------------------------------------------------------"
    Set-NetAdapterAdvancedProperty -Name $interfaceName -DisplayName "Vlan Id" -DisplayValue $vlanId
    Write-Host "---------------------------------------------------------"
    Write-Host "Configuración aplicada..."
    Start-Sleep -Seconds 1
    inicio
}

function restaurarVlan {
    param()
    clear
    Set-NetAdapterAdvancedProperty -Name $interfaceName -DisplayName "Vlan Id" -DisplayValue 0
    Write-Host "---------------------------------------------------------"
    Write-Host "Configuración aplicada..."
    Start-Sleep -Seconds 1
    inicio
}

function inicio{
    param()
    clear
    Write-Host "#####################################################################"
    Write-Host ""
    Write-Host ""
    Write-Host "                             Menu                                    "
    Write-Host ""
    Write-Host ""
    Write-Host "#####################################################################"
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host "Interfaz Seleccionada: "$interface
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host "1. Listar Adaptadores de Red"
    Write-Host "2. Configurar IP Adaptador Seleccionado"
    Write-Host "3. Congigurar Vlan Adaptador Seleccionado"
    Write-Host "4. Restaurar configuración por DHCP"
    Write-Host "5. Restaurar configuración Vlan"
    Write-Host "6. Salir"
    Write-Host ""
    Write-Host ""
    Write-Host "#####################################################################"
    Write-Host ""
    $opt = Read-Host "Elige una opción: "
    Write-Host ""
    Write-Host ""    
    Write-Host ""
    Write-Host ""
    switch($opt){
        1 { listarInterfaces }
        2 { configurarIP }
        3 { configurarVlan }
        4 { restaurarDhcp }
        5 { restaurarVlan }
        6 { salir }
    }
}
inicio
$salida = Read-Host "Press 0 to Exit or 1 to Continue"
switch($salida){
    0 { salir }
    1 { inicio }
}





