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
