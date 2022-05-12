# FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-env
FROM node:16.14.2

COPY ./debug /app
COPY ./proxor/bin /bin

EXPOSE 80

CMD ["node", "/app/main.js"]
