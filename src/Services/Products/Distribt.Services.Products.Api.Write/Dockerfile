FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY GlobalSettings.msbuild ./
COPY src/ ./src

RUN dotnet restore "src/Services/Products/Distribt.Services.Products.Api.Write/Distribt.Services.Products.Api.Write.csproj"

WORKDIR "/src/src/Services/Products/Distribt.Services.Products.Api.Write"
RUN dotnet publish "Distribt.Services.Products.Api.Write.csproj" -c Release -o /app/publish /p:UseAppHost=false


FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080