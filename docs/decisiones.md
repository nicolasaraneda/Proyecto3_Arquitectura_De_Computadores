# Decisiones del proyecto

Cada decisión registra las opciones, la elegida, la razón y lo que se pierde con la opción descartada.

## D1. Cómo se trajo el Proyecto 2 a este repositorio (25-10-2026)

- Opciones: (a) copiar los archivos en un commit inicial; (b) traer el historial completo con un merge del repositorio del Proyecto 2.
- Elegida: (b). El punto de partida es el commit `1227fa5` de `Vcalderone/Proyecto2_Arquitectura_De_Computadores`.
- Razón: `git diff 1227fa5` muestra exactamente qué se cambió para pasar de FPGA a ASIC, que es lo que se puede preguntar en la defensa.
- Qué se pierde: el repositorio arrastra los commits del Proyecto 2 y archivos propios de la FPGA (Makefile del iCE40, goboard.pcf, informe del Proyecto 2), que se ordenarán aparte.

## D2. Cómo se instala LibreLane (25-10-2026)

- Opciones: Nix o Docker.
- Elegida: Docker. LibreLane 3.0.16 instalado con pip en un entorno virtual (`~/herramientas/librelane`); las corridas usan `--dockerized`.
- Razón: lo hablamos con el profesor, y Nicolás ya usa Docker en otros dos proyectos.
- Qué se pierde: las herramientas corren dentro de un contenedor, y abrir KLayout u OpenROAD GUI desde ahí es más engorroso que con Nix.

## D3. Lectura del banco de registros en flip-flops (25-10-2026)

- Opciones: (a) lectura sincrónica, igual que la BRAM; (b) lectura combinacional.
- Elegida: (a).
- Razón: es un reemplazo directo de la BRAM por flip-flops; el ID stage y el controlador no cambian y cada instrucción toma los mismos ciclos que en el Proyecto 2. Verificado: los tres testbenches dan los mismos 101 checks en los mismos instantes que el commit 1227fa5.
- Qué se pierde: el ciclo de espera de lectura por instrucción y 64 flip-flops de salida.

## D4. Reset del banco de registros (25-10-2026)

- Opciones: (a) solo x0 fijo en 0 y x1 a x15 sin reset; (b) reset a 0 de los 15 registros.
- Elegida: (a).
- Razón: igual que en la BRAM, los registros no necesitan reset porque el juego escribe cada registro antes de leerlo. Verificado con un monitor sobre la simulación de game_tb: 0 valores desconocidos (X) usados en 388411 escrituras al banco.
- Qué se pierde: si un cambio futuro de game.s leyera un registro antes de escribirlo, su valor en silicio no estaría definido.

## D5. Dónde van los cambios de RTL (25-10-2026)

- Opciones: (a) en los mismos archivos de rtl/; (b) en una carpeta nueva.
- Elegida: (a).
- Razón: junto con D1, git diff 1227fa5 muestra cada cambio hecho para ASIC.
- Qué se pierde: el diseño deja de caber en la Go Board; para volver a la placa hay que usar el commit 1227fa5.
