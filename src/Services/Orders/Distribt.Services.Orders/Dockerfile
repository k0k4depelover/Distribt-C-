FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY GlobalSettings.msbuild ./
COPY src/ ./src

RUN dotnet restore "src/Services/Orders/Distribt.Services.Orders/Distribt.Services.Orders.csproj"

WORKDIR "/src/src/Services/Orders/Distribt.Services.Orders"
RUN dotnet publish "Distribt.Services.Orders.csproj" -c Release -o /app/publish /p:UseAppHost=false


FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080