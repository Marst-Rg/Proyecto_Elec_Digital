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
5. [Convertidor BCD a Binario](#5-convertidor-bcd-a-binario)
6. [Calculadora](#6-calculadora)
7. [Proyecto](#7-proyeccto)
---

## 1. Multiplicador

### Especificaciones Iniciales
Descripción breve de los bits de entrada, salida y el método utilizado (ej: Algoritmo de Booth o Sumas sucesivas).

### Diseño del Sistema
#### Diagrama de Flujo (Algoritmo)
![Diagrama de Flujo Multiplicador](./assets/mult_flujo.png)

#### Diagrama de Bloques (Camino de Datos)
![Datapath Multiplicador](./assets/mult_datapath.png)

#### Máquina de Estados (Control)
![FSM Multiplicador](./assets/mult_fsm.png)

### Implementación
* **Camino de Datos:** [Ver Código](./01_Multiplicador/src/datapath.v)
* **Unidad de Control:** [Ver Código](./01_Multiplicador/src/control_unit.v)

### Simulación
Explicación breve de qué se observa en la imagen.
![Simulación Multiplicador](./assets/mult_sim.png)

### Pruebas en FPGA
[Ver Video de Funcionamiento en YouTube](LINK_DEL_VIDEO_AQUI)

---

## 2. Divisor




---

## 3. Raíz Cuadrada

### Especificaciones Iniciales
* **Entrada:** Número binario de *N* bits (ej: 16 bits).
* **Salida:** Parte entera de la raíz (*N/2* bits) y residuo.
* **Método:** (Ej: Algoritmo non-restoring o de sustracción iterativa).

### Diseño del Sistema
#### Diagrama de Flujo (Algoritmo)
![Algoritmo Raíz](./assets/sqrt_flujo.png)

#### Diagrama de Bloques (Camino de Datos)
![Datapath Raíz](./assets/sqrt_datapath.png)

#### Máquina de Estados (Control)
![FSM Raíz](./assets/sqrt_fsm.png)

### Implementación
* **Camino de Datos:** [Ver Código](./03_Raiz_Cuadrada/src/datapath.v)
* **Unidad de Control:** [Ver Código](./03_Raiz_Cuadrada/src/control_unit.v)

### Simulación
Descripción de la prueba: *Se verifica la raíz de 144 (resultado 12) y 150 (resultado 12, residuo 6).*
![Simulación Raíz](./assets/sqrt_sim.png)

### Pruebas en FPGA
[Ver Video de Funcionamiento](./assets/video_sqrt_link.md)

---

## 4. Convertidor Binario a BCD

### Especificaciones Iniciales
* **Propósito:** Convertir el resultado binario para visualizarlo en los displays de 7 segmentos.
* **Método:** (Ej: Algoritmo Shift-Add-3 / Double Dabble).

### Diseño del Sistema
#### Diagrama de Flujo
![Algoritmo Bin2BCD](./assets/bin2bcd_flujo.png)

#### Diagrama de Bloques
![Datapath Bin2BCD](./assets/bin2bcd_datapath.png)

#### Máquina de Estados
*(Si aplica, o explicar si es un diseño iterativo)*
![FSM Bin2BCD](./assets/bin2bcd_fsm.png)

### Implementación
* **Código Fuente:** [Ver Código](./04_Binario_BCD/src/bin_to_bcd.v)

### Simulación
![Simulación Bin2BCD](./assets/bin2bcd_sim.png)

---

## 5. Convertidor BCD a Binario

### Especificaciones Iniciales
* **Propósito:** Ingresar datos en decimal (teclado) y convertirlos a binario para ser procesados.
* **Método:** (Ej: Algoritmo Reverse Double Dabble o Multiplicación por pesos).

### Diseño del Sistema
#### Diagrama de Flujo
![Algoritmo BCD2Bin](./assets/bcd2bin_flujo.png)

#### Diagrama de Bloques
![Datapath BCD2Bin](./assets/bcd2bin_datapath.png)

#### Máquina de Estados
![FSM BCD2Bin](./assets/bcd2bin_fsm.png)

### Implementación
* **Código Fuente:** [Ver Código](./05_BCD_Binario/src/bcd_to_bin.v)

### Simulación
![Simulación BCD2Bin](./assets/bcd2bin_sim.png)

---

## 6. Calculadora (Integración Final)

### Especificaciones del Sistema Completo
Descripción de la ALU (Unidad Aritmético Lógica) o el sistema central que une todos los módulos anteriores.
* **Entradas:** Teclado matricial 4x4 / Switches.
* **Salidas:** Displays de 7 segmentos / VGA.
* **Operaciones Soportadas:** Suma, Resta, Multiplicación, División, Raíz.

### Diagrama de Bloques General (Top Level)
*Este diagrama muestra cómo se conectan los submódulos (instancias) entre sí.*
![Arquitectura Calculadora](./assets/top_level_diagram.png)

### Máquina de Estados Principal
*Diagrama de la FSM que controla qué operación se realiza según la entrada del usuario.*
![FSM Principal](./assets/main_fsm.png)

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
