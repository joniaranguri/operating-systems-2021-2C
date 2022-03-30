# APL N2 Ejercicio 6 (Primer entrega)
# Script: ej-6.ps1
# Integrantes:
# ARANGURI JONATHAN ENRIQUE                  40.672.991	

<# Desarrollar un script que funcione como calculadora, permitiendo al usuario resolver las operaciones
matemáticas más básicas: suma, resta, multiplicación y división.
El script debe recibir los siguientes parámetros:
• -n1 nnnn: Primer operando. Parámetro obligatorio.
• -n2 nnnn: Segundo operando. Parámetro obligatorio.
• -suma: Parámetro tipo switch que indica que se realizará la operación n1+n2.
• -resta: Parámetro tipo switch que indica que se realizará la operación n1-n2.
• -multiplicacion: Parámetro tipo switch que indica que se realizará la operación n1*n2.
• -division: Parámetro tipo switch que indica que se realizará la operación n1/n2.
A tener en cuenta:
• Se debe validar que no se ingresen parámetros para realizar dos operaciones de manera
simultánea.
• Los operandos pueden ser cualquier número real, es decir, se incluyen números negativos,
positivos, cero y con decimales.
• Se debe validar que el operando 2 (n2) no sea cero cuando se está por ejecutar una
división.
Criterios de corrección:
Control Criticidad
Funciona correctamente según enunciado Obligatorio
Se validan los parámetros dentro del bloque Param Obligatorio
El script ofrece ayuda con Get-Help Obligatorio
Se utiliza ParameterSetName como parte de las validaciones de los
parámetros
Obligatorio
Funciona correctamente según enunciado Obligatorio
Se implementan funciones Deseable #>

<#
    .SYNOPSIS
    
 	Given two numbers, perform the specified operation.  
	 
    .DESCRIPTION
    
 	Given two numbers, perform the specified operation.  
    
    .EXAMPLE
    
        Option 1) ./ej-6.ps1 -n1 5 -n2 2.5 -suma
        Option 2) ./ej-6.ps1 -n1 5 -n2 2.5 -resta
        Option 3) ./ej-6.ps1 -n1 5 -n2 2.5 -division
        Option 4) ./ej-6.ps1 -n1 5 -n2 2.5 -multiplicacion
        
    .PARAMETER n1
    	The first number to use
    .PARAMETER n2 
    	The second number to use
    .PARAMETER [suma | resta | multiplicacion | division ]
   	    The name of the operation to be performed.
#>

Param
(
    [Parameter(ParameterSetName ='suma')]
    [switch] $suma,
    [Parameter(ParameterSetName ='resta')]
    [switch] $resta,
    [Parameter(ParameterSetName ='multiplicacion')]
    [switch] $multiplicacion,
    [Parameter(ParameterSetName ='division')]
    [ValidateScript( { if(($_  -and $n2 -eq 0) ){ throw "Cannot divide by 0." }else{ $true }})]
    [switch] $division,
    
    [Parameter(ParameterSetName ='division', Mandatory=$true)]
    [Parameter(ParameterSetName ='multiplicacion', Mandatory=$true)]
    [Parameter(ParameterSetName ='resta', Mandatory=$true)]
    [Parameter(ParameterSetName ='suma', Mandatory=$true)]
    [float]$n1,

    [Parameter(ParameterSetName ='division', Mandatory=$true)]
    [Parameter(ParameterSetName ='multiplicacion', Mandatory=$true)]
    [Parameter(ParameterSetName ='resta', Mandatory=$true)]
    [Parameter(ParameterSetName ='suma', Mandatory=$true)]
    [float]$n2
)

function performOperation(){
    if($suma){performSuma}
    if($resta){performResta}
    if($division){performDivision}
    if($multiplicacion){performMultiplicacion}
}
function performSuma {
  $result = $n1 + $n2
  Write-Host "$n1 + $n2 = $result"
}
function performResta {
    $result = $n1 - $n2
    Write-Host "$n1 - $n2 = $result"
}
function performDivision {
    $result = $n1 / $n2
    Write-Host "$n1 / $n2 = $result"
}
function performMultiplicacion {
    $result = $n1 * $n2
    Write-Host "$n1 * $n2 = $result"
}

performOperation
