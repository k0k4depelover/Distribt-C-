FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY GlobalSettings.msbuild ./
COPY src/ ./src

RUN dotnet restore "src/Services/Products/Distribt.Services.Products.Consumer/Distribt.Services.Products.Consumer.csproj"

WORKDIR "/src/src/Services/Products/Distribt.Services.Products.Consumer"
RUN dotnet publish "Distribt.Services.Products.Consumer.csproj" -c Release -o /app/publish /p:UseAppHost=false


FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080