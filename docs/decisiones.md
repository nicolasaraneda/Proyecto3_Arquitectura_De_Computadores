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
- Consecuencia: al crear asic_top se eliminaron rtl/game_top.v, goboard.pcf y los objetivos de síntesis y programación de la FPGA del Makefile.

## D6. Reset del macro (25-10-2026)

- Opciones: (a) rst_n externo activo en bajo con sincronizador de 2 flip-flops; (b) rst_n externo directo; (c) rst_n externo manteniendo el contador de 4096 ciclos.
- Elegida: (a).
- Razón: el contador del Proyecto 2 dependía del valor inicial que da la FPGA y existía por la BRAM, que ya no está. El sincronizador hace que todos los flip-flops salgan del reset en el mismo flanco.
- Qué se pierde: la espera de 164 µs al encender, que ya no protege nada.

## D7. SPI (25-10-2026)

- Opciones: (a) puertos presentes sin lógica, con MISO fijo; (b) instanciar pochoco_spi_slave.
- Elegida: (a).
- Razón: el juego no usa SPI, y el módulo está marcado como trabajo en progreso, con registros de otro proyecto; instanciarlo agrega área y lógica sin verificar.
- Qué se pierde: los puertos SPI quedan sin función y no se implementa el bootloader por SPI (opcional en el enunciado).

## D8. Polaridad de los 7 segmentos (25-10-2026)

- Opciones: (a) activos en alto en los puertos del macro; (b) activos en bajo, como en la Go Board.
- Elegida: (a).
- Razón: los puertos representan la función lógica (1 = segmento encendido); la inversión era propia del display de la Go Board.
- Qué se pierde: la salida deja de coincidir con la del Proyecto 2; un display activo en bajo necesitaría invertirla afuera.

## D9. Palabras de la RAM de datos (25-10-2026)

- Opciones: (a) 0 palabras, sin RAM de datos; (b) 4 palabras; (c) 64 palabras, el máximo recomendado.
- Elegida: (b), con el mismo valor en las dos estrategias (DataWords = 4).
- Razón: el juego usa 0 palabras de datos (0 lecturas y 0 escrituras en la simulación completa, y todos los lw y sw van a periféricos a través de x2). Cuatro palabras mantienen la RAM de datos que pide la estrategia 1 con un costo mínimo, y usar el mismo valor en la estrategia 2 hace que la comparación mida solo cómo se guarda el programa.
- Qué se pierde: 128 flip-flops que el juego no usa. Con (a), la estrategia 1 quedaría sin la RAM de datos que nombra el enunciado; con (c), la RAM dominaría el área de ambas estrategias.

## D10. Constantes del juego para el macro (25-10-2026)

- Opciones: (a) regenerar el programa para T = 100 ns antes de comparar las estrategias de memoria; (b) hacerlo al final, en la sección 3.4.
- Elegida: (a).
- Razón: las corridas de la comparación, y todas las siguientes, usan el mismo programa que correría el macro.
- Cálculo: f = 1/T = 1/100 ns = 10 MHz; una décima son 0,1 s × 10.000.000 ciclos/s = 1.000.000 ciclos. CLK_HZ = 10.000.000 y CYCLES_PER_TENTH = 1.000.000. ESPERA_TENTHS sigue en 30 (3 s) y el tiempo se sigue mostrando en décimas.
- Nota: el debounce sigue con DebounceDivBits = 15; a 10 MHz muestrea cada 3,3 ms y acepta un cambio en unos 10 ms, muy por debajo de la décima que se muestra.
- Qué se pierde: nada en las simulaciones, que ensamblan con CYCLES_PER_TENTH = 2500; en la imagen cambian 4 palabras.
