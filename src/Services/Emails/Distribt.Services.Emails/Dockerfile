FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY GlobalSettings.msbuild ./
COPY src/ ./src/

RUN dotnet restore "src/Services/Emails/Distribt.Services.Emails/Distribt.Services.Emails.csproj"

WORKDIR /src/src/Services/Emails/Distribt.Services.Emails
RUN dotnet publish "Distribt.Services.Emails.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish .
ENV ASPNETCORE_URLS=http://+:8000
EXPOSE 8000