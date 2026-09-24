# Dockerfile del repositorio base.
# Contiene cinco malas practicas deliberadas. Cada una lleva su numero en la
# linea anterior. Corregirlas es el bloque A1 de la guia del laboratorio.

# defecto 1
# FROM public.ecr.aws/lambda/nodejs:latest

# defecto 2
# COPY . .

# defecto 3
#RUN npm install

# defecto 4
# ENV DB_PASSWORD="inf384-clave-en-texto-plano"

# defecto 5
# RUN dnf install -y procps-ng vim && dnf clean all

# CMD ["src/handler.handler"]


# nuevo dockerfile
# Etapa 1: construcción
FROM public.ecr.aws/lambda/nodejs:20 AS build

WORKDIR ${LAMBDA_TASK_ROOT}

# Primero copiamos los manifiestos de dependencias
COPY package.json package-lock.json ./

# Instalación reproducible usando el lock file
RUN npm ci

# Ahora copiamos solamente el código de la aplicación
COPY src ./src

# Genera dist/handler.js usando esbuild
RUN npm run build


# Etapa 2: imagen final de ejecución
FROM public.ecr.aws/lambda/nodejs:20 AS runtime

WORKDIR ${LAMBDA_TASK_ROOT}

# Solo copiamos el artefacto empaquetado
COPY --from=build ${LAMBDA_TASK_ROOT}/dist/handler.js ./dist/handler.js

# Handler que ejecutará AWS Lambda
CMD ["dist/handler.handler"]
