# Proyecto Final: Electrónica Digital

## Integrantes del Equipo
| Nombre Completo | Identificación (SIA) |
|-----------------|----------------------|
| Mario José Riaño Galán      | 1029660086 |
| Juan Camilo Morales Hernández     | 1104545232            |
|  Isaias David Gallardo Felizzola   | 1042247018            |


---

## Tabla de Contenido
1. [Multiplicador](#1-multiplicador)
2. [Divisor](#2-divisor)
3. [Raíz Cuadrada](#3-raíz-cuadrada)
4. [Convertidor Binario a BCD](#4-convertidor-binario-a-bcd)
5. [Calculadora](#5-calculadora)
6. [Proyecto](#6-proyeccto)
---

## 1. Multiplicador

### Especificaciones Iniciales
Descripción breve de los bits de entrada, salida y el método utilizado (ej: Algoritmo de Booth o Sumas sucesivas).

### Diseño del Sistema
#### Diagrama de Flujo (Algoritmo)
![Diagrama de Flujo Multiplicador](./assets/mult_flujo.png)

#### Diagrama de Bloques (Camino de Datos)
![Datapath Multiplicador](01_Multiplicador/src/Multiplica/IMAGEN/dataPath_MUL.png)

#### Máquina de Estados (Control)
![Diagrama de Estados del Multiplicador](01_Multiplicador/src/Multiplica/IMAGEN/ESTADOS_MUL.png)


### Implementación

* **Codigo:** [Codigo Multiplicación](01_Multiplicador/src/Multiplica/)


### Simulación
La figura muestra la simulación temporal del módulo RTL de multiplicación para la operación $247 \times 127$.Inicialización: Tras un pulso de reset (rst) y la activación de la señal de inicio (init), el módulo carga los operandos $A=247$ y $B=127$, y la máquina de estados pasa al estado de inicio (state=1).

El cálculo se realiza mediante un algoritmo de multiplicación por shift-and-add. Se observa un bucle de estados (state transiciona entre 1, 3, 2, 3) que se repite 8 veces (o el número de bits del multiplicador B). Las señales de control add (suma) y sh (desplazamiento) se activan de forma síncrona con el reloj (clk) para realizar las sumas parciales y los desplazamientos necesarios. El registro de producto parcial (pp[31:0]) refleja el resultado acumulado en cada ciclo, pasando por valores intermedios como 741, 1729, 3705, etc.

Una vez completadas las iteraciones, la máquina de estados transiciona al estado final (state=4), y la señal done se activa. El resultado final se encuentra disponible en el registro pp[31:0], mostrando el valor correcto de 31369 ($247 \times 127$).
![Simulación del Multiplicador](Simu/Sim_Mul.png)

### Pruebas en FPGA
[Ver Video de Funcionamiento en YouTube](LINK_DEL_VIDEO_AQUI)

---

## 2. Divisor

### Especificaciones Iniciales
* **Entradas:**
    * `Dividendo`: Número binario de *N* bits (ej. 8 bits).
    * `Divisor`: Número binario de *M* bits (ej. 4 bits).
    * `Start`: Señal de inicio de operación.
* **Salidas:**
    * `Cociente`: Resultado entero de la división.
    * `Residuo`: El resto de la operación.
    * `Done/Ready`: Señal que indica que la operación ha terminado.
* **Método:** (Indica aquí el algoritmo usado, ej: *Algoritmo de Restauración / Restoring Division* o *Desplazamiento y Resta*).

### Diseño del Sistema

#### Diagrama de Flujo (Algoritmo)
*Describe la lógica de pasos: Cargar registros, desplazar a la izquierda, restar divisor, verificar signo, decidir si restaurar o no.*
![Flujo_div](02_Divisor/src/Divide%20/IMG/Flujo_div.png)


#### Diagrama de Bloques (Camino de Datos)
*Muestra los registros (A, Q, M), la ALU (restador) y los multiplexores.*
![datapath_div](02_Divisor/src/Divide%20/IMG/datapath_div.png)


#### Máquina de Estados (Control)
*Diagrama de la FSM que controla los desplazamientos y las restas (Estados: IDLE, SHIFT, SUB, RESTORE, END).*
![Estados_div](02_Divisor/src/Divide%20/IMG/Estados_div.png)


### Implementación
El código fuente está separado en unidad de control y camino de datos para modularidad.
* **Camino de Datos (Datapath):** [Ver Código](./02_Divisor/src/datapath.v)
* **Unidad de Control:** [Ver Código](./02_Divisor/src/control_unit.v)
* **Módulo Superior (Top):** [Ver Código](./02_Divisor/src/top_divisor.v)

### Simulación
Se realizó una simulación comportamental para verificar casos de prueba, incluyendo la división por cero (si tu circuito la maneja).
* **Caso de prueba:** Dividendo = 13 (1101), Divisor = 4 (0100) → Cociente = 3, Residuo = 1.
![Simulación del Divisor](Simu/SimM_div.png)



---

## 3. Raíz Cuadrada

### Especificaciones Iniciales
* **Entrada:** Número binario de *N* bits (ej: 16 bits).
* **Salida:** Parte entera de la raíz (*N/2* bits) y residuo.
* **Método:** (Ej: Algoritmo non-restoring o de sustracción iterativa).

### Diseño del Sistema
#### Diagrama de Flujo (Algoritmo)
![Flujo Sqrt](03_RaizCuadrada/src/Raiz/IMG/flujo_sqrt.png)



#### Diagrama de Bloques (Camino de Datos)
![Datapath Sqrt](03_RaizCuadrada/src/Raiz/IMG/Datapath_sqrt.png)



#### Máquina de Estados (Control)
![FSM Raíz](./assets/sqrt_fsm.png)

### Implementación
* **Camino de Datos:** [Ver Código](./03_Raiz_Cuadrada/src/datapath.v)
* **Unidad de Control:** [Ver Código](./03_Raiz_Cuadrada/src/control_unit.v)

### Simulación
Descripción de la prueba: *Se verifica la raíz de 144 (resultado 12) y 150 (resultado 12, residuo 6).*
![Simulación de la Raíz Cuadrada](Simu/Sim_sqrt.png)


---

## 4. Convertidor Binario a BCD

### Especificaciones Iniciales
* **Propósito:** Convertir el resultado binario para visualizarlo en los displays de 7 segmentos.
* **Método:** (Ej: Algoritmo Shift-Add-3 / Double Dabble).

### Diseño del Sistema
#### Diagrama de Flujo
![Flujo Doble BCD](04_Binario_BCD/src/Bin---%3EBCD/IMG/double_flujo.png)



#### Diagrama de Bloques
![Datapath Doble BCD](04_Binario_BCD/src/Bin---%3EBCD/IMG/data_double.png)



#### Máquina de Estados
*(Si aplica, o explicar si es un diseño iterativo)*
![FSM Bin2BCD](./assets/bin2bcd_fsm.png)

### Implementación
* **Código Fuente:** [Ver Código](./04_Binario_BCD/src/bin_to_bcd.v)

### Simulación
![Simulación binario a BCD](Simu/Sim_double.png)

---

## 5. Calculadora (Integración Final)

)

### Código Fuente (Top Module)
* **Archivo Principal:** [Top_Module.v](./06_Calculadora/src/top_calc.v)
* **Constraint File (.xdc/.ucf):** [Pines.xdc](./06_Calculadora/src/constraints.xdc)

### Demostración Final
#### Simulación de una operación completa
*Ejemplo: Ingresar 10, seleccionar multiplicación, ingresar 5, obtener 50.*
![Simulación Completa](./assets/full_sim.png)

#### Video del Proyecto Final
Prueba completa en la FPGA con todas las operaciones.
[**VER VIDEO EN YOUTUBE**](LINK_AQUI)

---
