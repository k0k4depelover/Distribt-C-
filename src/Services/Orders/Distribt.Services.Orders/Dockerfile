FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

COPY ["SharedSetup/SharedSetup.csproj", "SharedSetup/"]

COPY ["Orders/Distribt.Services.Orders/Distribt.Services.Orders.csproj", "Orders/Distribt.Services.Orders/"]
COPY ["Orders/Distribt.Services.Orders.BusinessLogic/Distribt.Services.Orders.BusinessLogic.csproj", "Orders/Distribt.Services.Orders.BusinessLogic/"]
COPY ["Orders/Distribt.Services.Orders.Consumer/Distribt.Services.Orders.Consumer.csproj", "Orders/Distribt.Services.Orders.Consumer/"]
COPY ["Orders/Distribt.Services.Orders.Dto/Distribt.Services.Orders.Dto.csproj", "Orders/Distribt.Services.Orders.Dto/"]

RUN dotnet restore "Orders/Distribt.Services.Orders/Distribt.Services.Orders.csproj"


COPY ["SharedSetup/", "SharedSetup/"]
COPY ["Orders/", "Orders/"]

WORKDIR "/src/Orders/Distribt.Services.Orders"
RUN dotnet publish "Distribt.Services.Orders.csproj" -c Release -o /app/publish /p:UseAppHost=false


FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app

COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

ENTRYPOINT ["dotnet", "Distribt.Services.Orders.dll"]
